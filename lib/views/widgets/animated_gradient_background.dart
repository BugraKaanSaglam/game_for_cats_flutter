import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

/// Reusable animated gradient background with a subtle dark overlay so that
/// foreground widgets stay readable regardless of the palette that is active.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.switchDuration = const Duration(seconds: 8),
    this.gradients = PawPalette.playfulBackgrounds,
    this.overlayOpacity = 0.08,
  });

  final Widget child;
  final Duration switchDuration;
  final List<List<Color>> gradients;
  final double overlayOpacity;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground> {
  int _currentIndex = 0;
  Timer? _timer;

  List<List<Color>> get _palettes => widget.gradients.isEmpty
      ? const [
          [Color(0xFF0F2027), Color(0xFF203A43)],
        ]
      : widget.gradients;

  @override
  void initState() {
    super.initState();
    _startCycling();
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.switchDuration != widget.switchDuration ||
        oldWidget.gradients.length != widget.gradients.length) {
      _timer?.cancel();
      _startCycling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCycling() {
    if (_palettes.length <= 1) return;
    _timer = Timer.periodic(widget.switchDuration, (_) {
      if (!mounted) return;
      setState(() => _currentIndex = (_currentIndex + 1) % _palettes.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[_currentIndex];

    return AnimatedContainer(
      duration: widget.switchDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.08 * 255),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.05 * 255),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: widget.overlayOpacity.clamp(0, 1) * 255,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
