import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bytebazaar/utils/constants/colors.dart';

class ProductCardMinimal extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String discountedPrice;
  final double rating;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  const ProductCardMinimal({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.discountedPrice,
    required this.rating,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with badge and heart icon
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: (imageUrl.startsWith('http') || imageUrl.startsWith('https'))
                        ? Image.network(
                            imageUrl,
                            width: constraints.maxWidth,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 64),
                          )
                        : Image.asset(
                            imageUrl,
                            width: constraints.maxWidth,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                  ),

                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      icon: Icon(
                        Iconsax.heart5,
                        size: 18,
                        color: isWishlisted ? Colors.red : BColors.grey,
                      ),
                      onPressed: onWishlistToggle,
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: textScale,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        (price.startsWith('\u20B1') || price.startsWith('₱')) ? price : '\u20B1$price',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: BColors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        textScaleFactor: textScale,
                      ),
                      const SizedBox(width: 4),
                      if (discountedPrice.isNotEmpty)
                        Text(
                          discountedPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: BColors.textLight,
                          ),
                          textScaleFactor: textScale,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Icon(Iconsax.star5, color: Colors.amber, size: 14 * textScale),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall,
                  textScaleFactor: textScale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
