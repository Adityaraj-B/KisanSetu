import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium gradient button with tap animation
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  static const List<Color> _defaultGradient = [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? _defaultGradient;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null && !widget.isLoading) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onPressed != null && !widget.isLoading) {
          HapticFeedback.mediumImpact();
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isLoading
                  ? gradient.map((c) => c.withValues(alpha :0.6)).toList()
                  : gradient,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha :_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary outline button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? const Color(0xFF2E7D32);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: buttonColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: buttonColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon button with container background
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? const Color(0xFF2E7D32);
    final bgColor = backgroundColor ?? iconColor.withValues(alpha :0.1);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}

