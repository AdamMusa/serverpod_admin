import 'package:flutter/material.dart';

/// Empty state widget for records table.
/// Shows different messages for empty table vs no search results.
class RecordsEmptyState extends StatelessWidget {
  const RecordsEmptyState({
    required this.searchQuery,
    this.totalRecords,
    super.key,
  });

  final String? searchQuery;
  final int? totalRecords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearchResult = searchQuery != null &&
        searchQuery!.isNotEmpty &&
        totalRecords != null &&
        totalRecords! > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSearchResult
                    ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                    : theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchResult
                    ? Icons.search_off_rounded
                    : Icons.inbox_outlined,
                size: 64,
                color: isSearchResult
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResult ? 'No matching records found' : 'No records yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearchResult
                  ? 'Try adjusting your search query to find what you\'re looking for.'
                  : 'This table is empty. Create your first record to get started.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearchResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Searching for: "$searchQuery"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
