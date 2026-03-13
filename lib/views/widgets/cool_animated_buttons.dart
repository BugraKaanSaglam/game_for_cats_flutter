import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

class CoolAnimatedButton extends StatefulWidget {
  const CoolAnimatedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.startColor = PawPalette.bubbleGum,
    this.endColor = PawPalette.tangerine,
  });

  final String text;
  final Icon icon;
  final VoidCallback onPressed;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: IconTheme(
                        data: const IconThemeData(
                          color: Colors.white,
                          size: 22,
                        ),
                        child: widget.icon,
                      ),
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
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
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
