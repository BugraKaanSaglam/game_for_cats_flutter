import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

/// Rounded gradient tile with optional emoji avatar used across settings & info screens.
class PlayfulCard extends StatelessWidget {
  const PlayfulCard({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.emoji,
    this.gradient,
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final String? subtitle;
  final Widget? child;
  final String? emoji;
  final List<Color>? gradient;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors =
        gradient ??
        [
          PawPalette.bubbleGum.withValues(alpha: 0.9 * 255),
          PawPalette.teal.withValues(alpha: 0.9 * 255),
        ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withValues(alpha: 0.92 * 255),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emoji != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.first.withValues(alpha: 0.2 * 255),
                ),
                child: Text(emoji!, style: const TextStyle(fontSize: 20)),
              ),
            if (emoji != null) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: PawTextStyles.cardTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: PawTextStyles.cardSubtitle),
                  ],
                  if (child != null) ...[const SizedBox(height: 14), child!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
