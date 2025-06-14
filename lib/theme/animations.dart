import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOut;

  static Widget fadeIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Offset offset = const Offset(0, 20),
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: offset, end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget scaleIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget combinedAnimation({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    Offset slideOffset = const Offset(0, 20),
    double scaleBegin = 0.8,
  }) {
    Widget animatedChild = child;
    
    if (fade) {
      animatedChild = fadeIn(
        child: animatedChild,
        duration: duration,
        curve: curve,
      );
    }
    
    if (slide) {
      animatedChild = slideIn(
        child: animatedChild,
        duration: duration,
        curve: curve,
        offset: slideOffset,
      );
    }
    
    if (scale) {
      animatedChild = scaleIn(
        child: animatedChild,
        duration: duration,
        curve: curve,
        begin: scaleBegin,
      );
    }
    
    return animatedChild;
  }
} 