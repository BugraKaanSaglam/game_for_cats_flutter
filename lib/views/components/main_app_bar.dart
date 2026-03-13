import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';

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
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final leading = hasBackButton
        ? IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: onBack ?? () => context.go(AppRoutes.main),
          )
        : null;

    return AppBar(
      toolbarHeight: 64,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
      leading: leading,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PawPalette.midnight,
              PawPalette.ink.withValues(alpha: 0.96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: PawPalette.midnight.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
    );
  }
}
