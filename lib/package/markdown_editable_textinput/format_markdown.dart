import 'dart:math';
import 'package:flutter/material.dart';

/// Use this class for converting String to [ResultMarkdown]
class FormatMarkdown {
  /// Convert [data] part into [ResultMarkdown] from [type].
  /// Use [fromIndex] and [toIndex] for converting part of [data]
  /// [titleSize] is used for markdown titles
  /// [link] is used for link conversion type
  static ResultMarkdown convertToMarkdown(
      MarkdownType type, String data, int fromIndex, int toIndex,
      {int titleSize = 1, String? link, String selectedText = ''}) {
    late String changedData;
    late int replaceCursorIndex;

    final lesserIndex = min(fromIndex, toIndex);
    final greaterIndex = max(fromIndex, toIndex);

    fromIndex = lesserIndex;
    toIndex = greaterIndex;

    switch (type) {
      case MarkdownType.bold:
        changedData = '**${data.substring(fromIndex, toIndex)}**';
        replaceCursorIndex = 2;
        break;
      case MarkdownType.italic:
        changedData = '_${data.substring(fromIndex, toIndex)}_';
        replaceCursorIndex = 1;
        break;
      case MarkdownType.strikethrough:
        changedData = '~~${data.substring(fromIndex, toIndex)}~~';
        replaceCursorIndex = 2;
        break;
      case MarkdownType.link:
        changedData = '[$selectedText](${link ?? selectedText})';
        replaceCursorIndex = 0;
        break;
      case MarkdownType.title:
        changedData =
            "${"#" * titleSize} ${data.substring(fromIndex, toIndex)}";
        replaceCursorIndex = 0;
        break;
      case MarkdownType.list:
        var index = 0;
        final splitedData = data.substring(fromIndex, toIndex).split('\n');
        changedData = splitedData.map((value) {
          index++;
          return index == splitedData.length ? '* $value' : '* $value\n';
        }).join();
        replaceCursorIndex = 0;
        break;
      case MarkdownType.code:
        changedData = '```${data.substring(fromIndex, toIndex)}```';
        replaceCursorIndex = 3;
        break;
      case MarkdownType.blockquote:
        var index = 0;
        final splitedData = data.substring(fromIndex, toIndex).split('\n');
        changedData = splitedData.map((value) {
          index++;
          return index == splitedData.length ? '> $value' : '> $value\n';
        }).join();
        replaceCursorIndex = 0;
        break;
      case MarkdownType.separator:
        changedData = '\n------\n${data.substring(fromIndex, toIndex)}';
        replaceCursorIndex = 0;
        break;
      case MarkdownType.image:
        if (link != '' && link != null) {
          changedData = '![$selectedText](${link ?? selectedText})';
          replaceCursorIndex = 0;
        } else {
          changedData =
              '![${data.substring(fromIndex, toIndex)}](${data.substring(fromIndex, toIndex)})';
          replaceCursorIndex = 3;
        }
        break;
    }

    final cursorIndex = changedData.length;

    return ResultMarkdown(
        data.substring(0, fromIndex) +
            changedData +
            data.substring(toIndex, data.length),
        cursorIndex,
        replaceCursorIndex);
  }
}

/// [ResultMarkdown] give you the converted [data] to markdown and the [cursorIndex]
class ResultMarkdown {
  /// String converted to mardown
  String data;

  /// cursor index just after the converted part in markdown
  int cursorIndex;

  /// index at which cursor need to be replaced if no text selected
  int replaceCursorIndex;

  /// Return [ResultMarkdown]
  ResultMarkdown(this.data, this.cursorIndex, this.replaceCursorIndex);
}

/// Represent markdown possible type to convert
enum MarkdownType {
  /// For **bold** text
  bold,

  /// For _italic_ text
  italic,

  /// For ~~strikethrough~~ text
  strikethrough,

  /// For [link](https://flutter.dev)
  link,

  /// For # Title or ## Title or ### Title
  title,

  /// For :
  ///   * Item 1
  ///   * Item 2
  ///   * Item 3
  list,

  /// For ```code``` text
  code,

  /// For :
  ///   > Item 1
  ///   > Item 2
  ///   > Item 3
  blockquote,

  /// For adding ------
  separator,

  /// For ![Alt text](link)
  image,
}

/// Add data to [MarkdownType] enum
extension MarkownTypeExtension on MarkdownType {
  /// Get String used in widget's key
  String get key {
    switch (this) {
      case MarkdownType.bold:
        return 'bold_button';
      case MarkdownType.italic:
        return 'italic_button';
      case MarkdownType.strikethrough:
        return 'strikethrough_button';
      case MarkdownType.link:
        return 'link_button';
      case MarkdownType.title:
        return 'H#_button';
      case MarkdownType.list:
        return 'list_button';
      case MarkdownType.code:
        return 'code_button';
      case MarkdownType.blockquote:
        return 'quote_button';
      case MarkdownType.separator:
        return 'separator_button';
      case MarkdownType.image:
        return 'image_button';
    }
  }

  /// Get Icon String
  IconData get icon {
    switch (this) {
      case MarkdownType.bold:
        return Icons.format_bold;
      case MarkdownType.italic:
        return Icons.format_italic;
      case MarkdownType.strikethrough:
        return Icons.format_strikethrough;
      case MarkdownType.link:
        return Icons.link;
      case MarkdownType.title:
        return Icons.text_fields;
      case MarkdownType.list:
        return Icons.list;
      case MarkdownType.code:
        return Icons.code;
      case MarkdownType.blockquote:
        return Icons.format_quote_rounded;
      case MarkdownType.separator:
        return Icons.minimize_rounded;
      case MarkdownType.image:
        return Icons.image_rounded;
    }
  }
}
