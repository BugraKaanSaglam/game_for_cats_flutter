import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final leading = hasBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack ?? () => context.go(AppRoutes.main),
          )
        : null;

    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
      centerTitle: true,
      leading: leading,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shadowColor: Colors.black.withValues(alpha: 0.3 * 255),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 226, 142, 16), Color.fromARGB(255, 242, 11, 19)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
