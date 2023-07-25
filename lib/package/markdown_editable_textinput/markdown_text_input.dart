import 'dart:io';
import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
// import 'package:translator/translator.dart';
import './format_markdown.dart';

/// Widget with markdown buttons
class MarkdownTextInput extends StatefulWidget {
  /// Optional decoration
  final Decoration? decoration;

  /// Callback called when text changed
  final Function onTextChanged;

  /// Initial value you want to display
  final String initialValue;

  /// Validator for the TextFormField
  final String? Function(String? value)? validators;

  /// String displayed at hintText in TextFormField
  final String? label;

  /// Change the text direction of the input (RTL / LTR)
  final TextDirection textDirection;

  /// The maximum of lines that can be display in the input
  final int? maxLines;

  /// List of action the component can handle
  final List<MarkdownType> actions;

  /// Optional controller to manage the input
  final TextEditingController? controller;

  /// Overrides input text style
  final TextStyle? textStyle;

  /// Optional actions
  final List<Widget> customActions;

  /// If you prefer to use the dialog to insert links, you can choose to use the markdown syntax directly by setting [insertLinksByDialog] to false. In this case, the selected text will be used as label and link.
  /// Default value is true.
  final bool insertLinksByDialog;

  /// Constructor for [MarkdownTextInput]
  MarkdownTextInput(this.onTextChanged, this.initialValue,
      {this.label = '',
      this.validators,
      this.textDirection = TextDirection.ltr,
      this.maxLines = 10,
      this.actions = const [
        MarkdownType.bold,
        MarkdownType.italic,
        MarkdownType.title,
        MarkdownType.link,
        MarkdownType.list
      ],
      this.textStyle,
      this.controller,
      this.insertLinksByDialog = true,
      this.decoration,
      this.customActions = const []});

  @override
  _MarkdownTextInputState createState() =>
      _MarkdownTextInputState(controller ?? TextEditingController());
}

class _MarkdownTextInputState extends State<MarkdownTextInput> {
  final TextEditingController _controller;
  TextSelection textSelection =
      const TextSelection(baseOffset: 0, extentOffset: 0);
  FocusNode focusNode = FocusNode();

  _MarkdownTextInputState(this._controller);

  void onTap(MarkdownType type,
      {int titleSize = 1, String? link, String? selectedText}) {
    final basePosition = textSelection.baseOffset;
    var noTextSelected =
        (textSelection.baseOffset - textSelection.extentOffset) == 0;

    var fromIndex = textSelection.baseOffset;
    var toIndex = textSelection.extentOffset;

    final result = FormatMarkdown.convertToMarkdown(
        type, _controller.text, fromIndex, toIndex,
        titleSize: titleSize,
        link: link,
        selectedText:
            selectedText ?? _controller.text.substring(fromIndex, toIndex));

    _controller.value = _controller.value.copyWith(
        text: result.data,
        selection:
            TextSelection.collapsed(offset: basePosition + result.cursorIndex));

    if (noTextSelected) {
      _controller.selection = TextSelection.collapsed(
          offset: _controller.selection.end - result.replaceCursorIndex);
      focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    _controller.text = widget.initialValue;
    _controller.addListener(() {
      if (_controller.selection.baseOffset != -1)
        textSelection = _controller.selection;
      widget.onTextChanged(_controller.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              focusNode: focusNode,
              textInputAction: TextInputAction.newline,
              maxLines: widget.maxLines,
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              validator: widget.validators != null
                  ? (value) => widget.validators!(value)
                  : null,
              style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,
              cursorColor: Theme.of(context).primaryColor,
              textDirection: widget.textDirection,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder:
                    const UnderlineInputBorder(borderSide: BorderSide.none),
                hintText: widget.label,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...widget.customActions,
                  ...widget.actions,
                ].map((type) {
                  if (type is Widget) {
                    return type;
                  } else {
                    switch (type) {
                      case MarkdownType.title:
                        return ExpandableNotifier(
                          child: Expandable(
                            key: const Key('H#_button'),
                            collapsed: ExpandableButton(
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(16, 10, 12, 10),
                                  child: Text(
                                    'H#',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            expanded: Center(
                              child: Row(
                                children: [
                                  for (int i = 1; i <= 6; i++)
                                    InkWell(
                                      key: Key('H${i}_button'),
                                      onTap: () => onTap(MarkdownType.title,
                                          titleSize: i),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'H$i',
                                          style: TextStyle(
                                              fontSize: (18 - i).toDouble(),
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ExpandableButton(
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.close,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      case MarkdownType.link:
                        return _basicInkwell(
                          type as MarkdownType,
                          customOnTap: !widget.insertLinksByDialog
                              ? null
                              : () async {
                                  var text = _controller.text.substring(
                                      textSelection.baseOffset,
                                      textSelection.extentOffset);

                                  var textController = TextEditingController()
                                    ..text = text;
                                  var linkController = TextEditingController();
                                  var textFocus = FocusNode();
                                  var linkFocus = FocusNode();

                                  var color =
                                      Theme.of(context).colorScheme.secondary;
                                  var language = kIsWeb
                                      ? window.locale.languageCode
                                      : Platform.localeName.substring(0, 2);

                                  var textLabel = 'Text';
                                  var linkLabel = 'Link';
                                  // try {
                                  //   var textTranslation =
                                  //       await GoogleTranslator()
                                  //           .translate(textLabel, to: language);
                                  //   textLabel = textTranslation.text;

                                  //   var linkTranslation =
                                  //       await GoogleTranslator()
                                  //           .translate(linkLabel, to: language);
                                  //   linkLabel = linkTranslation.text;
                                  // } catch (e) {
                                  //   textLabel = 'Text';
                                  //   linkLabel = 'Link';
                                  // }
                                  if (context.mounted) {}
                                  await showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('添加链接'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // const SizedBox(height: 15),
                                              TextField(
                                                controller: textController,
                                                decoration: InputDecoration(
                                                  hintText: 'example',
                                                  label: Text(textLabel),
                                                  labelStyle:
                                                      TextStyle(color: color),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: color,
                                                                  width: 2)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: color,
                                                                  width: 2)),
                                                ),
                                                autofocus: text.isEmpty,
                                                focusNode: textFocus,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onSubmitted: (value) {
                                                  textFocus.unfocus();
                                                  FocusScope.of(context)
                                                      .requestFocus(linkFocus);
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: linkController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'https://example.com',
                                                  label: Text(linkLabel),
                                                  labelStyle:
                                                      TextStyle(color: color),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: color,
                                                                  width: 2)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: color,
                                                                  width: 2)),
                                                ),
                                                autofocus: text.isNotEmpty,
                                                focusNode: linkFocus,
                                              ),
                                            ],
                                          ),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  24.0, 30.0, 24.0, 20),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                '取消',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                onTap(type,
                                                    link: linkController.text,
                                                    selectedText:
                                                        textController.text);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('确认'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                        );
                      case MarkdownType.image:
                        return InkWell(
                          key: Key((type as MarkdownType).key),
                          onTap: () => onTap(type),
                          onLongPress: () async {
                            final res = await Utils().uploadImage();
                            if (res is Map) {
                              onTap(
                                type,
                                link: res['link'],
                                selectedText: res['link'],
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Icon(type.icon),
                          ),
                        );
                      default:
                        return _basicInkwell(type as MarkdownType);
                    }
                  }
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _basicInkwell(MarkdownType type, {Function? customOnTap}) {
    return InkWell(
      key: Key(type.key),
      onTap: () => customOnTap != null ? customOnTap() : onTap(type),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Icon(type.icon),
      ),
    );
  }
}
