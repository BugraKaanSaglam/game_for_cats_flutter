import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: HuntColors.ink,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: hasBackButton
          ? IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack ?? () => context.go(AppRoutes.main),
            )
          : null,
      title: Text(
        title,
        style: HuntTextStyles.action.copyWith(
          color: HuntColors.paper,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: HuntColors.mossDark, width: 2),
      ),
    );
  }
}
