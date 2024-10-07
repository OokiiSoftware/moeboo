import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'pages/import.dart';
import 'oki/import.dart';
import 'provider/import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  HttpOverrides.global = MyHttpOverrides();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AlbunsProvider()),
      ChangeNotifierProvider(create: (_) => BooruProvider()),
      ChangeNotifierProvider(create: (_) => IdiomaProvider()),
    ],
    child: const Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State createState() => _State();
}
class _State extends State<Main> {

  //region variaveis

  static const _log = Log('Main');

  ThemeManager get _theme => ThemeManager.i;

  late Future<Widget> _task;

  String? _erroOnBuilder;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _task = _mainPage();
    database.child(Childs.theme).addListener((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // debugInvertOversizedImages = true;//

    return MaterialApp(
      title: Ressources.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: OkiScrollBehavior(),
      theme: _theme.themeData(),
      home: _body(),
      builder: (c, w) => ScaffoldMessenger(
        key: Log.key,
        child: w ?? const SplashScreen(),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder<Widget>(
      future: _task,
      initialData: const SplashScreen(),
      builder: (context, snapshot) {
        return snapshot.data!;
      },
    );
  }

  Widget _errorBuilder() {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Ocorreu um erro ao iniciar o app',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            const Text('Tente limpar os dados nas configurações do app'),
            const Text(''),
            ElevatedButton(
              onPressed: _onBackupClick,
              child: const Text('Tentar exportar meus albuns'),
            ),
            const Text(''),
            const Text('Detalhes do erro'),
            Text(_erroOnBuilder!),
          ],
        ),
      ),
    );
  }

  Future<Widget> _mainPage() async {
    try {
      await OkiManager.i.init();
      AlbunsProvider.i.load();
      BooruProvider.i.load();
      WallpaperProvider.i.load();

      await Future.delayed(const Duration(seconds: 1));

      return const MainPage();
    } catch(e) {
      _erroOnBuilder = e.toString();
      _log.e('_mainPage', e);
      return _errorBuilder();
    }
  }

  //endregion

  //region metodos

  void _onBackupClick() async {
    await StorageManager.i.init();

    final file = StorageManager.i.file('database.json');
    OkiManager.i.share(file.path, text: '${Ressources.appName}.json');
  }

  //endregion

}
