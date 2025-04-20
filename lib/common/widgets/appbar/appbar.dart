import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/device/device_utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = true, // Default to true, but WishlistScreen sets it to false
    this.flexibleSpace,
  });

  final Widget? title;
  final List<Widget>? actions;
  final IconData? leadingIcon;
  final VoidCallback? leadingOnPressed;
  final bool showBackArrow;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false, // We handle leading icon manually
        leading: showBackArrow
            ? IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Iconsax.arrow_left, color: BColors.white)) // Default back arrow
            : leadingIcon != null
                ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
                : null,
        title: title,
        centerTitle: false,
        actions: actions,
        flexibleSpace: flexibleSpace, // Allow gradient background
        backgroundColor: Colors.transparent, // Make AppBar transparent to show flexibleSpace
        elevation: 0, // Remove shadow
      );
  }

  @override
  Size get preferredSize => Size.fromHeight(BDevice.getAppBarHeight());
}
