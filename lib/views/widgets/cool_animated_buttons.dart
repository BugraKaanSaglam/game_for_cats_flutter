import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

class CoolAnimatedButton extends StatefulWidget {
  const CoolAnimatedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.compact = false,
    this.startColor = PawPalette.bubbleGum,
    this.endColor = PawPalette.tangerine,
  });

  final String text;
  final Icon icon;
  final VoidCallback onPressed;
  final bool compact;
  final Color startColor;
  final Color endColor;

  @override
  CoolAnimatedButtonState createState() => CoolAnimatedButtonState();
}

class CoolAnimatedButtonState extends State<CoolAnimatedButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _sheenController;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    Future.delayed(const Duration(milliseconds: 100), widget.onPressed);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.985 : 1.0;
    final elevation = _isPressed ? 10.0 : 18.0;
    final glowColor = Color.lerp(widget.startColor, widget.endColor, 0.5)!;
    final iconSize = widget.compact ? 38.0 : 42.0;
    final iconInnerSize = widget.compact ? 20.0 : 22.0;
    final labelFontSize = widget.compact ? 17.0 : 18.0;
    final horizontalPadding = widget.compact ? 16.0 : 18.0;
    final verticalPadding = widget.compact ? 14.0 : 16.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [widget.startColor, widget.endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.36),
                blurRadius: elevation,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedBuilder(
                      animation: _sheenController,
                      builder: (context, _) {
                        final wave = math.sin(
                          _sheenController.value * math.pi * 2,
                        );
                        return Stack(
                          children: [
                            Positioned(
                              left: 18 + (wave * 8),
                              top: 10,
                              child: _PawGlyph(
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            Positioned(
                              right: 82 - (wave * 10),
                              bottom: 10,
                              child: _PawGlyph(
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            Positioned(
                              left: 112,
                              bottom: 18 + (wave * 4),
                              child: Transform.rotate(
                                angle: -0.3,
                                child: _PawGlyph(
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedBuilder(
                      animation: _sheenController,
                      builder: (context, _) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final travel =
                                ((constraints.maxWidth + 120) *
                                    _sheenController.value) -
                                120;
                            return Stack(
                              children: [
                                Transform.translate(
                                  offset: Offset(travel, 0),
                                  child: Transform.rotate(
                                    angle: -0.35,
                                    child: Container(
                                      width: 72,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            Colors.white.withValues(
                                              alpha: 0.18,
                                            ),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _sheenController,
                      builder: (context, _) {
                        final pulse =
                            1 +
                            (math.sin(_sheenController.value * math.pi * 2) *
                                0.04);
                        return Transform.scale(
                          scale: pulse,
                          child: Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _PawGlyph(
                                  size: iconSize * 0.62,
                                  color: Colors.white.withValues(alpha: 0.14),
                                ),
                                IconTheme(
                                  data: IconThemeData(
                                    color: Colors.white,
                                    size: iconInnerSize,
                                  ),
                                  child: widget.icon,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.4,
                        ).copyWith(fontSize: labelFontSize),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: widget.compact ? 34 : 38,
                      height: widget.compact ? 34 : 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PawGlyph extends StatelessWidget {
  const _PawGlyph({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final toe = size * 0.2;
    final padWidth = size * 0.5;
    final padHeight = size * 0.34;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.14,
            top: size * 0.06,
            child: _PawDot(size: toe, color: color),
          ),
          Positioned(
            left: size * 0.38,
            top: 0,
            child: _PawDot(size: toe, color: color),
          ),
          Positioned(
            right: size * 0.14,
            top: size * 0.06,
            child: _PawDot(size: toe, color: color),
          ),
          Positioned(
            left: size * 0.3,
            top: size * 0.2,
            child: _PawDot(size: toe * 0.92, color: color),
          ),
          Positioned(
            left: (size - padWidth) / 2,
            bottom: size * 0.1,
            child: Container(
              width: padWidth,
              height: padHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(size * 0.22),
                  bottom: Radius.circular(size * 0.18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PawDot extends StatelessWidget {
  const _PawDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
