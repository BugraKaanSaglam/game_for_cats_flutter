import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

/// Full-screen first frame shown while the app decides between onboarding and
/// the main menu. It keeps Android 12+'s system splash transition seamless.
class StartupSplashView extends StatelessWidget {
  const StartupSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/splashscreen.png'),
          fit: BoxFit.cover,
          semanticLabel: 'Mice and Paws',
        ),
      ),
    );
  }
}

// * Temporary loading route shown while AppState initializes repositories and locale.
class LoadingScreenView extends StatelessWidget {
  const LoadingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return HuntCorePage(
      showAppBar: false,
      child: Center(
        child: HuntSurface(
          tone: HuntSurfaceTone.field,
          margin: const EdgeInsets.all(HuntSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: HuntColors.paper,
                  borderRadius: BorderRadius.circular(HuntRadii.lg),
                  border: Border.all(color: HuntColors.fieldLine),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          HuntColors.moss,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.track_changes_rounded,
                      color: HuntColors.terracotta,
                      size: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HuntSpacing.lg),
              Text(
                AppLocalizations.of(context)!.loading,
                style: HuntTextStyles.pageTitle,
              ),
              const SizedBox(height: HuntSpacing.xs),
              Text(
                AppLocalizations.of(context)!.game_name,
                style: HuntTextStyles.supporting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ! Convenience builder used by the Flame GameWidget loadingBuilder callback.
Widget loadingScreen(BuildContext context) => const LoadingScreenView();
