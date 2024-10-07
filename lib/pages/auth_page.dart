import 'dart:io';
import 'package:flutter/material.dart';
import '../oki/import.dart';
import '../provider/import.dart';
import '../util/util.dart';

class AuthPage extends StatefulWidget {
  final String? _senha;
  final void Function(String)? onConfigure;
  final void Function()? onSuccess;
  final void Function()? onCancel;
  final bool readOnly;
  final bool canBack;
  const AuthPage(this._senha, {this.onConfigure, this.onSuccess,
    this.canBack = false, this.onCancel, this.readOnly = false, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AuthPage> {

  //region variaveis

  void Function()? get onSuccess => widget.onSuccess;
  void Function()? get onCancel => widget.onCancel;
  bool get readOnly => widget.readOnly;
  bool get canBack => widget.canBack;
  void Function(String)? get onConfigure => widget.onConfigure;

  AlbunsProvider get _albuns => AlbunsProvider.i;
  AuthManager get _auth => AuthManager.auth;

  final List<String> _senha = [];
  bool _senhaIncorreta = false;

  bool _authComSenha = false;

  // Post _post;
  String? _imageFundo;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var spacerG = const SizedBox(height: 60,);
    var spacerM = const SizedBox(height: 20,);
    var spacerP = const SizedBox(height: 10,);

    return PopScope(
      onPopInvoked: _willPop,
      canPop: canBack,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink,
                  Colors.deepPurple,
                ],
              ),
              image: _imageFundo != null ? DecorationImage(
                fit: BoxFit.cover,
                opacity: blurBloqueio,
                image: FileImage(File(_imageFundo ?? '')),
                // colorFilter: ColorFilter.mode(Colors.white, BlendMode.clear),
              ) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_authComSenha)...[

                  const OkiShadowText('Digite sua senha',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ), // APP_NAME

                  spacerM,

                  if (onConfigure != null)...[
                    OkiShadowText('configuração'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.cyanAccent,
                      ),
                    ), // configuração

                    spacerM,
                  ],

                  OkiShadowText(_senhaIncorreta ? 'Senha Incorreta'.toUpperCase() : '',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.deepOrangeAccent,
                    ),
                  ), // Senha Incorreta

                  spacerM,

                  SizedBox(
                    width: 290,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _senhaContainer(_senha.isNotEmpty),
                        _senhaContainer(_senha.length > 1),
                        _senhaContainer(_senha.length > 2),
                        _senhaContainer(_senha.length > 3),
                      ],
                    ),
                  ),  // * * * *

                  spacerM,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _button(1),
                      _button(2),
                      _button(3),
                    ],
                  ), // 1 2 3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _button(4),
                      _button(5),
                      _button(6),
                    ],
                  ), // 4 5 6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _button(7),
                      _button(8),
                      _button(9),
                    ],
                  ), // 7 8 9

                  spacerP,

                  SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _willPop(canBack),
                          child: const OkiShadowText(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 70
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.backspace),
                            onPressed: _onBackSpace,
                          ),
                        ),
                      ],
                    ),
                  ), // Cancelar

                  spacerG,
                ]
              ],
            ),
          ),
        )
    );
  }

  Widget _senhaContainer(bool b) {
    return OkiClipRRect(
      size: 15,
      borderSize: .5,
      // borderColor: Colors.transparent,
      color: b ? Colors.black38 : Colors.white,
      child: Container(),
    );
  }

  Widget _button(int value) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OkiClipRRect(
        color: Colors.transparent,
        borderColor: Colors.transparent,
        borderSize: 1,
        size: 70,
        child: GestureDetector(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Center(
              child: OkiShadowText(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          onTap: () => _onButtonClick(value),
        ),
      ),
    );
  }

  //endregion

  //region metodos

  void _willPop(bool value) async {
    onCancel?.call();
    if (value) {
      _pop();
    }
  }

  void _init() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // _post = _albuns.getRandomSavedPost(Rating.safe);
    final album = _albuns.getRandomAlbum();
    _imageFundo = album?.capa;
    if (_imageFundo != null && !File(_imageFundo ?? '').existsSync()) {
      _imageFundo = null;
    }
    setState(() {});

    if (!_auth.isAuthEnabled && onConfigure == null) {
      _willPop(canBack);
      return;
    }

    if (!readOnly && _auth.isSupported && _auth.isSystemEnabled) {
      bool result = await _auth.bioAuth();
      if (result) {
        onSuccess?.call();
        if (canBack) {
          _pop();
        }
        return;
      }
    }

    setState(() => _authComSenha = true);
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _onBackSpace() {
    if (_senha.isEmpty) return;
    setState(() {
      _senhaIncorreta = false;
      _senha.removeAt(_senha.length -1);
    });
  }

  void _onButtonClick(int value) {
    if (_senha.length >= 4) return;
    setState(() {
      _senhaIncorreta = false;
      _senha.add('$value');
    });

    if (!readOnly) {
      _verificar();
    }
  }

  void _verificar() {
    if (_senha.length < 4) return;

    if (onConfigure != null) {
      onConfigure?.call(_senha.join());
      if (canBack) {
        Navigator.pop(context);
      }
      return;
    }

    bool incorreto = false;

    var senha = widget._senha?.split('');

    incorreto = (senha![0] != _senha[0]) || (senha[1] != _senha[1]) || (senha[2] != _senha[2]) || (senha[3] != _senha[3]);

    if (incorreto) {
      setState(() {
        _senhaIncorreta = true;
        _senha.clear();
      });
      return;
    }

    onSuccess?.call();
    if (canBack) {
      Navigator.pop(context);
    }
  }

  //endregion

}
