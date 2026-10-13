import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/links.dart';
import 'package:serverpod_admin_dashboard/src/widgets/document/document_viewer.dart';

/// A link in a table cell or details row: a thumbnail for images, an icon
/// for PDFs and pages; tapping opens the document in the dashboard.
class LinkValue extends StatelessWidget {
  const LinkValue({
    required this.url,
    required this.kind,
    required this.title,
    this.large = false,
    super.key,
  });

  final String url;
  final LinkKind kind;
  final String title;

  /// Details rows show a bigger preview than table cells.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final side = large ? 120.0 : 32.0;
    final label = switch (kind) {
      LinkKind.image => 'View image',
      LinkKind.pdf => 'View PDF',
      LinkKind.page => Uri.tryParse(url)?.host ?? url,
    };
    final icon = switch (kind) {
      LinkKind.image => Icons.image_outlined,
      LinkKind.pdf => Icons.picture_as_pdf_outlined,
      LinkKind.page => Icons.link,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showDocumentViewer(context, url: url, title: title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kind == LinkKind.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  url,
                  width: side,
                  height: side,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) => Icon(icon, size: side * 0.7),
                ),
              )
            else
              Icon(
                icon,
                size: large ? 28 : 20,
                color: theme.colorScheme.primary,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
