import 'package:flutter/material.dart';
import 'package:so_portfolio/theme/theme_app.dart';

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}

extension AppThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  ThemeColorExtension get appColors =>
      extension<ThemeColorExtension>() ?? ThemeModeColors.lightTheme;
}
