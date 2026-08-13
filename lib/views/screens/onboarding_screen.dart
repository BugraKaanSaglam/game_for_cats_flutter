import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              HuntSpacing.lg,
              HuntSpacing.md,
              HuntSpacing.lg,
              HuntSpacing.sm,
            ),
            child: HuntSurface(
              tone: HuntSurfaceTone.field,
              padding: const EdgeInsets.symmetric(
                horizontal: HuntSpacing.md,
                vertical: HuntSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.track_changes,
                    color: HuntColors.moss,
                    size: 28,
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
                        color: HuntColors.moss,
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
                _WelcomePage(l10n: l10n),
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
                            ? HuntColors.moss
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
                    label: last ? l10n.onboarding_start : l10n.onboarding_next,
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
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(HuntSpacing.lg),
      child: Center(
        child: HuntSurface(
          tone: HuntSurfaceTone.field,
          padding: const EdgeInsets.all(HuntSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 170, child: _FieldIllustration()),
              const SizedBox(height: HuntSpacing.xl),
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
                  onTap: () => setState(() => _tapped = true),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldIllustration extends StatelessWidget {
  const _FieldIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PracticePainter(progress: 0.2, tapped: false));
  }
}

class _PracticePainter extends CustomPainter {
  const _PracticePainter({required this.progress, required this.tapped});

  final double progress;
  final bool tapped;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = HuntColors.fieldLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)),
      line,
    );
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
    final pawPaint = Paint()..color = HuntColors.moss.withValues(alpha: 0.28);
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
