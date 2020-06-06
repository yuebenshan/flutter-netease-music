import 'package:flutter/material.dart';

extension OrientationContext on BuildContext {
  @deprecated
  NavigatorState get primaryNavigator => Navigator.of(this);

  @deprecated
  NavigatorState get secondaryNavigator => Navigator.of(this);

  ///
  /// check current application orientation is landscape.
  ///
  bool get isLandscape => MediaQuery.of(this).isLandscape;

  bool get isPortrait => !isLandscape;
}

extension _MediaData on MediaQueryData {
  bool get isLandscape => orientation == Orientation.landscape;
}
