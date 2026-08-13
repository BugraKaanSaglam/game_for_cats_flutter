import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

/// Shared shell for every non-game screen.
///
/// Keeping the background, safe-area handling, and app bar in one place makes
/// each screen feel like part of the same product instead of a separate page.
class HuntCorePage extends StatelessWidget {
  const HuntCorePage({
    super.key,
    required this.child,
    this.title,
    this.hasBackButton = true,
    this.showAppBar = true,
  });

  final Widget child;
  final String? title;
  final bool hasBackButton;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: showAppBar,
      appBar: showAppBar && title != null
          ? MainAppBar(title: title!, hasBackButton: hasBackButton)
          : null,
      body: HuntPageBackground(child: SafeArea(child: child)),
    );
  }
}

/// Standard section header rendered inside a themed surface.
class HuntCoreHeader extends StatelessWidget {
  const HuntCoreHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.tone = HuntSurfaceTone.field,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final HuntSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    return HuntSurface(
      tone: tone,
      child: HuntSectionHeading(
        eyebrow: eyebrow,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}

/// Shared loading state used by screens that depend on local repositories.
class HuntLoadingState extends StatelessWidget {
  const HuntLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(HuntColors.moss),
      ),
    );
  }
}

/// Shared empty/error state with one clear recovery action.
class HuntStateCard extends StatelessWidget {
  const HuntStateCard({
    super.key,
    required this.title,
    this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.info_outline_rounded,
  });

  final String title;
  final String? message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HuntSurface(
        margin: const EdgeInsets.all(HuntSpacing.lg),
        tone: HuntSurfaceTone.field,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: HuntColors.moss, size: 38),
            const SizedBox(height: HuntSpacing.md),
            Text(title, style: HuntTextStyles.sectionTitle),
            if (message != null) ...[
              const SizedBox(height: HuntSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: HuntTextStyles.supporting,
              ),
            ],
            const SizedBox(height: HuntSpacing.md),
            HuntActionButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

/// Constrains long-form content without duplicating page-width boilerplate.
class HuntCoreViewport extends StatelessWidget {
  const HuntCoreViewport({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.all(HuntSpacing.lg),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Shared background stack used by every non-game route.
class HuntPageBackground extends StatelessWidget {
  const HuntPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/mainscreen_background.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          semanticLabel: 'Mice and Paws',
        ),
        ColoredBox(color: HuntColors.night.withValues(alpha: 0.24)),
        child,
      ],
    );
  }
}

/// Reusable themed card with consistent spacing, border, and elevation.
class HuntSurface extends StatelessWidget {
  const HuntSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(HuntSpacing.lg),
    this.margin,
    this.tone = HuntSurfaceTone.paper,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final HuntSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    final background = switch (tone) {
      HuntSurfaceTone.paper => HuntColors.paper,
      HuntSurfaceTone.ink => HuntColors.ink,
      HuntSurfaceTone.field => HuntColors.field,
      HuntSurfaceTone.accent => HuntColors.sun,
    };
    final border = switch (tone) {
      HuntSurfaceTone.paper => HuntColors.line,
      HuntSurfaceTone.ink => HuntColors.inkSoft,
      HuntSurfaceTone.field => HuntColors.fieldLine,
      HuntSurfaceTone.accent => HuntColors.sunLine,
    };
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(HuntRadii.lg),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: HuntColors.ink.withValues(
              alpha: tone == HuntSurfaceTone.ink ? 0.2 : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum HuntSurfaceTone { paper, ink, field, accent }

/// Primary action control with shared semantics and press feedback.
class HuntActionButton extends StatefulWidget {
  const HuntActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool expand;

  @override
  State<HuntActionButton> createState() => _HuntActionButtonState();
}

class _HuntActionButtonState extends State<HuntActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final background = widget.secondary ? HuntColors.paper : HuntColors.ink;
    final foreground = widget.secondary ? HuntColors.ink : HuntColors.paper;
    final button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: HuntMotion.tap,
          child: AnimatedContainer(
            duration: HuntMotion.tap,
            padding: const EdgeInsets.symmetric(
              horizontal: HuntSpacing.md,
              vertical: HuntSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: enabled ? background : HuntColors.line,
              borderRadius: BorderRadius.circular(HuntRadii.md),
              border: Border.all(
                color: widget.secondary ? HuntColors.lineStrong : background,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: foreground, size: 19),
                    const SizedBox(width: HuntSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: HuntTextStyles.action.copyWith(color: foreground),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Branded menu button for the main navigation grid.
///
/// Keeping this variant in the shared UI layer prevents the home screen from
/// owning a second button implementation with different touch behavior.
class HuntMenuButton extends StatelessWidget {
  const HuntMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.foreground = HuntColors.paper,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foreground;
  final bool large;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HuntRadii.lg);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: color,
        borderRadius: radius,
        elevation: 5,
        shadowColor: Colors.black45,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: large ? 68 : 58,
            child: ClipRRect(
              borderRadius: radius,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HuntSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: foreground, size: large ? 30 : 23),
                      const SizedBox(width: HuntSpacing.sm),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: HuntTextStyles.action.copyWith(
                            color: foreground,
                            fontSize: large ? 19 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum HuntSnackBarTone { success, info, warning }

void showHuntSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_outline_rounded,
  HuntSnackBarTone tone = HuntSnackBarTone.success,
}) {
  final color = switch (tone) {
    HuntSnackBarTone.success => HuntColors.mossDark,
    HuntSnackBarTone.info => HuntColors.royalBlueDark,
    HuntSnackBarTone.warning => HuntColors.terracotta,
  };
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        elevation: 8,
        margin: const EdgeInsets.fromLTRB(
          HuntSpacing.md,
          0,
          HuntSpacing.md,
          HuntSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HuntRadii.md),
          side: BorderSide(color: HuntColors.sun.withValues(alpha: 0.7)),
        ),
        content: Row(
          children: [
            Icon(icon, color: HuntColors.sun),
            const SizedBox(width: HuntSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: HuntTextStyles.supporting.copyWith(
                  color: HuntColors.paper,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

class HuntMetric extends StatelessWidget {
  const HuntMetric({
    super.key,
    required this.label,
    required this.value,
    this.accent = HuntColors.ink,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HuntSpacing.sm,
          vertical: HuntSpacing.md,
        ),
        decoration: BoxDecoration(
          color: HuntColors.paperWarm,
          borderRadius: BorderRadius.circular(HuntRadii.md),
          border: Border.all(color: HuntColors.line),
        ),
        child: Column(
          children: [
            Text(value, style: HuntTextStyles.metric.copyWith(color: accent)),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: HuntTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class HuntSectionHeading extends StatelessWidget {
  const HuntSectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: HuntTextStyles.eyebrow),
              const SizedBox(height: HuntSpacing.xs),
              Text(title, style: HuntTextStyles.pageTitle),
              if (subtitle != null) ...[
                const SizedBox(height: HuntSpacing.xs),
                Text(subtitle!, style: HuntTextStyles.supporting),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class HuntTag extends StatelessWidget {
  const HuntTag({
    super.key,
    required this.label,
    this.icon,
    this.tone = HuntTagTone.neutral,
  });

  final String label;
  final IconData? icon;
  final HuntTagTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      HuntTagTone.neutral => HuntColors.inkSoft,
      HuntTagTone.success => HuntColors.moss,
      HuntTagTone.warning => HuntColors.terracotta,
      HuntTagTone.accent => HuntColors.coral,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(HuntRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(label, style: HuntTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

enum HuntTagTone { neutral, success, warning, accent }
