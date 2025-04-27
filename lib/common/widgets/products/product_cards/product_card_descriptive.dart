import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bytebazaar/utils/constants/colors.dart';

class ProductCardDescriptive extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String discountedPrice;
  final double rating;
  final int sold;
  final String? badge;
  final VoidCallback? onWishlist;

  const ProductCardDescriptive({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.discountedPrice,
    required this.rating,
    required this.sold,
    this.badge,
    this.onWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with badge and heart icon
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 11 * textScale),
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Iconsax.heart5, size: 20, color: BColors.grey),
                  onPressed: onWishlist,
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: textScale,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Iconsax.location, color: BColors.grey, size: 14 * textScale),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.labelSmall?.copyWith(color: BColors.grey),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: textScale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: BColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: textScale,
                ),
                Row(
                  children: [
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.star5, color: Colors.amber, size: 14 * textScale),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall,
                      textScaleFactor: textScale,
                    ),
                    const SizedBox(width: 10),
                    Text('•', style: theme.textTheme.bodySmall?.copyWith(color: BColors.grey)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$sold Sold',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: textScale,
                      ),
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
