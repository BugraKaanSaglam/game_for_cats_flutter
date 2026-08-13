import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mice_and_paws_cat_game/l10n/app_localizations.dart';
import 'package:mice_and_paws_cat_game/routing/app_routes.dart';
import 'package:mice_and_paws_cat_game/services/app_analytics.dart';
import 'package:mice_and_paws_cat_game/state/app_state.dart';
import 'package:mice_and_paws_cat_game/views/components/hunt_ui.dart';
import 'package:mice_and_paws_cat_game/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Two-step first-run guide that introduces the hunt interaction.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  late final AnimationController _ambientController;
  int _page = 0;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    AppAnalytics.screenView('onboarding');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        context.read<AppState>().settings?.reducedMotion ?? false;
    if (reducedMotion == _reducedMotion &&
        (_ambientController.isAnimating || reducedMotion)) {
      return;
    }
    _reducedMotion = reducedMotion;
    if (_reducedMotion) {
      _ambientController.stop();
    } else {
      _ambientController.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AppState>().completeOnboarding();
    if (mounted) context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final last = _page == 1;
    return HuntCorePage(
      title: l10n.game_name,
      showAppBar: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) => CustomPaint(
                painter: _OnboardingBackdropPainter(
                  progress: _reducedMotion ? 0.18 : _ambientController.value,
                  page: _page,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  HuntSpacing.lg,
                  HuntSpacing.md,
                  HuntSpacing.lg,
                  HuntSpacing.sm,
                ),
                child: AnimatedContainer(
                  duration: HuntMotion.standard,
                  curve: HuntMotion.curve,
                  padding: const EdgeInsets.symmetric(
                    horizontal: HuntSpacing.md,
                    vertical: HuntSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _page == 0
                          ? const [HuntColors.sun, HuntColors.coral]
                          : const [HuntColors.sky, HuntColors.field],
                    ),
                    borderRadius: BorderRadius.circular(HuntRadii.lg),
                    border: Border.all(color: HuntColors.paper),
                    boxShadow: [
                      BoxShadow(
                        color: HuntColors.ink.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: _page == 0 ? -0.04 : 0.04,
                        duration: HuntMotion.standard,
                        child: Icon(
                          _page == 0
                              ? Icons.pets_rounded
                              : Icons.track_changes_rounded,
                          color: HuntColors.ink,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: HuntSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.game_name,
                          style: HuntTextStyles.sectionTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          AppAnalytics.track(AnalyticsEvent.onboardingSkipped);
                          unawaited(_finish());
                        },
                        child: Text(
                          l10n.onboarding_skip,
                          style: HuntTextStyles.action.copyWith(
                            color: HuntColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _page = value),
                  children: [
                    _WelcomePage(
                      l10n: l10n,
                      animation: _ambientController,
                      reducedMotion: _reducedMotion,
                    ),
                    _PracticePage(l10n: l10n),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  HuntSpacing.lg,
                  HuntSpacing.sm,
                  HuntSpacing.lg,
                  HuntSpacing.lg,
                ),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(
                        2,
                        (index) => AnimatedContainer(
                          duration: HuntMotion.tap,
                          margin: const EdgeInsets.only(right: HuntSpacing.sm),
                          width: index == _page ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _page
                                ? (_page == 0
                                      ? HuntColors.coral
                                      : HuntColors.sky)
                                : HuntColors.lineStrong,
                            borderRadius: BorderRadius.circular(HuntRadii.pill),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 150,
                      child: HuntActionButton(
                        label: last
                            ? l10n.onboarding_start
                            : l10n.onboarding_next,
                        icon: last
                            ? Icons.play_arrow_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: () async {
                          if (last) {
                            await _finish();
                          } else {
                            AppAnalytics.track(
                              AnalyticsEvent.onboardingNextTapped,
                              parameters: {'pageIndex': _page},
                            );
                            await _controller.nextPage(
                              duration: HuntMotion.standard,
                              curve: HuntMotion.curve,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.l10n,
    required this.animation,
    required this.reducedMotion,
  });

  final AppLocalizations l10n;
  final Animation<double> animation;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(HuntSpacing.lg),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final lift = reducedMotion
                ? 0.0
                : math.sin(animation.value * math.pi * 2) * 4;
            return Transform.translate(offset: Offset(0, lift), child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(HuntSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [HuntColors.sun, HuntColors.paper, HuntColors.sky],
              ),
              borderRadius: BorderRadius.circular(HuntRadii.lg),
              border: Border.all(color: HuntColors.paper, width: 2),
              boxShadow: [
                BoxShadow(
                  color: HuntColors.ink.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 170,
                  child: _AnimatedWelcomeArt(
                    animation: animation,
                    reducedMotion: reducedMotion,
                  ),
                ),
                const SizedBox(height: HuntSpacing.lg),
                Text(
                  l10n.onboarding_title_welcome,
                  textAlign: TextAlign.center,
                  style: HuntTextStyles.pageTitle,
                ),
                const SizedBox(height: HuntSpacing.md),
                Text(
                  l10n.onboarding_subtitle_welcome,
                  textAlign: TextAlign.center,
                  style: HuntTextStyles.body,
                ),
                const SizedBox(height: HuntSpacing.lg),
                HuntTag(
                  label: l10n.home_feature_paw_first,
                  icon: Icons.touch_app_outlined,
                  tone: HuntTagTone.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticePage extends StatefulWidget {
  const _PracticePage({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<_PracticePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _tapped = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        context.read<AppState>().settings?.reducedMotion ?? false;
    if (reducedMotion == _reducedMotion &&
        (_controller.isAnimating || reducedMotion)) {
      return;
    }
    _reducedMotion = reducedMotion;
    if (_reducedMotion) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Padding(
      padding: const EdgeInsets.all(HuntSpacing.lg),
      child: Center(
        child: HuntSurface(
          tone: HuntSurfaceTone.field,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HuntSurface(
                tone: HuntSurfaceTone.field,
                padding: const EdgeInsets.all(HuntSpacing.md),
                child: GestureDetector(
                  onTap: () => setState(() => _tapped = !_tapped),
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => CustomPaint(
                        painter: _PracticePainter(
                          progress: _reducedMotion ? 0 : _controller.value,
                          tapped: _tapped,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HuntSpacing.lg),
              Text(
                l10n.onboarding_title_play,
                textAlign: TextAlign.center,
                style: HuntTextStyles.pageTitle,
              ),
              const SizedBox(height: HuntSpacing.sm),
              Text(
                l10n.onboarding_subtitle_play,
                textAlign: TextAlign.center,
                style: HuntTextStyles.body,
              ),
              const SizedBox(height: HuntSpacing.md),
              HuntTag(
                label: _tapped
                    ? l10n.current_streak_label
                    : l10n.guide_practice,
                icon: _tapped ? Icons.check_rounded : Icons.ads_click_rounded,
                tone: _tapped ? HuntTagTone.success : HuntTagTone.neutral,
              ),
              const SizedBox(height: HuntSpacing.sm),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: HuntSpacing.sm,
                runSpacing: HuntSpacing.sm,
                children: [
                  HuntTag(
                    label: l10n.micetap_count,
                    icon: Icons.mouse_rounded,
                    tone: HuntTagTone.success,
                  ),
                  HuntTag(
                    label: l10n.bugtap_count,
                    icon: Icons.bug_report_rounded,
                    tone: HuntTagTone.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedWelcomeArt extends StatelessWidget {
  const _AnimatedWelcomeArt({
    required this.animation,
    required this.reducedMotion,
  });

  final Animation<double> animation;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        painter: _WelcomePainter(
          progress: reducedMotion ? 0.18 : animation.value,
        ),
      ),
    );
  }
}

class _WelcomePainter extends CustomPainter {
  const _WelcomePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final pulse = 1 + math.sin(progress * math.pi * 2) * 0.08;
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = HuntColors.paper.withValues(alpha: 0.9);
    canvas.drawCircle(center, 54 * pulse, orbit);
    canvas.drawCircle(
      center,
      78 + math.sin(progress * math.pi * 2) * 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = HuntColors.coral.withValues(alpha: 0.65),
    );

    final target = Offset(
      center.dx + math.cos(progress * math.pi * 2) * 48,
      center.dy + math.sin(progress * math.pi * 2) * 28,
    );
    canvas.drawCircle(target, 28, Paint()..color = HuntColors.coral);
    canvas.drawCircle(
      target,
      17,
      Paint()..color = HuntColors.paper.withValues(alpha: 0.9),
    );
    canvas.drawCircle(target, 8, Paint()..color = HuntColors.moss);

    final pawPaint = Paint()..color = HuntColors.sky;
    final pawY = size.height * 0.82;
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.25 + i * 0.25);
      final y = pawY + math.sin(progress * math.pi * 2 + i) * 5;
      canvas.drawCircle(Offset(x, y), 8, pawPaint);
      canvas.drawCircle(Offset(x - 10, y - 11), 4, pawPaint);
      canvas.drawCircle(Offset(x, y - 15), 4, pawPaint);
      canvas.drawCircle(Offset(x + 10, y - 11), 4, pawPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WelcomePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _OnboardingBackdropPainter extends CustomPainter {
  const _OnboardingBackdropPainter({
    required this.progress,
    required this.page,
  });

  final double progress;
  final int page;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = page == 0
        ? [HuntColors.coral, HuntColors.sun, HuntColors.sky]
        : [HuntColors.sky, HuntColors.moss, HuntColors.coral];
    for (var i = 0; i < 7; i++) {
      final angle = progress * math.pi * 2 + i * 0.9;
      final x = size.width * (0.12 + (i % 4) * 0.27);
      final y = size.height * (0.14 + (i % 5) * 0.19);
      final offset = Offset(
        x + math.sin(angle) * 18,
        y + math.cos(angle * 1.2) * 14,
      );
      canvas.drawCircle(
        offset,
        8 + (i % 3) * 4,
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingBackdropPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.page != page;
}

class _PracticePainter extends CustomPainter {
  const _PracticePainter({required this.progress, required this.tapped});

  final double progress;
  final bool tapped;

  @override
  void paint(Canvas canvas, Size size) {
    final fieldRect = Offset.zero & size;
    final fieldRadius = RRect.fromRectAndRadius(
      fieldRect,
      const Radius.circular(20),
    );
    canvas.drawRRect(
      fieldRadius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HuntColors.sky, HuntColors.field, HuntColors.sun],
        ).createShader(fieldRect),
    );
    final line = Paint()
      ..color = HuntColors.paper.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(fieldRadius, line);
    final target = Offset(
      size.width * (0.18 + progress * 0.64),
      size.height * (0.38 + math.sin(progress * math.pi * 2) * 0.16),
    );
    final targetPaint = Paint()
      ..color = tapped ? HuntColors.moss : HuntColors.coral;
    canvas.drawCircle(target, 28, targetPaint);
    canvas.drawCircle(
      target,
      18,
      Paint()..color = HuntColors.paper.withValues(alpha: 0.8),
    );
    canvas.drawCircle(target, 8, targetPaint);
    final ringPaint = Paint()
      ..color = HuntColors.paper.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      target,
      38 + math.sin(progress * math.pi * 2) * 5,
      ringPaint,
    );
    for (var i = 0; i < 6; i++) {
      final angle = progress * math.pi * 2 + i * math.pi / 3;
      final start = Offset(
        target.dx + math.cos(angle) * 46,
        target.dy + math.sin(angle) * 46,
      );
      final end = Offset(
        target.dx + math.cos(angle) * 58,
        target.dy + math.sin(angle) * 58,
      );
      canvas.drawLine(start, end, ringPaint);
    }
    final pawPaint = Paint()..color = HuntColors.moss.withValues(alpha: 0.45);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.28), size.height * 0.76),
        6,
        pawPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PracticePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.tapped != tapped;
}
