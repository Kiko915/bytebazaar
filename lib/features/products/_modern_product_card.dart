import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

class ModernProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String discountedPrice;
  final double rating;
  final int sold;

  const ModernProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.discountedPrice,
    required this.rating,
    required this.sold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: BColors.primary.withOpacity(0.09),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: BColors.primary.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: BColors.primary.withOpacity(0.08),
                child: Icon(Icons.broken_image_outlined, color: BColors.primary, size: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: BColors.primary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              children: [
                Icon(Iconsax.location, size: 14, color: BColors.primary.withOpacity(0.65)),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodySmall?.copyWith(color: BColors.primary.withOpacity(0.65)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              children: [
                Text(
                  '\₱$discountedPrice',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: BColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto'
                  ),
                ),
                if (discountedPrice != price)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      '\₱$price',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'Roboto'
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              children: [
                Icon(Iconsax.star1, color: Colors.amber, size: 15),
                SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 8),
                Icon(Iconsax.shopping_bag, color: BColors.primary, size: 15),
                SizedBox(width: 2),
                Text(
                  '$sold sold',
                  style: theme.textTheme.bodySmall?.copyWith(color: BColors.primary.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
