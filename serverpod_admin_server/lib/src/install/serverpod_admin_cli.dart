import 'dart:io';

import 'package:archive/archive_io.dart';

const _defaultAssetUrl =
    'https://github.com/AdamMusa/serverpod_admin/releases/latest/download/serverpod_admin_dashboard_web.zip';
const _defaultTargetDirectory = 'web/admin';

class ServerpodAdminCli {
  Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty || _hasHelp(arguments)) {
      _printUsage();
      return;
    }

    final command = arguments.first;
    late final _CliOptions options;
    try {
      options = _CliOptions.parse(arguments.skip(1).toList());
    } on FormatException catch (error) {
      stderr.writeln(error.message);
      _printUsage();
      exitCode = 64;
      return;
    }

    switch (command) {
      case 'install':
        await _install(options);
      default:
        stderr.writeln('Unknown command: $command');
        _printUsage();
        exitCode = 64;
    }
  }

  Future<void> _install(_CliOptions options) async {
    final target = Directory(options.target ?? _defaultTargetDirectory);
    final source = options.source;

    if (target.existsSync()) {
      if (!options.force) {
        stderr.writeln(
          'Target ${target.path} already exists. Use --force to replace it.',
        );
        exitCode = 73;
        return;
      }
      target.deleteSync(recursive: true);
    }

    target.createSync(recursive: true);

    final tempDirectory = Directory.systemTemp.createTempSync(
      'serverpod_admin_install_',
    );
    try {
      final archiveFile = File('${tempDirectory.path}/dashboard.zip');
      if (source == null) {
        stdout.writeln('Downloading prebuilt admin dashboard...');
        await _download(_defaultAssetUrl, archiveFile);
      } else {
        await _copySourceToArchive(source, archiveFile);
      }

      final bytes = archiveFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      _extractArchive(archive, target);

      stdout.writeln('Installed Serverpod Admin dashboard to ${target.path}');
      stdout.writeln('''

Add this to your server.dart:

import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  admin.serveAdminDashboard(pod); // /admin

  await pod.start();
}

Custom path:
  admin.serveAdminDashboard(pod, path: '/customadminpath');
''');
    } finally {
      tempDirectory.deleteSync(recursive: true);
    }
  }

  Future<void> _download(String url, File destination) async {
    final client = HttpClient();
    try {
      var uri = Uri.parse(url);
      for (var redirects = 0; redirects < 5; redirects++) {
        final request = await client.getUrl(uri);
        final response = await request.close();

        if (response.isRedirect && response.headers.value('location') != null) {
          uri = uri.resolve(response.headers.value('location')!);
          continue;
        }

        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Failed to download dashboard bundle: HTTP ${response.statusCode}',
            uri: uri,
          );
        }

        await response.pipe(destination.openWrite());
        return;
      }

      throw HttpException('Too many redirects while downloading $url');
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _copySourceToArchive(
    String source,
    File archiveFile,
  ) async {
    final uri = Uri.tryParse(source);
    final isUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isUrl) {
      stdout.writeln('Downloading admin dashboard from $source...');
      await _download(source, archiveFile);
      return;
    }

    final sourceFile = File(source);
    if (sourceFile.existsSync()) {
      sourceFile.copySync(archiveFile.path);
      return;
    }

    final sourceDirectory = Directory(source);
    if (sourceDirectory.existsSync()) {
      final encoder = ZipFileEncoder();
      encoder.create(archiveFile.path);
      await encoder.addDirectory(sourceDirectory, includeDirName: false);
      await encoder.close();
      return;
    }

    throw FileSystemException('Source does not exist', source);
  }

  void _extractArchive(Archive archive, Directory target) {
    for (final file in archive.files) {
      final normalizedName = file.name.replaceAll('\\', '/');
      if (normalizedName.startsWith('/') || normalizedName.contains('../')) {
        throw const FormatException('Archive contains an unsafe path.');
      }

      final outputPath = '${target.path}/$normalizedName';
      if (file.isFile) {
        final output = File(outputPath)..createSync(recursive: true);
        output.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(outputPath).createSync(recursive: true);
      }
    }
  }

  bool _hasHelp(List<String> arguments) {
    return arguments.contains('-h') || arguments.contains('--help');
  }

  void _printUsage() {
    stdout.writeln('''
Serverpod Admin

Usage:
  dart run serverpod_admin_server:serverpod_admin install [options]

Options:
  --target <dir>   Install directory. Defaults to web/admin.
  --source <path>  Local zip, local build/web directory, or zip URL.
  --force          Replace the target directory if it already exists.
  -h, --help       Show this help.
''');
  }
}

class _CliOptions {
  const _CliOptions({
    required this.force,
    this.target,
    this.source,
  });

  final bool force;
  final String? target;
  final String? source;

  factory _CliOptions.parse(List<String> arguments) {
    var force = false;
    String? target;
    String? source;

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      switch (argument) {
        case '--force':
          force = true;
        case '--target':
          target = _readValue(arguments, ++index, '--target');
        case '--source':
          source = _readValue(arguments, ++index, '--source');
        default:
          throw FormatException('Unknown option: $argument');
      }
    }

    return _CliOptions(force: force, target: target, source: source);
  }

  static String _readValue(List<String> arguments, int index, String option) {
    if (index >= arguments.length) {
      throw FormatException('Missing value for $option');
    }
    return arguments[index];
  }
}
