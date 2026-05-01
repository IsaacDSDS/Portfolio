import 'package:flutter/material.dart';

class ThemeColorExtension extends ThemeExtension<ThemeColorExtension> {
  const ThemeColorExtension({
    required this.windowHeaderColor,
    required this.headerTextColor,
    required this.windowBodyColor,
    required this.topBarTextColor,
    required this.borderColor,
    required this.shadowColor,
  });

  // ===== Window Header =======
  final Color windowHeaderColor;
  final Color headerTextColor;

  // ===== Window Body =======
  final Color windowBodyColor;

  // ===== Desktop Top Bar =====
  final Color topBarTextColor;

  // ===== Other =======
  final Color borderColor;
  final Color shadowColor;

  @override
  ThemeColorExtension copyWith({
    Color? windowHeaderColor,
    Color? windowBodyColor,
    Color? borderColor,
    Color? shadowColor,
    Color? headerTextColor,
    Color? topBarTextColor,
  }) {
    return ThemeColorExtension(
      windowHeaderColor: windowHeaderColor ?? this.windowHeaderColor,
      windowBodyColor: windowBodyColor ?? this.windowBodyColor,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      topBarTextColor: topBarTextColor ?? this.topBarTextColor,
    );
  }

  @override
  ThemeColorExtension lerp(ThemeColorExtension? other, double t) {
    if (other is! ThemeColorExtension) {
      return this;
    }
    return ThemeColorExtension(
      windowHeaderColor:
          Color.lerp(windowHeaderColor, other.windowHeaderColor, t) ??
          windowHeaderColor,
      windowBodyColor:
          Color.lerp(windowBodyColor, other.windowBodyColor, t) ??
          windowBodyColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      headerTextColor:
          Color.lerp(headerTextColor, other.headerTextColor, t) ??
          headerTextColor,
      topBarTextColor:
          Color.lerp(topBarTextColor, other.topBarTextColor, t) ??
          topBarTextColor,
    );
  }
}

class ThemeModeColors {
  static final light = ThemeData(
    extensions: [lightTheme],
    fontFamily: 'Roboto',
  );

  static final lightTheme = ThemeColorExtension(
    windowHeaderColor: Color(0xfffffdfa),
    windowBodyColor: Colors.white.withValues(alpha: .9),
    borderColor: Color(0xffede9e5),
    shadowColor: Color(0xff3b393f).withValues(alpha: .2),
    headerTextColor: Colors.black,
    topBarTextColor: Colors.white,
  );

  static final dark = ThemeData(extensions: [darkTheme], fontFamily: 'Roboto');

  static final darkTheme = ThemeColorExtension(
    windowHeaderColor: const Color(0xff25262d),
    windowBodyColor: const Color(0xff1a1a20).withValues(alpha: .9),
    borderColor: Color(0xff3b393f),
    shadowColor: Color(0xff3b393f),
    headerTextColor: Colors.white,
    topBarTextColor: Colors.white,
  );
}
