import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/chat/screens/chat_screen.dart';

/// Animated Floating Chat Button - Premium Design
/// Shows chatbot icon when collapsed, expands to show name on hover/interaction
class AnimatedChatFAB extends StatefulWidget {
  final String languageCode;

  const AnimatedChatFAB({
    super.key,
    required this.languageCode,
  });

  @override
  State<AnimatedChatFAB> createState() => _AnimatedChatFABState();
}

class _AnimatedChatFABState extends State<AnimatedChatFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Auto-expand on first load to show the feature
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _expand();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _collapse();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _isExpanded = true;
      _controller.forward();
    });
  }

  void _collapse() {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }

  void _navigateToChat() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatbotName = widget.languageCode == 'hi' ? 'किसान मित्र' : 'Ask Kisan';
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Position above the nav bar (nav bar height ~80 + margin)
    final bottomPosition = bottomPadding + 100;

    return Positioned(
      right: 20,
      bottom: bottomPosition,
      child: GestureDetector(
        onTap: _navigateToChat,
        onLongPress: _isExpanded ? _collapse : _expand,
        child: MouseRegion(
          onEnter: (_) => _expand(),
          onExit: (_) => _collapse(),
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isExpanded ? 1.0 : _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E7D32),
                        Color(0xFF43A047),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Chat bot icon
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),

                            // Animated text
                            ClipRect(
                              child: SizeTransition(
                                sizeFactor: _expandAnimation,
                                axis: Axis.horizontal,
                                axisAlignment: -1,
                                child: FadeTransition(
                                  opacity: _expandAnimation,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      chatbotName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
