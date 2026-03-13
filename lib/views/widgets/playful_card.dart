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
          PawPalette.bubbleGum.withValues(alpha: 0.9),
          PawPalette.teal.withValues(alpha: 0.9),
        ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              PawPalette.surface.withValues(alpha: 0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emoji != null)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji!, style: const TextStyle(fontSize: 22)),
                ),
              ),
            if (emoji != null) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: PawTextStyles.cardTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
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
