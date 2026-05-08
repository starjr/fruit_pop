import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PopButtonVariant { primary, secondary, mint, ghost }

/// 눌리는 그림자 효과가 있는 메인 버튼.
class PopButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final PopButtonVariant variant;
  final double height;
  final double? width;
  final EdgeInsets padding;
  final double radius;
  final bool disabled;

  const PopButton({
    super.key,
    required this.child,
    this.onTap,
    this.variant = PopButtonVariant.primary,
    this.height = 52,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.radius = 999,
    this.disabled = false,
  });

  @override
  State<PopButton> createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled || widget.onTap == null;
    final config = _config(widget.variant);

    return GestureDetector(
      onTapDown: (_) { if (!disabled) setState(() => _down = true); },
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        height: widget.height,
        width: widget.width,
        padding: widget.padding,
        transform: Matrix4.translationValues(0, _down ? 2 : 0, 0),
        decoration: BoxDecoration(
          gradient: disabled ? null : config.gradient,
          color: disabled ? const Color(0xFFE8E0DC) : config.solid,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.variant == PopButtonVariant.ghost
              ? Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.2)
              : null,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: config.shadow,
                    offset: Offset(0, _down ? 2 : 4),
                    blurRadius: 0,
                  ),
                  if (config.glow != null)
                    BoxShadow(color: config.glow!, blurRadius: 12, offset: const Offset(0, 6)),
                ],
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: disabled ? AppColors.inkLight : config.textColor,
            fontWeight: FontWeight.w700,
            fontFamily: 'Pretendard',
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              color: disabled ? AppColors.inkLight : config.textColor,
              size: 20,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  _PopConfig _config(PopButtonVariant v) {
    switch (v) {
      case PopButtonVariant.primary:
        return _PopConfig(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.primaryTop, AppColors.primaryBot]),
          shadow: AppColors.primaryShadow,
          glow: AppColors.primaryTop.withValues(alpha: 0.3),
          textColor: Colors.white,
        );
      case PopButtonVariant.secondary:
        return _PopConfig(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.secondaryTop, AppColors.secondaryBot]),
          shadow: AppColors.secondaryShadow,
          textColor: AppColors.secondaryText,
        );
      case PopButtonVariant.mint:
        return _PopConfig(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.mintTop, AppColors.mintBot]),
          shadow: AppColors.mintShadow,
          textColor: AppColors.mintText,
        );
      case PopButtonVariant.ghost:
        return _PopConfig(
          solid: Colors.white.withValues(alpha: 0.7),
          shadow: Colors.black.withValues(alpha: 0.08),
          textColor: AppColors.ink,
        );
    }
  }
}

class _PopConfig {
  final LinearGradient? gradient;
  final Color? solid;
  final Color shadow;
  final Color? glow;
  final Color textColor;
  _PopConfig({this.gradient, this.solid, required this.shadow, this.glow, required this.textColor});
}

/// 부드러운 글래스 카드
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.radius = 18, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.candyPink.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 솔리드 흰색 카드
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  const WhiteCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.radius = 24, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}
