part of '../../../../../main.dart';

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 54,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text('No products yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add a perfume product to rebuild the list.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
