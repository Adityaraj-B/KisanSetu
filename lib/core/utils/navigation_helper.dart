import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Custom Page Route - Smooth slide/fade transitions
/// Used for navigation between screens
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings? routeSettings;
  final bool slideFromRight;

  CustomPageRoute({
    required this.page,
    this.routeSettings,
    this.slideFromRight = true,
  }) : super(
          settings: routeSettings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppConstants.mediumAnimation,
          reverseTransitionDuration: AppConstants.mediumAnimation,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition
            final begin = Offset(slideFromRight ? 1.0 : -1.0, 0.0);
            const end = Offset.zero;
            final slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeInOutCubic),
            );
            final slideAnimation = animation.drive(slideTween);

            // Fade transition
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeIn),
            );
            final fadeAnimation = animation.drive(fadeTween);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom Fade Route - Simple fade transition
class CustomFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings? routeSettings;

  CustomFadeRoute({
    required this.page,
    this.routeSettings,
  }) : super(
          settings: routeSettings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppConstants.mediumAnimation,
          reverseTransitionDuration: AppConstants.shortAnimation,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        );
}

/// Navigation Helper - Simplifies navigation calls
class NavigationHelper {
  static void push(BuildContext context, Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(CustomPageRoute(page: page));
  }

  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      CustomPageRoute(page: page),
      (route) => false,
    );
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void pushFade(BuildContext context, Widget page) {
    Navigator.of(context).push(CustomFadeRoute(page: page));
  }
}
