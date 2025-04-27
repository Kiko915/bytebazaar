import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BProductCardVertical extends StatelessWidget {
  const BProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isDark = BHelperFunctions.isDarkMode(context);
    final double cardWidth = size.width * 0.44; // Responsive width for grid
    final double cardHeight = size.height * 0.34; // Responsive height
    final double imageHeight = cardHeight * 0.54;
    final double detailsPadding = cardWidth * 0.06;

    return Center(
      child: Container(
        width: cardWidth.clamp(160, 400),
        constraints: BoxConstraints(
          minHeight: 220,
          maxHeight: cardHeight.clamp(240, 420),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BSizes.productImageRadius),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(BSizes.productImageRadius)),
                      child: Image.asset(
                        'assets/images/products/sample-product.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'New!',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.cardColor,
                      child: IconButton(
                        icon: Icon(Iconsax.heart5, color: BColors.grey, size: 16),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Flexible(
              child: Padding(
                padding: EdgeInsets.fromLTRB(detailsPadding, 8, detailsPadding, 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        '32 Moonbeam Stone Pink Women', // Replace with dynamic title
                        style: theme.textTheme.labelMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: textScale,
                      ),
                      SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(Iconsax.location, color: BColors.grey, size: 14 * textScale),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Cebu City',
                              style: theme.textTheme.labelSmall?.copyWith(color: BColors.grey),
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: textScale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      // Price
                      Text(
                        'PHP 2,137.50',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: textScale,
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '5%',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.red),
                            textScaleFactor: textScale,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'PHP 2,250.00',
                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: BColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: textScale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Ratings and Sold Count
                      Row(
                        children: [
                          Icon(Iconsax.star5, color: Colors.amber, size: 14 * textScale),
                          SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: theme.textTheme.bodySmall,
                            textScaleFactor: textScale,
                          ),
                          SizedBox(width: 8),
                          Text('•', style: theme.textTheme.bodySmall?.copyWith(color: BColors.grey)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '56 Sold',
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
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildThumbnailSection(BuildContext context, bool dark, double maxWidth) {
    return AspectRatio(
      aspectRatio: 1.25, // You can adjust this ratio as needed
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BSizes.productImageRadius),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(BSizes.productImageRadius),
              child: Image(
                width: double.infinity,
                height: double.infinity,
                image: const AssetImage('assets/images/products/sample-product.png'),
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            top: BSizes.sm,
            left: BSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BSizes.sm,
                vertical: BSizes.xs,
              ),
              decoration: BoxDecoration(
                color: BColors.primary,
                borderRadius: BorderRadius.circular(BSizes.borderRadiusSm),
              ),
              child: Text(
                'New!',
                style: Theme.of(context).textTheme.labelSmall!.apply(
                  color: BColors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: BSizes.sm,
            right: BSizes.sm,
            child: Container(
              decoration: BoxDecoration(
                color: BColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: BColors.darkGrey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  icon: const Icon(
                    Iconsax.heart5,
                    color: BColors.grey,
                    size: 16,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildProductTitle(BuildContext context) {
    const productTitle = '32 Moonbeam Stone Pink Women'; // Replace with actual product title from data
    return Tooltip(
      message: productTitle,
      child: Text(
        productTitle,
        style: Theme.of(context).textTheme.labelMedium,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHP 2,137.50',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: BColors.primary,
          ),
        ),
        const SizedBox(height: BSizes.xs / 2),
        Row(
          children: [
            Text(
              '5%',
              style: Theme.of(context).textTheme.labelSmall?.apply(
                color: Colors.red,
              ),
            ),
            const SizedBox(width: BSizes.sm),
            Flexible(
              child: Text(
                'PHP 2,250.00',
                style: Theme.of(context).textTheme.bodySmall!.apply(
                  decoration: TextDecoration.lineThrough,
                  color: BColors.textLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingAndSoldCount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Iconsax.star5,
          color: Colors.amber,
          size: BSizes.iconSm,
        ),
        const SizedBox(width: BSizes.xs),
        Text(
          '4.9',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: BSizes.sm),
        Text(
          '•',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: BColors.grey,
          ),
        ),
        const SizedBox(width: BSizes.sm),
        Flexible(
          child: Text(
            '56 Sold',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreLocation(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Iconsax.location,
          color: BColors.grey,
          size: BSizes.iconXs,
        ),
        const SizedBox(width: BSizes.xs / 2),
        Flexible(
          child: Text(
            'Cebu City',
            style: Theme.of(context).textTheme.labelSmall?.apply(
              color: BColors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
