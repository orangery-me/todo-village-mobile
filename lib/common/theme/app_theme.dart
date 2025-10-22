import 'package:flutter/material.dart';
import 'package:todo_village_mobile/common/theme/palette.dart';
import 'package:todo_village_mobile/common/theme/text_styles.dart';
import 'package:todo_village_mobile/generated/fonts.gen.dart';

class ThemeSheet {
  final ThemeData themeData;
  final Palette palette;
  final AppTextStyles textStyles;

  ThemeSheet({required this.palette, required this.textStyles})
    : themeData = ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        brightness: palette.brightness,
        fontFamily: FontFamily.mulish,
        scaffoldBackgroundColor: palette.scaffoldBackground,
        extensions: [palette, textStyles],
      );
}
