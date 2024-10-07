import 'package:flutter/material.dart';
import 'package:moeboo/provider/import.dart';
import 'statefull_builder.dart';

class DialogBox extends ChangeNotifier {
  final BuildContext context;
  final String? title;
  final String auxBtnText;
  final bool dismissible;
  final List<Widget> content;
  final EdgeInsets contentPadding;
  final Function()? onDispose;
  DialogBox({
    required this.context,
    this.title,
    this.auxBtnText = '',
    this.dismissible = true,
    this.content = const [],
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.onDispose,
  });

  Future<DialogResult> none() async {
    return await _aux();
  }

  Future<DialogResult> simNao() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        negativeButton(idioma.nao),
        positiveButton(idioma.sim),
      ],
    );
  }
  Future<DialogResult> simNaoCancel() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        noneButton(idioma.cancelar),
        negativeButton(idioma.nao),
        positiveButton(idioma.sim),
      ],
    );
  }

  Future<DialogResult> cancelOK() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        negativeButton(idioma.cancelar),
        positiveButton('OK'),
      ],
    );
  }

  Future<DialogResult> ok() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        positiveButton('OK'),
      ],
    );
  }

  Future<DialogResult> close() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        noneButton(idioma.fechar),
      ],
    );
  }

  Future<DialogResult> cancel() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        negativeButton(idioma.cancelar),
      ],
    );
  }

  Future<DialogResult> _aux({List<Widget>? actions, bool dismissible = true}) async {
    /*OkiStatefulBuilder(
      dispose: onDispose,
      builder: (context, setState, state) {
        onBuilder?.call(setState);

        return AlertDialog(
          title: title == null ? null : Text(title ?? ''),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for(var item in content)
                  item,
                if (onNotShowAgain != null)
                  SwitchListTile(
                    title: Text(notShowAgainText),
                    value: _naoMostrarNovamente,
                    onChanged: (value) {
                      onNotShowAgain?.call(value);
                      setState.call(() => _naoMostrarNovamente = value);
                    },
                  ),
                // const Divider(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: actions ?? [],
                // )
              ],
            ),
          ),
          contentPadding: contentPadding,
          actions: actions,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30)
          ),
        );
      },
    );*/// backup

    return await showDialog<DialogResult>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return OkiStatefulBuilder(
          dispose: (_) => onDispose?.call(),
          builder: (context, setState, state) {
            return AlertDialog(
              title: title == null ? null : Text(title ?? ''),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: content,
                ),
              ),
              contentPadding: contentPadding,
              actions: actions,
              actionsAlignment: MainAxisAlignment.spaceBetween,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
              ),
            );
          },
        );
      },
    ) ?? DialogResult.none;
  }


  void update(int index, Widget newWidget) {
    content.removeAt(index);
    content.insert(index, newWidget);

    notifyListeners();
  }

  Widget noneButton(String text) =>
      TextButton(
        child: Text(text),
        onPressed: () => Navigator.pop(context, DialogResult.none),
      );

  Widget negativeButton(String text) =>
      TextButton(
        child: Text(text),
        onPressed: () => Navigator.pop(context, DialogResult.negative),
      );

  Widget positiveButton(String text) =>
      TextButton(
        child: Text(text),
        onPressed: () => Navigator.pop(context, DialogResult.positive),
      );
}

class DialogResult {
  static const int noneValue = -10;
  static const int positiveValue = 122;
  static const int negativeValue = 2252;

  final int value;
  DialogResult(this.value);

  static DialogResult get none => DialogResult(noneValue);
  static DialogResult get positive => DialogResult(positiveValue);
  static DialogResult get negative => DialogResult(negativeValue);

  bool get isPositive => value == positiveValue;
  bool get isNegative => value == negativeValue;
  bool get isNone => value == noneValue;
}

class DialogFullScreen {
  final BuildContext context;
  final bool showCloseButton;
  final Widget content;
  final MainAxisAlignment alignment;
  DialogFullScreen({required this.context, required this.content, this.alignment = MainAxisAlignment.start,
    this.showCloseButton = true});

  Future<dynamic> show() async {
    return await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) {
        return SizedBox.expand( // makes widget fullscreen
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                content,
                if (showCloseButton)...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: FloatingActionButton.extended(
                        label: const Text('FECHAR'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showPage() async {
    return await showGeneralDialog(
      context: context,
      // barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) {
        return content;
      },
    );
  }
}
