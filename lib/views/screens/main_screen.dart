// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/controllers/main_controller.dart';
import 'package:game_for_cats_2025/models/database/db_error.dart';
import 'package:game_for_cats_2025/models/database/opc_database_list.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/views/widgets/animated_gradient_background.dart';
import 'package:game_for_cats_2025/views/widgets/cool_animated_buttons.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

import '../components/main_app_bar.dart';
import 'package:game_for_cats_2025/main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final MainController _controller;
  late Future<OPCDataBase> _configurationFuture;
  OPCDataBase? _db;
  late AnimationController _buttonController;
  late AnimationController _ambientController;
  bool _didApplyLocale = false;
  final List<_OrbConfig> _orbConfigs = const [_OrbConfig(alignment: Alignment(-0.9, -0.8), color: Color(0xFFFFD6E8), size: 190, travel: 0.08), _OrbConfig(alignment: Alignment(0.85, -0.6), color: Color(0xFFB8E1FF), size: 150, travel: 0.06, phase: 1.2), _OrbConfig(alignment: Alignment(-0.5, 0.75), color: Color(0xFFFFF5D7), size: 230, travel: 0.05, phase: 2.4)];

  @override
  void initState() {
    super.initState();
    _controller = MainController();
    _configurationFuture = _controller.fetchConfiguration().then((value) => _controller.ensureConfiguration(value));
    _buttonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _ambientController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: mainAppBar(AppLocalizations.of(context)!.game_name, context, hasBackButton: false), body: mainBody(context));
  }

  Widget mainBody(BuildContext context) {
    return AnimatedGradientBackground(
      child: FutureBuilder<OPCDataBase>(
        future: _configurationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return dbError(context);
          }

          final configuration = snapshot.data;
          if (configuration == null) {
            return dbError(context);
          }

          _db = configuration;

          if (_buttonController.status != AnimationStatus.forward && _buttonController.status != AnimationStatus.completed) {
            unawaited(_buttonController.forward());
          }

          _controller.applyGameTime(configuration);
          final language = _controller.applyLanguage(configuration);
          languageCode = language;

          if (!_didApplyLocale) {
            _didApplyLocale = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => MainApp.of(context)?.setLocale(language.value));
          }

          return Stack(
            children: [
              _buildAmbientOrbs(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth > 800 ? constraints.maxWidth * 0.25 : 24.0;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGreeting(context),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: _buildMenuButtons(constraints)),
                            ),
                          ),
                          _buildStaggeredAnimatedButton(
                            delay: 0.6,
                            child: CoolAnimatedButton(text: AppLocalizations.of(context)!.exit_button, icon: const Icon(Icons.exit_to_app_outlined), onPressed: () => exit(0), startColor: const Color(0xFFF9605F), endColor: const Color(0xFFEF5350)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper function for staggered animation
  Widget _buildStaggeredAnimatedButton({required Widget child, required double delay}) {
    final animation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _buttonController.drive(CurveTween(curve: Curves.easeIn)),
        child: child,
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: PawPalette.pinkToOrange()),
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.game_name, style: PawTextStyles.heading),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(context)!.main_tagline, style: PawTextStyles.subheading),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BoxConstraints constraints) {
    final spacing = constraints.maxHeight * 0.02;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStaggeredAnimatedButton(
          delay: 0.0,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.start_button,
            icon: const Icon(Icons.arrow_right_alt_sharp),
            onPressed: () => _controller.navigateTo(context, '/game_screen', AppLocalizations.of(context)!.start_button, configuration: _db),
          ),
        ),
        SizedBox(height: spacing),
        _buildStaggeredAnimatedButton(
          delay: 0.15,
          child: CoolAnimatedButton(text: AppLocalizations.of(context)!.settings_button, icon: const Icon(Icons.settings), onPressed: () => _controller.navigateTo(context, '/settings_screen', AppLocalizations.of(context)!.settings_button)),
        ),
        SizedBox(height: spacing),
        _buildStaggeredAnimatedButton(
          delay: 0.30,
          child: CoolAnimatedButton(text: AppLocalizations.of(context)!.howtoplay_button, icon: const Icon(Icons.menu_book), onPressed: () => _controller.navigateTo(context, '/howtoplay_screen', AppLocalizations.of(context)!.howtoplay_button)),
        ),
        SizedBox(height: spacing),
        _buildStaggeredAnimatedButton(
          delay: 0.45,
          child: CoolAnimatedButton(text: AppLocalizations.of(context)!.credits_button, icon: const Icon(Icons.pest_control_rodent_sharp), onPressed: () => _controller.navigateTo(context, '/credits_screen', AppLocalizations.of(context)!.credits_button)),
        ),
        SizedBox(height: spacing),
        _buildStaggeredAnimatedButton(
          delay: 0.55,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.activity_button,
            icon: const Icon(Icons.show_chart_rounded),
            onPressed: () => _controller.navigateTo(context, '/activity_screen', AppLocalizations.of(context)!.activity_button),
            startColor: const Color(0xFF4FACFE),
            endColor: const Color(0xFF00F2FE),
          ),
        ),
      ],
    );
  }

  Widget _buildAmbientOrbs() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, _) {
          return Stack(
            children: _orbConfigs.map((orb) {
              final oscillation = math.sin((_ambientController.value * 2 * math.pi) + orb.phase) * orb.travel;
              final alignment = Alignment((orb.alignment.x + oscillation).clamp(-1.0, 1.0), (orb.alignment.y + oscillation).clamp(-1.0, 1.0));
              return Align(
                alignment: alignment,
                child: Container(
                  width: orb.size,
                  height: orb.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        orb.color.withValues(alpha: 0.45 * 255),
                        orb.color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _OrbConfig {
  const _OrbConfig({required this.alignment, required this.color, required this.size, required this.travel, this.phase = 0});

  final Alignment alignment;
  final Color color;
  final double size;
  final double travel;
  final double phase;
}
