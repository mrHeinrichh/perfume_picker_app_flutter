part of '../../../../../main.dart';

class _ImagePickerPanel extends StatelessWidget {
  const _ImagePickerPanel({
    required this.product,
    required this.imageBytes,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final PerfumeProduct? product;
  final Uint8List? imageBytes;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPickedImage = imageBytes != null;
    final hasExistingImage = product?.imageUrl.trim().isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8D0C4)),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4ED),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPickedImage
                ? Image.memory(
                    imageBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  )
                : hasExistingImage
                ? Center(
                    child: ProductImage(
                      product: product!,
                      size: 82,
                      hero: false,
                    ),
                  )
                : const Icon(Icons.add_photo_alternate_outlined, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product image', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  hasPickedImage
                      ? 'Gallery photo selected'
                      : hasExistingImage
                      ? 'Current product photo'
                      : 'No photo selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: .58),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onPickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(hasPickedImage ? 'Change' : 'Gallery'),
                    ),
                    if (onRemoveImage != null)
                      IconButton.filledTonal(
                        tooltip: 'Remove selected image',
                        onPressed: onRemoveImage,
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
