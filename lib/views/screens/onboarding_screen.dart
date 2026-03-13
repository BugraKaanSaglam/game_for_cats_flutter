import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/animated_gradient_background.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

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

  Future<void> _completeOnboarding() async {
    await context.read<AppState>().completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = <_OnboardingPageData>[
      _OnboardingPageData(
        title: l10n.onboarding_title_welcome,
        subtitle: l10n.onboarding_subtitle_welcome,
        icon: Icons.pets,
        accent: PawPalette.pinkToOrange(),
      ),
      _OnboardingPageData(
        title: l10n.onboarding_title_play,
        subtitle: l10n.onboarding_subtitle_play,
        icon: Icons.touch_app_outlined,
        accent: PawPalette.tealToLemon(),
      ),
      _OnboardingPageData(
        title: l10n.onboarding_title_track,
        subtitle: l10n.onboarding_subtitle_track,
        icon: Icons.insights_outlined,
        accent: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      ),
    ];

    final isLastPage = _pageIndex == pages.length - 1;

    return Scaffold(
      body: AnimatedGradientBackground(
        overlayOpacity: 0.12,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: PawPalette.pinkToOrange(),
                        ),
                      ),
                      child: const Icon(Icons.pets, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.game_name,
                        style: PawTextStyles.heading.copyWith(fontSize: 20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AppAnalytics.track(AnalyticsEvent.onboardingSkipped);
                        _completeOnboarding();
                      },
                      child: Text(
                        l10n.onboarding_skip,
                        style: PawTextStyles.cardSubtitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  itemBuilder: (context, index) =>
                      _OnboardingPage(data: pages[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _DotsIndicator(
                          count: pages.length,
                          activeIndex: _pageIndex,
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _GradientButton(
                      fullWidth: true,
                      label: isLastPage
                          ? l10n.onboarding_start
                          : l10n.onboarding_next,
                      gradient: PawPalette.pinkToOrange(),
                      onPressed: () async {
                        if (isLastPage) {
                          await _completeOnboarding();
                          return;
                        }
                        AppAnalytics.track(
                          AnalyticsEvent.onboardingNextTapped,
                          parameters: <String, Object?>{
                            'pageIndex': _pageIndex,
                          },
                        );
                        await _controller.nextPage(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                        );
                      },
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 178,
                    height: 178,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: data.accent),
                      boxShadow: [
                        BoxShadow(
                          color: data.accent.first.withValues(alpha: 0.32),
                          blurRadius: 28,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 64),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: PawTextStyles.heading.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 12),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: PawTextStyles.subheading.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: isActive ? 28 : 8,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFFF5D8F)],
                  )
                : null,
            color: isActive ? null : Colors.white54,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    this.fullWidth = false,
  });

  final String label;
  final List<Color> gradient;
  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> accent;
}
