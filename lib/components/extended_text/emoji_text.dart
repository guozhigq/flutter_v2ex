import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/string.dart';

///emoji/image text
class EmojiText extends SpecialText {
  EmojiText(TextStyle? textStyle, {this.start})
      : super(EmojiText.flag, ']', textStyle);
  static const String flag = '[';
  final int? start;
  @override
  InlineSpan finishText() {
    final String key = toString();

    if (EmojiUitl.instance.emojiMap.containsKey(key)) {
      double size = 22;

      // final TextStyle ts = textStyle!;
      // if (ts.fontSize != null) {
      //   size = ts.fontSize! * 1.15;
      // }

      return ImageSpan(
          NetworkImage(
            EmojiUitl.instance.emojiMap[key]!,
          ),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start!,
          //fit: BoxFit.fill,
          margin: const EdgeInsets.all(1));
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class EmojiUitl {
  final coolapkEmoticon = Strings.coolapkEmoticon;
  EmojiUitl._() {
    for (int i = 0; i < coolapkEmoticon.values.toList().length; i++) {
      _emojiMap['[${coolapkEmoticon.keys.toList()[i]}]'] =
          coolapkEmoticon.values.toList()[i];
    }
  }

  final Map<String, String> _emojiMap = <String, String>{};

  Map<String, String> get emojiMap => _emojiMap;

  // final String _emojiFilePath = 'https://i.imgur.com/';

  static EmojiUitl? _instance;
  static EmojiUitl get instance => _instance ??= EmojiUitl._();
}
