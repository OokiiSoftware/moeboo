import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../res/import.dart';
import '../util/util.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../oki/import.dart';
import 'import.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ConfigPage> {

  //region variaveis

  AuthManager get _auth => AuthManager.auth;
  BooruProvider get _booruMng => BooruProvider.i;

  static bool _segurancaOptionsOpened = false;
  static bool _debugOptionsOpened = false;
  static bool _layoutOptionsOpened = false;

  double _blurBloqueio = blurBloqueio;

  late IdiomaProvider idiomaProvider;

  ILanguage get ui => idioma;

  //endregion

  //region overrides

  @override
  void dispose() {
    if (_booruMng.rating.isEmpty) {
      _booruMng.rating.add(Rating.safeValue);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    idiomaProvider = context.watch<IdiomaProvider>();
    final query = MediaQuery.of(context);
    final isPortrait = query.orientation == Orientation.portrait;

    bool isAuthEnabled = _auth.isAuthEnabled;
    bool isAuthenticated = _auth.isAuthenticated;
    bool showEchiOptions = !isPlayStory && isAuthenticated;

    final rating = _booruMng.rating;

    Widget? title(String text, bool showText) {
      if (showText) {
        return Text(text);
      }
      return null;
    }

    final layoutOptions = [
      ListTile(
        title: ToggleButtons(
          isSelected: <bool>[albunsLatoyt == 0, albunsLatoyt == 1],
          onPressed: (i) {
            setState(() {
              albunsLatoyt = i;
            });
          },
          children: const [
            Icon(Icons.grid_view, size: 80,),
            Icon(Icons.view_quilt_rounded, size: 80,),
          ],
        ),
        leading: title(idiomaWatch(context).albuns, isPortrait),
        subtitle: title(idiomaWatch(context).albuns, !isPortrait),
      ),
      ListTile(
        title: ToggleButtons(
          isSelected: <bool>[postsLatoyt == 0, postsLatoyt == 1],
          onPressed: (i) {
            setState(() {
              postsLatoyt = i;
            });
          },
          children: const [
            Icon(Icons.grid_view, size: 80,),
            Icon(Icons.view_quilt_rounded, size: 80,),
          ],
        ),
        leading: title(idiomaWatch(context).posts, isPortrait),
        subtitle: title(idiomaWatch(context).posts, !isPortrait),
      ),
      SwitchListTile(
        title: title(idiomaWatch(context).usarPaginas, isPortrait),
        subtitle: title(idiomaWatch(context).usarPaginas, !isPortrait),
        value: usePage,
        onChanged: (value) {
          usePage = value;
          setState(() {});
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(idiomaWatch(context).titleConfigPage),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 60),
        children: [
          Card(
            child: ExpansionTile(
              title: Text(idiomaWatch(context).provedores),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for(int i = 0; i < Boorus.list.length ~/ 2; i++)
                            RadioListTile<String>(
                              title: Text(Boorus.list[i].name),
                              secondary: Boorus.list[i].isPersonalizado ?
                              IconButton(
                                tooltip: idiomaWatch(context).editar,
                                onPressed: () => _onAddBooruClick(Boorus.list[i]),
                                icon: const Icon(Icons.edit),
                              ) : null,
                              value: Boorus.list[i].name,
                              groupValue: currentBooru,
                              onChanged: (String? value) {
                                _booruMng.setBooruFromName(value!);
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          for(int i = Boorus.list.length ~/ 2; i < Boorus.list.length; i++)
                            RadioListTile<String>(
                              title: Text(Boorus.list[i].name),
                              secondary: Boorus.list[i].isPersonalizado ?
                              IconButton(
                                tooltip: idiomaWatch(context).editar,
                                onPressed: () => _onAddBooruClick(Boorus.list[i]),
                                icon: const Icon(Icons.edit),
                              ) : null,
                              value: Boorus.list[i].name,
                              groupValue: currentBooru,
                              onChanged: (String? value) {
                                _booruMng.setBooruFromName(value!);
                                setState(() {});
                              },
                            ),

                          ListTile(
                            title: Text(idiomaWatch(context).adicionar),
                            trailing: const Icon(Icons.edit),
                            onTap: _onAddBooruClick,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),   // Proverodes

          if (showEchiOptions)
            Card(
              child: ExpansionTile(
                title: const Text('Maturidade'),
                children: [
                  CheckboxListTile(
                    title: const Text(Rating.safeValue),
                    subtitle: const Text('Nada sexualizado ou inapropriado para ver na frente dos outros.'),
                    value: rating.contains(Rating.safeValue),
                    onChanged: (value) => _onRatingChanged(value, Rating.safeValue),
                  ),
                  CheckboxListTile(
                    title: const Text(Rating.questionableValue),
                    subtitle: const Text('Nudez simples ou quase nudez, mas sem sexo explícito ou genitais expostos.'),
                    value: rating.contains(Rating.questionableValue),
                    onChanged: (value) => _onRatingChanged(value, Rating.questionableValue),
                  ),
                  CheckboxListTile(
                    title: const Text(Rating.explicitValue),
                    subtitle: const Text('Atos sexuais explícitos, genitais e fluidos corporais.'),
                    value: rating.contains(Rating.explicitValue),
                    onChanged: (value) => _onRatingChanged(value, Rating.explicitValue),
                  ),

                  const Divider(),

                  SwitchListTile(
                    title: const Text('Capa de Albuns Safe'),
                    subtitle: const Text('Usar somente Posts \'Safe\' como capa de albuns'),
                    value: useOnlySafeAsCapa,
                    onChanged: _onSetOnlySafeAsCapaChanged,
                  ),  // Capa dos albuns
                ],
              ),
            ),  // Maturidade

          const Divider(),

          if (!isPlayStory)
            Card(
              child: ExpansionTile(
                title: const Text('Segurança'),
                initiallyExpanded: _segurancaOptionsOpened,
                onExpansionChanged: (value) => _segurancaOptionsOpened = value,
                children: [
                  SwitchListTile(
                    title: const Text('Habilitar Autenticação'),
                    value: isAuthEnabled,
                    onChanged: _onAutenticacaoChanged,
                  ),  // Senha
                  if (isAuthEnabled)...[
                    SwitchListTile(
                      title: Text(isAuthenticated ? 'Autenticado' : 'Não Autenticado'),
                      subtitle: Text(isAuthenticated ? 'Você está Autenticado' : 'Você não está Autenticado'),
                      value: isAuthenticated,
                      onChanged: _onIsAuthenticadoChanged,
                    ),

                    if (_auth.isSupported && isAuthenticated)...[
                      SwitchListTile(
                        title: const Text('Autenticação do Sistema'),
                        subtitle: const Text('Usa autenticação do dispositivo como padrão'),
                        value: _auth.isSystemEnabled,
                        onChanged: _onAutenticacaoSistemaChanged,
                      ),  // Autenticação do Sistema

                      OkiDropDown(
                        text: 'Tipo de bloqueio',
                        info: _bloqueioTypeInfo(),
                        items: ui.bloqueioType,
                        value: ui.bloqueioType[bloqueioType],
                        onChanged: _onBloqueioTypeChanged,
                      ),  // Tipo de bloqueio

                      ListTile(
                        title: const Text('Transparência na tela de bloqueio'),
                        subtitle: Row(
                          children: [
                            Text('${(_blurBloqueio * 10).toInt()}%'),
                            Expanded(
                              child: Slider(
                                value: _blurBloqueio,
                                max: 10,
                                min: 0,
                                onChanged: _onBlurChanged,
                                onChangeEnd: _onBlurChangeEnd,
                              ),
                            )
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: _onVisualizarBloqueioClick,
                          child: const Text('Visualizar'),
                        ),
                      ),  // Transparência
                    ]
                  ],
                ],
              ),
            ),  // Segurança

          Card(
            child: ExpansionTile(
              title: Text(idiomaWatch(context).layout),
              initiallyExpanded: _layoutOptionsOpened,
              children: [
                if (isPortrait)
                  for(var widget in layoutOptions)
                    widget
                else
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        for(var widget in layoutOptions)
                          Expanded(child: widget),
                      ],
                    ),
                  ),

                const SizedBox(height: 10,),

                if (usePage)...[
                  ListTile(
                    subtitle: Spinner<int>(
                      values: const [20, 30, 50, 70, 100, 200],
                      value: postsPorPage,
                      onChanged: (value) {
                        postsPorPage = value;
                      },
                    ),
                    title: Text(idiomaWatch(context).itemPorPagina),
                  ),
                ],
              ],
              onExpansionChanged: (value) => _layoutOptionsOpened = value,
            ),
          ), // Layout

          Card(
            child: ListTile(
              title: Text(idiomaWatch(context).armazenamento),
              // trailing: TextButton(
              //   child: Text('Gerenciar'),
              //   onPressed: _onArmazenamentoClick,
              // ),
              onTap: _onArmazenamentoClick,
            ),
          ),

          Card(
            child: OkiDropDown(
              text: idiomaWatch(context).idioma,
              items: idiomaProvider.values.keys.toList(),
              value: idiomaWatch(context).languageName,
              onChanged: _onIdiomaChanged,
              // onTap: _onArmazenamentoClick,
            ),
          ),

          if (isDebug)
            Card(
              child: ExpansionTile(
                title: const Text('Debug'),
                initiallyExpanded: _debugOptionsOpened,
                children: [
                  if (isAuthenticated)
                    SwitchListTile(
                      title: const Text('Play Story'),
                      value: isPlayStory,
                      onChanged: _onisPlayStoryChanged,
                    ), // PlayStory

                  ElevatedButton(
                    child: const Text('SnackBar'),
                    onPressed: () {
                      Log.snack('SnackBar teste');
                    },
                  ),
                  const SizedBox(height: 5,),
                  ElevatedButton(
                    child: const Text('SnackBar Erro'),
                    onPressed: () {
                      Log.snack('SnackBar teste', isError: true);
                    },
                  ),
                  const SizedBox(height: 10,),
                ],
                onExpansionChanged: (value) => _debugOptionsOpened = value,
              ),
            ),  // Debug
        ],
      ),
    );
  }

  //endregion

  //region metodos

  void _onArmazenamentoClick() {
    Navigate.push(context, const ArmazenamentoPage());
  }

  // ignore: unused_element
  void _onBlacklitClick() {
    DialogFullScreen(
      context: context,
      content: StatefulBuilder(
        builder: (context, setState) =>
            Scaffold(
              appBar: AppBar(title: const Text('Tags Bloqueadas'),),
              body: ListView.builder(
                itemCount: _booruMng.blackList.length,
                itemBuilder: (context, index) {
                  final item = _booruMng.blackList[index];

                  return ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      tooltip: 'Remover',
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        _booruMng.blackList.remove(item);
                        setState.call(() {});
                      },
                    ),
                  );
                },
              ),
            ),
      ),
    ).showPage();
  }

  void _onAddBooruClick([ABooru? item]) async {
    Booru? booru;
    if (item != null && item.isPersonalizado) {
      booru = Booru(
        baseUrl: item.domain,
        homeUrl: item.home,
        nome: item.name,
        booruType: item.type,
        isSafe: item.isSafe,
      );
    }
    await Navigate.push(context, AddBooruPage(booru: booru));
    setState(() {});
  }


  void _onBlurChanged(double value) {
    _blurBloqueio = value;
    setState(() {});
  }

  void _onBlurChangeEnd(double value) {
    blurBloqueio = value;
  }

  void _onBloqueioTypeChanged(String? value) {
    bloqueioType = value == ui.bloqueioType[0] ? 0 : 1;
    setState(() {});
  }

  void _onSetOnlySafeAsCapaChanged(bool? value) {
    useOnlySafeAsCapa = value ?? false;
    setState(() {});
  }

  void _onAutenticacaoChanged(bool? value) {
    if (value ?? false) {
      _authEnable();
    } else {
      if(_auth.isAuthenticated) {
        _authDisable();
      } else {
        _msgNaoAutenticado();
      }
    }
  }

  void _onIsAuthenticadoChanged(bool? value) {
    if (value ?? false) {
      _authenticate();
    } else {
      _authDes();
    }
  }

  void _onAutenticacaoSistemaChanged(bool? value) {
    if (value ?? false) {
      _biometriaEnable();
    } else {
      _biometriaDisable();
    }
  }

  void _onRatingChanged(bool? add, String value) {
    if (add??false) {
      _booruMng.rating.add(value);
    } else {
      _booruMng.rating.remove(value);
    }
    setState(() {});
  }

  void _onIdiomaChanged(String? value) {
    // idiomaAtual = value!;

    idiomaProvider.setIdiomaFromString(value!);
  }

  // ignore: unused_element
  void _onBooruChanged(String? value) {
    BooruProvider.i.setBooruFromName(value ?? '');
    setState(() {});
  }

  void _onisPlayStoryChanged(bool value) async {
    isPlayStory = value;
    if (value) {
      if (!Boorus.get(currentBooru)!.isSafe) {
        _booruMng.setBooruFromName(Yandere.name_);
      }
    }
    setState(() {});
  }

  // ignore: unused_element
  void _onisDebugChanged(bool value) async {
    showDebug = value;
    setState(() {});
  }

  void _onVisualizarBloqueioClick() {
    Navigate.push(context, AuthPage(
      _auth.password,
      readOnly: true,
    ));
  }

  void _authEnable() {
    Navigate.push(context, AuthPage(
      _auth.password,
      canBack: true,
      onSuccess: () {
        setState(() => _auth.isAuthenticated = true);
      },
      onConfigure: (value) {
        if (value.isNotEmpty) {
          setState(() {
            _auth.password = value;
            _auth.isAuthenticated = true;
          });
        }
      },
    ));
  }
  void _authDisable() {
    Navigate.push(context, AuthPage(
      _auth.password,
      canBack: true,
      onSuccess: () {
        setState(() {
          _auth.password = '';
          _auth.isAuthenticated = false;
        });
      },
    ));
  }
  void _authenticate() async {
    Navigate.push(context, AuthPage(
      _auth.password,
      canBack: true,
      onSuccess: () {
        setState(() => _auth.isAuthenticated = true);
      },
    ));
  }
  void _authDes() async {
    var title = 'Desautenticar?';
    var result = await DialogBox(context: context, title: title,).simNao();
    if (result.isPositive) {
      setState(() {
        _auth.isAuthenticated = false;
      });
    }
  }

  void _biometriaEnable() async {
    bool result = await _auth.bioAuth();
    _auth.isSystemEnabled = result;
    setState(() {});

    if (!result) {
      Log.snack('Erro ao Autenticar', isError: true);
    }
  }
  void _biometriaDisable() async {
    var title = 'Remover Biometria?';
    var result = await DialogBox(context: context, title: title).simNao();
    if (result.isPositive) {
      if (await _auth.bioAuth()) {
        setState(() => _auth.isSystemEnabled = false);
      }
    }
  }

  void _msgNaoAutenticado() {
    Log.snack('Não autenticado', isError: true);
  }

  String? _bloqueioTypeInfo() {
    switch(bloqueioType) {
      case 0:
        return 'O app poderá ser utilizado, porém com algumas restrições.';
      case 1:
        return 'Bloqueia totalmente o app.';
      default: return null;
    }
  }

  //endregion

}