import 'package:flutter/material.dart';
import 'package:moeboo/model/album.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../model/booru.dart';
import '../oki/import.dart';
import '../res/import.dart';

class AddBooruPage extends StatefulWidget {
  final Booru? booru;
  const AddBooruPage({this.booru, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AddBooruPage> {

  BooruProvider get _booruProv => BooruProvider.i;

  late Booru booru;

  final _formKey = GlobalKey<FormState>();

  ILanguage get ui => idioma;
  
  bool isNovo = false;
  bool useHttps = true;

  String _dominio = '';

  @override
  void initState() {
    isNovo = widget.booru == null;
    booru = widget.booru?.copy() ?? Booru.empty;
    _dominio = booru.baseUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final boorus = Boorus.optionals.values.toList();
    boorus.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text(ui.titleAddBooru),
        actions: [
          if (!isNovo)
            IconButton(
              tooltip: ui.excluir,
              onPressed: _onRemoveTap,
              icon: const Icon(Icons.delete_forever),
            ),
          const SizedBox(width: 10,),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OkiTextField(
                    hint: ui.nome,
                    initialValue: booru.nome,
                    textInputType: TextType.name,
                    onSave: (value) => booru.nome = value ?? '',
                    validator: (value) {
                      if (isNovo && (Boorus.values.containsKey(value) || Boorus.optionals.containsKey(value))) {
                        return ui.provedorTip;
                      }
                      return null;
                    },
                  ),  // nome
                  OkiTextField(
                    hint: ui.dominio,
                    initialValue: booru.baseUrl,
                    textInputType: TextType.text.lowerCase,
                    onSave: (value) => booru.baseUrl = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return ui.campoObrigatorio;
                      }
                      if (value.contains('/')) {
                        return ui.dominioTip;
                      }
                      return null;
                    },
                    onChanged: (value) => _dominio = value,
                    icon: TextButton(
                      onPressed: _onTestTap,
                      child: Text(ui.teste),
                    ),
                  ),  // domain
                  OkiTextField(
                    hint: ui.homePage,
                    initialValue: booru.homeUrl,
                    textInputType: TextType.text.lowerCase,
                    onSave: (value) => booru.homeUrl = value ?? '',
                    validator: (value) {
                      if (value!.contains('/')) {
                        return ui.homePageTip;
                      }
                      return null;
                    },
                  ),  // home

                  CheckboxListTile(
                    title: const Text('Https'),
                    subtitle: Text(ui.desmarqueHttp),
                    value: useHttps,
                    onChanged: (value) {
                      useHttps = value!;
                      _setState();
                    },
                  ),  // https

                  OkiDropDown(
                    text: ui.tipoBooru,
                    value: BooruType.templateValues[booru.booruType.index],
                    items: BooruType.templateValues,
                    onChanged: _onTypeChanged,
                  ),  // tipo

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSaveTap,
                      child: Text(ui.salvar),
                    ),
                  ),  // salvar

                  TextButton(
                    onPressed: _onHelpTap,
                    child: Text(ui.identificarProvider),
                  ),  // Ajuda

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),  // form

          const Divider(),

          Center(
            child: Text(ui.preConfig),
          ),

          ListView.builder(
            itemCount: Boorus.optionals.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 80),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              final item = boorus[i];

              return SwitchListTile(
                title: Text(item.name),
                subtitle: Text(item.home),
                value: Boorus.optEnabled[item.name] ?? false,
                onChanged: (value) {
                  Boorus.optEnabled[item.name] = value;
                  Boorus.save();
                  _setState();

                  if (!value && currentBooru == item.name) {
                    _booruProv.setBooruFromName(Yandere.name_);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _onSaveTap() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    _booruProv.addBooru(booru);
    Log.snack(ui.dadosSalvos);
  }

  void _onRemoveTap() async {
    void onresultO() {
      _booruProv.removeBooru(booru);
      Navigator.pop(context);
    }

    final result = await DialogBox(
      context: context,
      content: [
        Text(ui.desejaRemoverProvider),
      ],
    ).simNao();
    if (result.isPositive) {
      onresultO();
    }
  }

  void _onTestTap() {
    if (_dominio.isEmpty) {
      Log.snack('Informe o Domínio', isError: true);
      return;
    }

    final booru = _booruProv.createBooru(Booru(
      nome: '',
      baseUrl: _dominio,
      homeUrl: '',
      booruType: this.booru.booruType,
    ));

    String text = '';
    bool inProgress = true;

    DialogBox(
      context: context,
      title: ui.testandoDomain,
      content: [
        OkiStatefulBuilder(
          initialize: (setState) async {
            try {
              final res = await booru!.findPosts(query: AlbumQuery());
              if (res.isEmpty) {
                text = ui.buscaNoResult;
              } else {
                text = ui.tudoCerto;
              }
            } catch(e) {
              text = 'ERROR: $e\n\nBooru Type: ${booru!.type.value}';
            }
            inProgress = false;
            setState();
          },
          builder: (context, setState, state) {
            return Column(
              children: [
                if (inProgress)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else...[
                  if (text.isNotEmpty)
                    Text(text),
                ]
              ],
            );
          },
        ),
      ],
    ).ok();
  }

  void _onHelpTap() {
    final color = Theme.of(context).textTheme.bodyLarge?.color;
    final styleTitle = TextStyle(
      color: color,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    final styleContent = TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    );
    final styleDestaque = TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    DialogBox(
      context: context,
      title: ui.identificarProvider,
      content: [
        RichText(
          text: TextSpan(
            text: 'Danbooru\n',
            style: styleTitle,
            children: [
              TextSpan(text: ui.danbooruInfo_1,
                style: styleContent,
              ),
              TextSpan(text: ' /posts ',
                style: styleDestaque,
              ),
              TextSpan(text: ui.danbooruInfo_2,
                style: styleContent,
              ),
            ],
          ),
        ),  // Dan
        const Divider(),
        RichText(
          text: TextSpan(
            text: 'Gelbooru\n',
            style: styleTitle,
            children: [
              TextSpan(text: ui.gelbooruInfo,
                style: styleContent,
              ),
              TextSpan(text: ' /index.php?page=post&s=list',
                style: styleDestaque,
              ),
            ],
          ),
        ),  // Gel
        const Divider(),
        RichText(
          text: TextSpan(
            text: 'Moebooru\n',
            style: styleTitle,
            children: [
              TextSpan(text: ui.moebooruInfo_1,
                style: styleContent,
              ),
              TextSpan(text: ' /post ',
                style: styleDestaque,
              ),
              TextSpan(text: ui.moebooruInfo_2,
                style: styleContent,
              ),
            ],
          ),
        ),  // Moe
      ],
    ).ok();
  }

  void _onTypeChanged(String? value) {
    booru.booruType = BooruType.fromName(value??'');
    _setState();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}