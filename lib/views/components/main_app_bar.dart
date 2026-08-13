import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mice_and_paws_cat_game/routing/app_routes.dart';
import 'package:mice_and_paws_cat_game/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';

/// Transparent app bar whose title and controls sit on the page artwork.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    required this.title,
    this.hasBackButton = true,
    this.onBack,
  });

  final String title;
  final bool hasBackButton;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 68,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: hasBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HuntColors.sun,
                  shape: BoxShape.circle,
                  border: Border.all(color: HuntColors.sunLine, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  color: HuntColors.ink,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack ?? () => context.go(AppRoutes.main),
                ),
              ),
            )
          : null,
      title: DecoratedBox(
        decoration: BoxDecoration(
          color: HuntColors.sun,
          borderRadius: BorderRadius.circular(HuntRadii.pill),
          border: Border.all(color: HuntColors.sunLine, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            title,
            style: HuntTextStyles.action.copyWith(
              color: HuntColors.ink,
              fontSize: 18,
            ),
          ),
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }
}
