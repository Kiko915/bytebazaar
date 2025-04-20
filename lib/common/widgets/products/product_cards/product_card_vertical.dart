import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BProductCardVertical extends StatelessWidget {
  const BProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);

    return SizedBox(
      width: 180,
      height: 254,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BSizes.productImageRadius),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          _buildThumbnailSection(context, dark),
          const SizedBox(height: BSizes.xs / 4),
          Padding(
              padding: const EdgeInsets.only(
                left: BSizes.sm,
                right: BSizes.sm,
                bottom: BSizes.xs,
              ),
              child: SizedBox(
                height: 114,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProductTitle(context),
                _buildStoreLocation(context),
                _buildPriceSection(context),
                _buildRatingAndSoldCount(context),
              ],
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildThumbnailSection(BuildContext context, bool dark) {
    return Container(
      height: 128,
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
              height: 128,
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
    );
  }

  Widget _buildProductTitle(BuildContext context) {
    return Text(
      '327 Moonbeam Stone Pink Women',
      style: Theme.of(context).textTheme.labelMedium,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.left,
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
        Expanded(
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
