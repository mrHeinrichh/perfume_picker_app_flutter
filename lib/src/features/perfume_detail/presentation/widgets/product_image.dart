part of '../../../../../main.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    required this.size,
    this.hero = true,
  });

  final PerfumeProduct product;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final imagePath = product.imageUrl.trim();
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    final imageBytes = product.imageBytes;

    final image = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .92,
            height: size * .92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: product.glow.withValues(alpha: .28),
            ),
          ),
          if (imageBytes != null || imagePath.isNotEmpty)
            Container(
              width: size * .76,
              height: size * .76,
              padding: EdgeInsets.all(size * .06),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(size * .16),
                boxShadow: [
                  BoxShadow(
                    color: product.accent.withValues(alpha: .16),
                    blurRadius: size * .14,
                    offset: Offset(0, size * .05),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * .11),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: size * .64,
                        height: size * .64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            _BottleFallback(product: product, size: size),
                      )
                    : isNetworkImage
                    ? Image.network(
                        imagePath,
                        width: size * .64,
                        height: size * .64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            _BottleFallback(product: product, size: size),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _BottleFallback(product: product, size: size);
                        },
                      )
                    : Image.asset(
                        imagePath,
                        width: size * .64,
                        height: size * .64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            _BottleFallback(product: product, size: size),
                      ),
              ),
            )
          else
            _BottleFallback(product: product, size: size),
        ],
      ),
    );

    if (!hero) return image;

    return Hero(tag: 'product-image-${product.id}', child: image);
  }
}

class _BottleFallback extends StatelessWidget {
  const _BottleFallback({required this.product, required this.size});

  final PerfumeProduct product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: size * .13,
          child: Container(
            width: size * .28,
            height: size * .17,
            decoration: BoxDecoration(
              color: product.glow.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(size * .06),
            ),
          ),
        ),
        Positioned(
          bottom: size * .1,
          child: Container(
            width: size * .58,
            height: size * .66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [product.glow.withValues(alpha: .96), product.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: product.accent.withValues(alpha: .26),
                  blurRadius: size * .17,
                  offset: Offset(0, size * .08),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: size * .3,
                height: size * .3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .86),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: product.accent,
                  size: size * .17,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
