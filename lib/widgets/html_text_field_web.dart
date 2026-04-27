// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HtmlTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final Color? cursorColor;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool? enabled;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const HtmlTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.cursorColor,
    this.textInputAction,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.enabled,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<HtmlTextField> createState() => _HtmlTextFieldState();
}

class _HtmlTextFieldState extends State<HtmlTextField> {
  static int _nextId = 0;

  late final String _viewType;
  late final String _cssClass;
  late html.HtmlElement _element;
  late html.StyleElement _styleElement;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  final List<StreamSubscription<html.Event>> _subscriptions = [];
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _isSyncingFromDom = false;
  double _fieldHeight = 20;

  bool get _enabled => widget.enabled ?? true;

  bool get _isMultiline =>
      !widget.obscureText && (widget.maxLines == null || widget.maxLines! > 1);

  @override
  void initState() {
    super.initState();
    final id = _nextId++;
    _viewType = 'live-app-html-text-field-$id';
    _cssClass = 'live-app-html-text-field-class-$id';
    _styleElement = html.StyleElement();
    html.document.head?.append(_styleElement);

    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;

    _element = _createElement();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _element,
    );

    _controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_handleFocusChanged);
    _attachDomListeners();
    _syncElementFromController();
    _applyElementConfiguration();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusElement());
    }
  }

  @override
  void didUpdateWidget(covariant HtmlTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
      _controller.addListener(_handleControllerChanged);
      _syncElementFromController();
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_handleFocusChanged);
    }

    _applyElementConfiguration();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _styleElement.remove();
    _element.remove();
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  html.HtmlElement _createElement() {
    final element = _isMultiline
        ? html.TextAreaElement()
        : html.InputElement(type: widget.obscureText ? 'password' : 'text');
    element.classes.add(_cssClass);
    element.setAttribute('autocomplete', 'off');
    element.setAttribute('autocorrect', 'off');
    element.setAttribute('autocapitalize', 'off');
    element.setAttribute('spellcheck', 'false');
    return element;
  }

  void _attachDomListeners() {
    _subscriptions
      ..add(_element.onInput.listen(_handleInput))
      ..add(
        _element.onFocus.listen((_) {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
          if (mounted) {
            setState(() {});
          }
        }),
      )
      ..add(
        _element.onBlur.listen((_) {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
          if (mounted) {
            setState(() {});
          }
        }),
      )
      ..add(_element.onClick.listen((_) => widget.onTap?.call()))
      ..add(_element.onKeyDown.listen(_handleKeyDown));
  }

  void _handleInput(html.Event event) {
    final oldValue = _controller.value;
    final rawText = _elementValue;
    final selectionOffset = _selectionStart(rawText.length);
    var newValue = TextEditingValue(
      text: rawText,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );

    for (final formatter in widget.inputFormatters ?? <TextInputFormatter>[]) {
      newValue = formatter.formatEditUpdate(oldValue, newValue);
    }

    _isSyncingFromDom = true;
    _controller.value = newValue;
    _isSyncingFromDom = false;

    if (newValue.text != rawText) {
      _setElementValue(newValue.text);
      _setSelection(newValue.selection.baseOffset);
    }

    widget.onChanged?.call(newValue.text);
    _syncHeight();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleKeyDown(html.Event event) {
    if (event is! html.KeyboardEvent || event.key != 'Enter') {
      return;
    }

    final shouldSubmit =
        !_isMultiline ||
        widget.textInputAction == TextInputAction.search ||
        widget.textInputAction == TextInputAction.done ||
        widget.textInputAction == TextInputAction.send;
    if (!shouldSubmit) {
      return;
    }

    event.preventDefault();
    widget.onSubmitted?.call(_controller.text);
  }

  void _handleControllerChanged() {
    if (_isSyncingFromDom) {
      return;
    }
    _syncElementFromController();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _focusElement();
    } else if (html.document.activeElement == _element) {
      _element.blur();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _focusElement() {
    if (!_enabled) {
      return;
    }
    _element.focus();
  }

  void _syncElementFromController() {
    _setElementValue(_controller.text);
    _setSelection(_controller.selection.baseOffset);
    _syncHeight();
  }

  void _applyElementConfiguration() {
    final placeholder = widget.decoration?.hintText ?? '';
    _element.setAttribute('placeholder', placeholder);
    _element.setAttribute('enterkeyhint', _enterKeyHint());
    if (_enabled) {
      _element.removeAttribute('disabled');
    } else {
      _element.setAttribute('disabled', 'disabled');
    }

    if (widget.maxLength == null) {
      _element.removeAttribute('maxlength');
    } else {
      _element.setAttribute('maxlength', widget.maxLength.toString());
    }

    if (_element is html.InputElement) {
      final input = _element as html.InputElement;
      input.type = widget.obscureText ? 'password' : 'text';
      input.setAttribute('inputmode', _inputMode());
    }

    if (_element is html.TextAreaElement) {
      final textarea = _element as html.TextAreaElement;
      textarea.rows = widget.maxLines ?? 1;
    }
  }

  void _applyStyles(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style;
    final textStyle = baseStyle.merge(widget.style);
    final fontSize = textStyle.fontSize ?? 16;
    final lineHeight = fontSize * 1.25;
    final textColor = textStyle.color ?? Colors.black;
    final cursorColor = widget.cursorColor ?? textColor;
    final hintColor =
        widget.decoration?.hintStyle?.color ??
        textColor.withValues(alpha: 0.54);

    _element.style
      ..width = '100%'
      ..height = '100%'
      ..boxSizing = 'border-box'
      ..padding = '0'
      ..margin = '0'
      ..border = '0'
      ..outline = 'none'
      ..backgroundColor = 'transparent'
      ..color = _cssColor(textColor)
      ..fontFamily =
          textStyle.fontFamily ??
          'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif'
      ..fontSize = '${fontSize}px'
      ..fontWeight = _cssFontWeight(textStyle.fontWeight)
      ..fontStyle = textStyle.fontStyle == FontStyle.italic
          ? 'italic'
          : 'normal'
      ..lineHeight = '${lineHeight}px'
      ..overflowX = 'hidden'
      ..overflowY = _isMultiline ? 'auto' : 'hidden'
      ..resize = 'none';
    _element.style.setProperty('caret-color', _cssColor(cursorColor));
    _element.style.setProperty('appearance', 'none');
    _element.style.setProperty('-webkit-appearance', 'none');
    _element.style.setProperty('box-shadow', 'none');

    _styleElement.text =
        '''
.$_cssClass::placeholder {
  color: ${_cssColor(hintColor)};
  opacity: 1;
}
.$_cssClass:disabled {
  opacity: 0.6;
}
''';

    final targetHeight = lineHeight.ceilToDouble();
    if ((_fieldHeight - targetHeight).abs() > 0.5 && !_isMultiline) {
      _fieldHeight = targetHeight;
    }
  }

  void _syncHeight() {
    if (!_isMultiline) {
      return;
    }

    final fontSize = widget.style?.fontSize ?? 16;
    final lineHeight = fontSize * 1.25;
    final minHeight = lineHeight.ceilToDouble();
    final maxHeight = lineHeight * 5;
    final scrollHeight = _element.scrollHeight.toDouble();
    final nextHeight = scrollHeight <= 0
        ? minHeight
        : scrollHeight.clamp(minHeight, maxHeight).toDouble();

    if ((_fieldHeight - nextHeight).abs() > 0.5) {
      _fieldHeight = nextHeight;
    }
  }

  String get _elementValue {
    if (_element is html.InputElement) {
      return (_element as html.InputElement).value ?? '';
    }
    if (_element is html.TextAreaElement) {
      return (_element as html.TextAreaElement).value ?? '';
    }
    return '';
  }

  void _setElementValue(String value) {
    if (_elementValue == value) {
      return;
    }
    if (_element is html.InputElement) {
      (_element as html.InputElement).value = value;
    } else if (_element is html.TextAreaElement) {
      (_element as html.TextAreaElement).value = value;
    }
  }

  int _selectionStart(int fallback) {
    final start = _element is html.InputElement
        ? (_element as html.InputElement).selectionStart
        : (_element as html.TextAreaElement).selectionStart;
    return (start ?? fallback).clamp(0, _elementValue.length);
  }

  void _setSelection(int offset) {
    if (offset < 0 || html.document.activeElement != _element) {
      return;
    }
    final safeOffset = offset.clamp(0, _elementValue.length);
    if (_element is html.InputElement) {
      (_element as html.InputElement).setSelectionRange(safeOffset, safeOffset);
    } else if (_element is html.TextAreaElement) {
      (_element as html.TextAreaElement).setSelectionRange(
        safeOffset,
        safeOffset,
      );
    }
  }

  String _inputMode() {
    final keyboardType = widget.keyboardType;
    if (keyboardType == TextInputType.number ||
        keyboardType == const TextInputType.numberWithOptions() ||
        keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
      return 'decimal';
    }
    if (keyboardType == TextInputType.emailAddress) {
      return 'email';
    }
    if (keyboardType == TextInputType.phone) {
      return 'tel';
    }
    if (keyboardType == TextInputType.url) {
      return 'url';
    }
    if (widget.textInputAction == TextInputAction.search) {
      return 'search';
    }
    return 'text';
  }

  String _enterKeyHint() {
    return switch (widget.textInputAction) {
      TextInputAction.search => 'search',
      TextInputAction.send => 'send',
      TextInputAction.done => 'done',
      TextInputAction.go => 'go',
      TextInputAction.next => 'next',
      _ => 'enter',
    };
  }

  String _cssFontWeight(FontWeight? weight) {
    if (weight == null) {
      return '400';
    }
    return weight.value.toString();
  }

  String _cssColor(Color color) {
    final argb = color.toARGB32();
    final a = ((argb >> 24) & 0xff) / 255;
    final r = (argb >> 16) & 0xff;
    final g = (argb >> 8) & 0xff;
    final b = argb & 0xff;
    return 'rgba($r, $g, $b, ${a.toStringAsFixed(3)})';
  }

  @override
  Widget build(BuildContext context) {
    _applyStyles(context);
    _applyElementConfiguration();

    final decoration = (widget.decoration ?? const InputDecoration()).copyWith(
      hintText: '',
      counterText: widget.decoration?.counterText ?? '',
      enabled: _enabled,
    );

    return InputDecorator(
      decoration: decoration,
      isFocused: _focusNode.hasFocus,
      isEmpty: _controller.text.isEmpty,
      child: SizedBox(
        height: _fieldHeight,
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
