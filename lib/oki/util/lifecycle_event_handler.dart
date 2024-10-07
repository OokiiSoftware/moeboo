import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future Function()? onPause;
  final Future Function()? onResume;
  final Future Function()? onHidden;
  final Future Function()? onDetached;
  final Future Function()? onInactive;
  LifecycleEventHandler({
    this.onResume,
    this.onDetached,
    this.onPause,
    this.onInactive,
    this.onHidden,
  });


  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await onPause?.call();
        break;
      case AppLifecycleState.inactive:
        await onInactive?.call();
        break;
      case AppLifecycleState.detached:
        await onDetached?.call();
        break;
      case AppLifecycleState.resumed:
        await onResume?.call();
        break;
      case AppLifecycleState.hidden:
        await onHidden?.call();
        break;
    }

    if (kDebugMode) {
      print('didChangeAppLifecycleState $state');
    }
  }

}