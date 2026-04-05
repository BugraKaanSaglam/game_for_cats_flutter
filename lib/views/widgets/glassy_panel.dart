import 'dart:ui';

import 'package:flutter/material.dart';

//* Small reusable frosted panel for stats / information overlays.
class GlassyPanel extends StatelessWidget {
  const GlassyPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blurSigma = 14,
    this.opacity = 0.25,
    this.gradient,
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    //! BackdropFilter is intentionally wrapped inside ClipRRect to keep the blur bounded.
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient:
          gradient ??
          LinearGradient(
            colors: [
              Colors.white.withValues(alpha: opacity.clamp(0, 1)),
              Colors.white.withValues(alpha: (opacity * 0.6).clamp(0, 1)),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 15),
        ),
      ],
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
