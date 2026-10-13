/// What a column value links to, so the dashboard can show it in place.
enum LinkKind { image, pdf, page }

const _imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];

/// The kind of document [value] links to, or null when it is not an
/// http(s) URL. Signed preview links often name the file in a query
/// parameter (`?document=…/licence.jpg`), so those are checked too.
LinkKind? linkKind(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty || text.contains(' ')) return null;
  final uri = Uri.tryParse(text);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  final names = [
    uri.path,
    ...uri.queryParameters.values,
  ].map((name) => name.toLowerCase()).toList();
  bool named(Iterable<String> extensions) =>
      names.any((name) => extensions.any((e) => name.endsWith('.$e')));
  if (named(_imageExtensions)) return LinkKind.image;
  if (named(const ['pdf'])) return LinkKind.pdf;
  return LinkKind.page;
}
