import 'package:flutter/material.dart';

class OkiStatefulBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, void Function([Duration?]) setState, State<OkiStatefulBuilder> state) builder;
  final void Function(void Function())? dispose;
  final void Function(void Function())? initialize;

  const OkiStatefulBuilder({
    super.key,
    required this.builder,
    this.dispose,
    this.initialize,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<OkiStatefulBuilder> {

  @override
  void initState() {
    super.initState();
    widget.initialize?.call(_setState);
  }

  @override
  void dispose() {
    widget.dispose?.call(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _setState, this);

  void _setState([Duration? delay]) {
    Future.delayed(delay ?? Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }
}