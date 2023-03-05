import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/string.dart';

class CustomTheme {
   final TextTheme _textTheme;

   CustomTheme(this._textTheme);

   TextTheme customFsTheme({double fontSize = 14}) {
      double scale = fontSize / baseFontSize;
      return TextTheme(
         displayLarge: updateFontSize(_textTheme.displayLarge!, scale),
         displayMedium: updateFontSize(_textTheme.displayMedium!, scale),
         displaySmall: updateFontSize(_textTheme.displaySmall!, scale),
         headlineLarge: updateFontSize(_textTheme.headlineLarge!, scale),
         headlineMedium: updateFontSize(_textTheme.headlineMedium!, scale),
         headlineSmall: updateFontSize(_textTheme.headlineSmall!, scale),
         titleLarge: updateFontSize(_textTheme.titleLarge!, scale),
         titleMedium: updateFontSize(_textTheme.titleMedium!, scale),
         titleSmall: updateFontSize(_textTheme.titleSmall!, scale),
         labelLarge: updateFontSize(_textTheme.labelLarge!, scale),
         labelMedium: updateFontSize(_textTheme.labelMedium!, scale),
         labelSmall: updateFontSize(_textTheme.labelSmall!, scale),
         bodyLarge: updateFontSize(_textTheme.bodyLarge!, scale),
         bodyMedium: updateFontSize(_textTheme.bodyMedium!, scale),
         bodySmall: updateFontSize(_textTheme.bodySmall!, scale),
      );
   }

   TextStyle updateFontSize(TextStyle textStyle, double scale) {
      return TextStyle(
          fontSize: textStyle.fontSize! * scale
      );
   }
}
