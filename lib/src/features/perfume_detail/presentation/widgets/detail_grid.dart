part of '../../../../../main.dart';

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.product, required this.match});

  final PerfumeProduct product;
  final PerfumeMatch match;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 680 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          childAspectRatio: columns == 4 ? 1.35 : 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _MetricTile(
              icon: Icons.percent_rounded,
              label: 'Match',
              value: '${match.matchPercentage}%',
            ),
            _MetricTile(
              icon: Icons.wc_outlined,
              label: 'Category',
              value: product.gender,
            ),
            _MetricTile(
              icon: Icons.auto_awesome_outlined,
              label: 'Characteristics',
              value: product.fragranceCharacteristics.join(', '),
            ),
            _MetricTile(
              icon: Icons.blur_on_rounded,
              label: 'Notes',
              value: '${product.notes.length} total',
            ),
          ],
        );
      },
    );
  }
}
