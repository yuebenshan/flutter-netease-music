import 'package:flutter/material.dart';

/// Quiet Application [BuildContext] extension
extension QuietBuildContextExt on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  NavigatorState get rootNavigator => Navigator.of(this, rootNavigator: true);
}
