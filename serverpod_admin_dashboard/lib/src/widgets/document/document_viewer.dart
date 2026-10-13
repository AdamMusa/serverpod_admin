import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serverpod_admin_dashboard/src/helpers/links.dart';
import 'package:serverpod_admin_dashboard/src/widgets/document/embedded_frame.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in a new browser tab.
Future<void> openLink(String url) =>
    launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

/// Shows the document [url] links to inside the dashboard: images zoomable,
/// PDFs in the browser's viewer, other pages as a link to open.
Future<void> showDocumentViewer(
  BuildContext context, {
  required String url,
  required String title,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => DocumentViewer(url: url, title: title),
  );
}

class DocumentViewer extends StatelessWidget {
  const DocumentViewer({required this.url, required this.title, super.key});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = linkKind(url) ?? LinkKind.page;
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1100,
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
              child: Row(
                children: [
                  Icon(_icon(kind), color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy link',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(content: Text('Link copied.')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'Open in a new tab',
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => openLink(url),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SizedBox(
                height: kind == LinkKind.page ? null : size.height * 0.75,
                child: switch (kind) {
                  LinkKind.image => InteractiveViewer(
                    maxScale: 6,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, _, _) => _Unavailable(url: url),
                    ),
                  ),
                  LinkKind.pdf => embeddedFrame(url),
                  LinkKind.page => _Unavailable(url: url, page: true),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(LinkKind kind) => switch (kind) {
    LinkKind.image => Icons.image_outlined,
    LinkKind.pdf => Icons.picture_as_pdf_outlined,
    LinkKind.page => Icons.link,
  };
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.url, this.page = false});

  final String url;
  final bool page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            page ? Icons.public : Icons.broken_image_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            page
                ? 'This link opens a web page.'
                : 'The document could not be shown here. Its link may have '
                      'expired: refresh the list, or open it in a new tab.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SelectableText(
            url,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => openLink(url),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in a new tab'),
          ),
        ],
      ),
    );
  }
}
