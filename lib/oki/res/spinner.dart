import 'dart:async';

import 'package:flutter/material.dart';

class Spinner<T> extends StatefulWidget {
  final T value;
  final List<T> values;
  final Axis direction;
  final TextStyle? style;
  final TextStyle? selectedTextStyle;
  final TextStyle? noSelectedTextStyle;
  final double height;
  final double? space;
  final Duration? timeAwait;
  final BoxDecoration? decoration;
  final void Function(T)? onChanged;
  final void Function(T)? onEnd;
  const Spinner({
    required this.values,
    required this.value,
    this.height = 50,
    this.decoration,
    this.direction = Axis.horizontal,
    this.space,
    this.timeAwait = const Duration(seconds: 1),
    this.onChanged,
    this.onEnd,
    this.style,
    this.noSelectedTextStyle,
    this.selectedTextStyle,
    super.key});

  @override
  State<StatefulWidget> createState() => _State<T>();
}
class _State<T> extends State<Spinner<T>> {

  List<T> get values => widget.values;
  int _currentPage = 0;

  PageController? _controller;

  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentPage = values.indexOf(widget.value);
    _controller = PageController(initialPage: _currentPage, viewportFraction: (widget.space ?? 20) / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: widget.decoration,
      child: PageView.builder(
        controller: _controller,
        scrollDirection: widget.direction,
        itemCount: values.length,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final T item = values[i];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Container(
                height: 35,
                color: Colors.transparent,
                child: Center(
                  child: Text(
                    item.toString(),
                    style: _style(i),
                  ),
                ),
              ),
              onTap: () => _onItemTap(item),
            ),
          );
        },
      ),
    );
  }

  TextStyle? _style(int page) {
    final style = widget.style ?? const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      shadows: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 10,
          offset: Offset(1, 1),
        ),
      ],
    );

    if (_currentPage == page) {
      return widget.selectedTextStyle ?? style.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: (style.fontSize ?? 16) + 4,
      );
    }
    return widget.noSelectedTextStyle ?? style.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
  }

  void _onPageChanged(int i) {
    _currentPage = i;
    if (values.isEmpty) {
      return;
    }
    widget.onChanged?.call(values[i]);

    if (widget.onEnd != null) {
      _timer?.cancel();
      _timer = Timer(widget.timeAwait ?? Duration.zero, () {
        if (_currentPage == i) {
          widget.onEnd?.call(values[i]);
        }
      });
    }
    setState(() {});
  }

  void _onItemTap(T item) {
    _controller?.animateToPage(
      values.indexOf(item),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }
}