import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../import.dart';

class OkiDropDown extends StatelessWidget {
  final List<String> items;
  final Function(String?) onChanged;
  final String? text;
  final String? info;
  final String value;
  final bool vertical;
  const OkiDropDown({this.text, required this.items, this.info, this.vertical = false,
    required this.onChanged, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> temp = [];
    for (String value in items) {
      temp.add(DropdownMenuItem(value: value, child: Text(value)));
    }

    Widget drops = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: DropdownButton(
        value: value,
        disabledHint: Text(value),
        items: temp,
        onChanged: onChanged,
      ),
    );

    return ListTile(
      title: text == null ? null : Text(text ?? ''),
      subtitle: vertical ? drops : info == null ? null : Text(info ?? ''),
      trailing: vertical ? info == null ? null : Text(info ?? '') : drops,
    );
  }
}

class OkiTextField extends StatelessWidget {
  final String? preText;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final Widget? icon;
  final bool textIsEmpty;
  final bool isPassword;
  final bool readOnly;
  final bool circularBorder;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int maxLines;
  final Color? color;
  final double? elevation;
  final FocusNode? focus;
  final TextStyle? style;
  final TextType? textInputType;
  final EdgeInsets? padding;
  final TextInputAction? action;
  final List<TextInputFormatter>? formatters;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSave;

  const OkiTextField({
    this.preText,
    this.initialValue,
    this.controller,
    this.hint,
    this.icon,
    this.color,
    this.elevation,
    this.circularBorder = false,
    this.textIsEmpty = false,
    this.isPassword = false,
    this.readOnly = false,
    this.textInputType,
    this.maxLines = 1,
    this.formatters,
    this.padding,
    this.focus,
    this.style,
    this.action,
    this.onTap,
    this.onChanged,
    this.validator,
    this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 50.0;

    final border = circularBorder ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: style?.color?.withOpacity(0.2) ?? Colors.black38,
      ),
    ) : const UnderlineInputBorder();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (elevation != null)
            BoxShadow(
              blurRadius: elevation ?? 0,
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        minLines: 1,
        focusNode: focus,
        initialValue: initialValue,
        readOnly: readOnly,
        obscureText: isPassword,
        style: style,
        textInputAction: action,
        keyboardType: textInputType?.textInputType,
        inputFormatters: textInputType?.inputFormatters,
        onTap: onTap,
        onChanged: onChanged,
        validator: validator,
        onSaved: onSave,
        cursorColor: Colors.pink,
        decoration: InputDecoration(
          labelText: hint,
          suffixIcon: icon,
          prefixIcon: preText != null? Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text('$preText: ', style: style?.copyWith(
              color: style?.color?.withAlpha(120),
            ),
            ),
          ) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          fillColor: color,
          filled: color != null,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: border.borderSide.copyWith(
              color: Colors.pink,
            ),
          ),
          disabledBorder: border,
          errorBorder: border.copyWith(
            borderSide: border.borderSide.copyWith(
              color: Colors.red,
            ),
          ),
          border: border,
          focusedErrorBorder: border,
          labelStyle: style?.copyWith(
            color: style?.color?.withAlpha(120),
          ),
        ),
      ),
    );
  }

  bool get textNotEnpity {
    return (initialValue != null && (initialValue?.isNotEmpty ?? false)) || (controller?.text.isNotEmpty ?? false);
  }
}

class OkiTextField2 extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Widget? icon;
  final bool textIsEmpty;
  final bool isPassword;
  final void Function()? onTap;
  final int maxLines;
  final TextType? textInputType;

  const OkiTextField2({
    this.hint,
    this.controller,
    this.icon,
    this.textIsEmpty = false,
    this.isPassword = false,
    this.textInputType,
    this.maxLines = 1,
    this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      obscureText: isPassword,
      keyboardType: textInputType?.textInputType,
      // style: Styles.normalText,
      decoration: InputDecoration(
          suffixIcon: icon,
          labelText: hint,
          labelStyle: const TextStyle(/*color: textIsEmpty ? OkiTheme.textError : OkiTheme.text*/)
      ),
      onTap: onTap,
    );
  }
}

class OkiTextFieldSugestion extends StatefulWidget {
  final String? hint;
  final String? label;
  final Widget? icon;
  final int? maxLines;
  final bool textIsEmpty;
  final TextEditingController? controller;
  final TextType? textInputType;
  final FocusNode? focus;
  final Duration? timeAwait;
  final List<String>? sugestoes;
  final void Function()? onTap;
  final Function(String suggestion)? onChanged;
  final Future<List<String>>Function(String) suggestionsCallback;

  const OkiTextFieldSugestion({
    this.hint,
    this.label,
    this.controller,
    this.icon,
    this.focus,
    this.textIsEmpty = false,
    this.textInputType,
    this.maxLines = 1,
    this.onTap,
    this.sugestoes = const <String>[],
    this.timeAwait = Duration.zero,
    this.onChanged,
    required this.suggestionsCallback, super.key});

  @override
  State<StatefulWidget> createState() => _OkiTextFieldSugestionState();

}
class _OkiTextFieldSugestionState extends State<OkiTextFieldSugestion> {

  String _currentText = '';

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    var styleLabel = const TextStyle(/*color: textIsEmpty ? OkiTheme.textError : OkiTheme.text*/);
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      minLines: 1,
      focusNode: widget.focus,
      inputFormatters: widget.textInputType?.inputFormatters,
      keyboardType: widget.textInputType?.textInputType,
      onChanged: _onChanged,
      decoration: InputDecoration(
        suffixIcon: widget.icon,
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: styleLabel,
      ),
      onTap: widget.onTap,
    );
  }

  void _onChanged(String value) async {
    _currentText = value;
    widget.onChanged?.call(value);

    timer?.cancel();
    timer = Timer(widget.timeAwait ?? Duration.zero, () {
      if (_currentText == value) {
        // Log.d('Layouts', 'OkiTextFieldSugestion', value, currentText);
        widget.suggestionsCallback(value);
      }
    });
  }
}

class OkiShadowText extends StatelessWidget {
  final int maxLines;
  final bool center;
  final String text;
  final TextStyle? style;

  const OkiShadowText(this.text, {this.style, this.maxLines = 1, this.center = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      maxLines: maxLines,
      textAlign: center ? TextAlign.center : null,
      style: (style ?? const TextStyle()).copyWith(
        shadows: [
          const BoxShadow(
            blurRadius: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

class OkiClipRRect extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;
  final Color borderColor;
  final double borderSize;
  final double size;
  final double elevation;
  const OkiClipRRect({required this.child, this.radius = 50, this.elevation = 0, this.size = 50, this.borderSize = 0,
    this.color = const Color(-1), this.borderColor = const Color(0xff000000), super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            blurRadius: borderSize,
            spreadRadius: borderSize,
          ),

          if (elevation != 0)
            BoxShadow(
              color: borderColor,
              blurRadius: elevation,
              // spreadRadius: borderSize,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class OkiBottomSheet extends StatelessWidget {
  final List<Widget> children;
  const OkiBottomSheet({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: children,
        ),
      ),
    );
  }
}

class BottomSheetItem extends StatelessWidget {
  final IconData? icon;
  final void Function()? onPressed;
  final String? tooltip;
  const BottomSheetItem({this.icon, this.tooltip, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}


class PersistentBottomSheet {
  final Widget child;
  final void Function()? onClose;
  final void Function()? onShow;
  final BuildContext context;
  final Color? backgroundColor;
  final double blur;
  PersistentBottomSheet({required this.context, required this.child, this.onShow, this.onClose, this.blur = 0, this.backgroundColor});

  void show() async {
    onShow?.call();
    await showModalBottomSheet(
      context: context,
      // elevation: 25,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(child: child,);
      },
    );
    onClose?.call();
  }
}
