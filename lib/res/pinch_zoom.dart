import 'package:flutter/material.dart';

class PinchZoom extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration resetDuration;
  final bool zoomEnabled;
  final void Function()? onTap;
  final void Function(double)? onZoom;
  final void Function(int)? onTouch;

  const PinchZoom({
    required this.child,
    this.resetDuration = const Duration(milliseconds: 100),
    this.maxScale = 3.0,
    this.zoomEnabled = true,
    this.onTap,
    this.onZoom,
    this.onTouch, super.key,
  });

  @override
  State createState() => _State();
}
class _State extends State<PinchZoom> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();

  static const _animationZoomSpeed = Duration(milliseconds: 200);

  bool get zoomEnabled => widget.zoomEnabled;

  TapDownDetails? _doubleTapDetails;
  double _currentZoom = 1;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: zoomEnabled ? _handleDoubleTapDown : null,
      onDoubleTap: zoomEnabled ? _handleDoubleTap : null,
      onTap: zoomEnabled ? widget.onTap : null,
      child: InteractiveViewer(
        minScale: 1.0,
        panEnabled: _currentZoom > 1,
        maxScale: widget.maxScale,
        scaleEnabled: zoomEnabled,
        transformationController: _transformationController,
        onInteractionEnd: _onInteractiveZoomEnd,
        child: widget.child,
      ),
    );
  }

  void _onInteractiveZoomEnd(ScaleEndDetails details) {
    _listenerZoom(esperar: false);
  }
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }
  void _handleDoubleTap() {
    Matrix4 begin = _transformationController.value;
    Matrix4 end;

    if (begin != Matrix4.identity()) {
      end = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition;

      end = Matrix4.identity()
        ..translate(-(position?.dx ?? 0) * (widget.maxScale - 1), -(position?.dy ?? 0) * (widget.maxScale - 1))
        ..scale(widget.maxScale);
    }

    AnimationController animationController = AnimationController(
      duration: _animationZoomSpeed,
      vsync: this,
    );
    animationController.addListener(() {
      Animation<Matrix4> animation = Matrix4Tween(begin: begin, end: end).animate(animationController);

      _transformationController.value = animation.value;
    });
    animationController.forward();
    _listenerZoom();
  }

  void _listenerZoom({bool esperar = true}) async {
    if (esperar) {
      await Future.delayed(_animationZoomSpeed);
    }

    final zoom = _transformationController.value.determinant();
    if (_currentZoom != zoom) {
      widget.onZoom?.call(zoom);
      _currentZoom = zoom;
      setState(() {});
    }
  }

}
