import 'package:flutter/material.dart';

class Navigate {

  static Future<dynamic> push(BuildContext context, StatefulWidget widget, {
    bool fullscreenDialog = false,
    bool heroAnim = false,
    ChangeNotifier? provider,
  }) async {
    if (heroAnim) {
      return await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          fullscreenDialog: fullscreenDialog,
          pageBuilder: (context, anim, anim2) => widget,
        ),
      );
    }
    Offset offset = Offset(fullscreenDialog ? 0 : -1, fullscreenDialog ? 1 : 0);

    return await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: fullscreenDialog,
        pageBuilder: (context, anim, anim2) => SlideTransition(
          position: Tween<Offset>(begin: offset, end: Offset.zero).animate(anim),
          child: widget,
        ),
        transitionsBuilder: (context, anim, anim2, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  static pushReplacement(BuildContext context, StatefulWidget widget) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim, anim2) => FadeTransition(
          opacity: anim,
          child: widget,
        ),
      ),
    );

    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }

}