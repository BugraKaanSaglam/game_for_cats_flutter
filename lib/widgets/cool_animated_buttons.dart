// Dosya: lib/widgets/cool_animated_button.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CoolAnimatedButton extends StatefulWidget {
  final String text;
  final Icon icon;
  final VoidCallback onPressed;
  final Color startColor;
  final Color endColor;

  const CoolAnimatedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.startColor = const Color(0xFF6A11CB), // Mor
    this.endColor = const Color(0xFF2575FC), // Mavi
  });

  @override
  CoolAnimatedButtonState createState() => CoolAnimatedButtonState();
}

class CoolAnimatedButtonState extends State<CoolAnimatedButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    // Animasyonun bitmesi için küçük bir gecikme sonrası işlemi tetikle
    Future.delayed(const Duration(milliseconds: 100), widget.onPressed);
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Basılma durumuna göre gölgeyi ve konumu ayarla
    final double elevation = _isPressed ? 2.0 : 8.0;

    final Matrix4 transform = _isPressed ? (Matrix4.identity()..translate(0.0, 4.0, 0.0)) : Matrix4.identity();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: transform,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [widget.startColor, widget.endColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: widget.startColor.withOpacity(0.4), blurRadius: elevation * 2, offset: Offset(0, elevation))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
            ),
            const SizedBox(width: 12),
            IconTheme(
              data: const IconThemeData(color: Colors.white, size: 24),
              child: widget.icon,
            ),
          ],
        ),
      ),
    );
  }
}
