import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:showcaseview/showcaseview.dart';
import '../util/util.dart';
import '../fragments/import.dart';
import '../provider/import.dart';
import '../model/import.dart';
import '../pages/import.dart';
import '../res/import.dart';
import '../oki/import.dart';

class AlbumCollectionPage extends StatefulWidget {
  final Album album;
  final Album? talvezParent;
  final bool realOnly;
  final bool showAddButton;
  final bool showConfigMenu;
  final bool root;
  const AlbumCollectionPage({
    required this.album,
    this.talvezParent,
    this.realOnly = false,
    this.showConfigMenu = false,
    this.showAddButton = true,
    this.root = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AlbumCollectionPage> with TickerProviderStateMixin {

  //region variaveis

  late BuildContext context2;
  late BuildContext context3;

  AuthManager get _auth => AuthManager.auth;
  AlbunsProvider get _albunsMng => AlbunsProvider.i;

  final ScrollController _mainController = ScrollController();
  final ScrollController _storeController = ScrollController();
  final RefreshController _refreshController = RefreshController();
  late AnimationController _aniController;

  final _animDuration = const Duration(milliseconds: 200);

  Album _albumWatch() => context2.watch<Album>();
  Album _albumRead() => context2.read<Album>();

  bool _canSetAlbumAsCapa() => _albumWatch().isSalvo &&
      !_albumWatch().isCapaOfCollection && _albumWatch().parent?.id != AlbunsProvider.rootId;
  bool _canShowDeleteButton() => _albumWatch().isSalvo;

  bool get _isRoot => widget.root;
  bool _canUpdateStore = false;
  bool _inProgress = false;

  final List<Store> _albunsStories = [];

  ILanguage get ui => idioma;

  final _searchBtnKey = GlobalKey();

  //endregion

  //region widgets

  @override
  void dispose() {
    _mainController.dispose();
    _storeController.dispose();
    _refreshController.dispose();
    try {
      _aniController.dispose();
    } catch(e) {
      //
    }

    // _album.clearPostsOnline();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.album.isRoot) {
      List<GlobalKey> prepareKeys() {
        final items = <GlobalKey>[];

        if (!Tutorial.collectionAlbumSearch) {
          Tutorial.collectionAlbumSearch = true;
          items.add(_searchBtnKey);
        }

        return items;
      }

      final keys = prepareKeys();

      if (keys.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => ShowCaseWidget.of(context3).startShowCase(keys));
      }
    }

    _loadStores = _init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.album,
      builder: (context, o) {
        context2 = context;

        return Scaffold(
          endDrawer: _drawer(),
          body: Column(
            // physics: const AlwaysScrollableScrollPhysics(
            //   parent: BouncingScrollPhysics(),
            // ),
            children: [
              _appBar(),

              Expanded(child: _body()),
            ],
          ),
          drawerScrimColor: Colors.transparent,
          drawerEdgeDragWidth: MediaQuery.of(context2).size.width / 4,
          floatingActionButton: _floatingActionButton(),
        );
      },
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: ShowCaseWidget(
        builder: (context) {
          context3 = context;
          return Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                if (!_isRoot)
                  IconButton(
                    tooltip: ui.voltar,
                    icon: const Icon(Icons.arrow_back_ios, size: 20,),
                    onPressed: () => Navigator.pop(context),
                  )
                else
                  const SizedBox(width: 20),

                Text(_albumWatch().nome, maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),  // title

                const Spacer(),

                if (_isRoot)
                  Showcase(
                    key: _searchBtnKey,
                    title: ui.pesquisar,
                    description: ui.infoPesquisar,
                    child: IconButton(
                      tooltip: ui.pesquisar,
                      onPressed: _onPesquisaClick,
                      icon: const Icon(Icons.search),
                    ),
                  ),

                Builder(builder: (context) {
                  return IconButton(
                    tooltip: ui.menu,
                    icon: const Icon(Icons.menu),
                    onPressed: Scaffold.of(context).openEndDrawer,
                  );
                }),

                const SizedBox(width: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: ListView(
        children: [
          DrawerHeader(
            // margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(12, 12, 16, 1),
                image: DecorationImage(
                  image: AssetImage(Assets.icLauncher),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 3,
                      sigmaY: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            Assets.icLauncher,
                            width: 100,
                            height: 100,
                          ),
                        ),

                        const Text(Ressources.appName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: 15,
                    bottom: 5,
                    child: Text('v ${OkiManager.i.appVersion}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_auth.isAuthenticated)... [
            if (widget.showAddButton && (_albumWatch().parent != null || _isRoot))
              _menuItem(ui.novoAlbum),

            if (_isRoot)...[
              _menuItem(ui.favoritos),
              _menuItem(ui.postsSalvos),
            ],

            if (!widget.realOnly)... [
              _menuItem(ui.editarAlbum),

              if (_canShowDeleteButton())
                _menuItem(ui.excluirAlbum),
            ],

            if (_canSetAlbumAsCapa())
              _menuItem(ui.useAlbumAsCapa),
          ],

          const Divider(),

          if (widget.showConfigMenu)
            _menuItem(ui.config),

          _menuItem(ui.info),

          // if (_albumRead().isRoot)...[
          //   _menuItem(ui.tour),
          // ],
        ],
      ),
    );
  }

  Widget _body() {
    final albunsList = _albumWatch().values.toList()..removeWhere((item) {
      if (item.isFavoritos) return true;
      if (item.isSalvos) return true;

      if (_auth.isAuthenticated) return false;

      return item.isOculto;
    });
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: albunsList.length.isEven ? 80 : 0),
      child: Scrollbar(
        thumbVisibility: Platform.isWindows,
        controller: _mainController,
        child: Column(
          children: [
            if(_isRoot)...[
              _stories(),
            ],

            AnimatedPadding(
              duration: _animDuration,
              padding: EdgeInsets.all(isUnindoAlbum ? 20 : 0),
              child: AlbunsFragment(
                albuns: albunsList,
                gridMode: albunsLatoyt == 0,
                onItemClick: _onAlbumClick,
                onItemLongClick: _onAlbumLongClick,
                onAddFolderClick: ([album]) => _onAddAlbumClick(),
                controller: _mainController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stories() {
    return FutureBuilder(
      future: _loadStores,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container();
        }
        if (_albunsStories.isEmpty) {
          return Container();
        }

        return SizedBox(
          height: 150,
          child: SmartRefresher(
            onRefresh: _updateStores,
            controller: _refreshController,
            scrollController: _storeController,
            scrollDirection: Axis.horizontal,
            header: CustomHeader(
              refreshStyle: RefreshStyle.UnFollow,
              builder: (BuildContext context, RefreshStatus? mode) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedBuilder(
                      animation: _aniController,
                      child: const Icon(Icons.refresh, size: 30,),
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _aniController.value * 2 * pi,
                          child: child,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            child: ListView(
              shrinkWrap: true,
              controller: _storeController,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                for(int i = 0; i < _albunsStories.length; i++)
                  StoreTile(
                    store: _albunsStories[i],
                    onTap: _canUpdateStore ? null : _onStorieClick,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(String value) {
    final subtitle = menuSubtitle(context2, value);

    return ListTile(
      title: Text(value),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: MenuIcon(value),
      onTap: () => _onMenuItemClick(context2, value),
    );
  }

  Widget? _floatingActionButton() {
    if (_inProgress) return const CircularProgressIndicator();

    if (isUnindoAlbum) {
      return FloatingActionButton.extended(
        label: Text(ui.cancelar,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        onPressed: _onUnirCancelClick,
      );
    }

    return FloatingActionButton(
      heroTag: hashCode,
      tooltip: ui.novoAlbum,
      onPressed: _onAddAlbumClick,
      child: const Icon(Icons.create_new_folder_rounded),
    );
  }

  //endregion

  //region Metodos

  Future<void>? _loadStores;

  Future<void> _init() async {
    _aniController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _refreshController.headerMode?.addListener(() {
      if (_refreshController.headerStatus == RefreshStatus.idle) {
        _aniController.reset();
      } else if (_refreshController.headerStatus == RefreshStatus.refreshing) {
        _aniController.repeat();
      }
    });

    if (widget.album.isRoot) {
      _albunsStories.addAll(await AlbunsProvider.i.getStories());
    }
  }

  void _back() {
    Navigator.pop(context);
  }

  void _setInProgress(bool b) {
    _inProgress = b;
    _setState();
  }

  void _setState() {
    // Log.d(TAG, '_setState', method);
    if (mounted) {
      setState(() {});
    }
  }

  //endregion

  //region menu

  void _onPesquisaClick() {
    showSearch(context: context, delegate: DataSearch());
  }

  Map<String, void Function()?> get menu => {
    ui.novoAlbum: _onAddAlbumClick,
    ui.editarAlbum: _onEditAlbumClick,
    ui.excluirAlbum: _onDeleteAlbumClick,
    ui.useAlbumAsCapa: _onUseAsCapaClick,
    ui.favoritos: _onFavoritosClick,
    ui.postsSalvos: _onPostsSalvosClick,
    ui.config: _onConfigClick,
    ui.info: _infoClick,
  };

  void _onMenuItemClick(BuildContext context, String value) {
    Navigator.pop(context);

    menu[value]?.call();

    // switch(value) {
    //   case Menus.novoAlbum:
    //     _onAddAlbumClick(context);
    //     break;
    //   case Menus.editarAlbum:
    //     _onEditAlbumClick(context);
    //     break;
    //   case Menus.excluirAlbum:
    //     _onDeleteAlbumClick(context);
    //     break;
    //   case Menus.useAlbumAsCapa:
    //     _onUseAsCapaClick(context);
    //     break;
    //   case Menus.favoritos:
    //     onFavoritosClick(context, _setInProgress);
    //     break;
    //   case Menus.postsSalvos:
    //     onPostsSalvosClick(context, _setInProgress);
    //     break;
    //   case Menus.config:
    //     _onConfigClick();
    //     break;
    //   case Menus.info:
    //     _onInfoClick(widget.album);
    //     break;
    // }
  }

  void _onAddAlbumClick({Album? album, bool showCustonParent = true}) async {
    var result = await Navigate.push(context, AddAlbumPage(
      album: album,
      parent: _albumRead(),
      showCustomParent: !_isRoot && showCustonParent,
    ));
    if (result != null && result is Album) {
      if (!_albumRead().containsKey(result.id)) {
        _back();
      }
      _onAlbumClick(result);
    }
    _setState();
  }

  void _onEditAlbumClick() {
    popupRenameAlbum(context, _albumRead()).then((value) => _setState());
  }

  void _onDeleteAlbumClick([Album? item]) {
    popupDeleteAlbum(context, item ?? _albumRead()).then((value) {
      if (value) {
        if (item == null) {
          Navigator.pop(context);
        } else {
          _setState();
        }

        AlbunsProvider.i.save();
      }
    });
  }


  void _onFavoritosClick() {
    onFavoritosClick(context, _setInProgress);
  }

  void _onPostsSalvosClick() {
    onPostsSalvosClick(context, _setInProgress);
  }

  //------------------------------------------------------

  void _onUseAsCapaClick() {
    _albumRead().useAsCapa();
    _albunsMng.save();
    Log.snack(ui.capaAlterada);
  }

  void _onConfigClick() {
    Navigate.push(context, const ConfigPage()).then((value) => _setState());
  }

  void _infoClick() {
    _onInfoClick(widget.album);
  }

  void _onInfoClick(Album album) async {
    void onComplete() {
      popupAlbumInfo(context, album);
      _setInProgress(false);
    }

    _setInProgress(true);
    await album.computPosts(recursive: true);
    onComplete();
  }

  //endregion

  //region store

  Future<void> _updateStores() async {
    _albunsStories.clear();
    _albunsStories.addAll(await _albunsMng.getStories());
    _canUpdateStore = false;
    _refreshController.refreshCompleted();
    _setState();
  }

  void _onStorieClick(Store store) {
    int initIndex = _albunsStories.indexOf(store);
    if (initIndex < 0) initIndex = 0;

    Navigate.push(context, StorePage(
        albuns: _albunsStories,
        initialIndex: initIndex,
      ),
      fullscreenDialog: true, heroAnim: true,
    ).then((value) async {
      await Future.delayed(const Duration(milliseconds: 200));

      if (_albunsStories.length == 1) {
        _albunsStories.first.todosVistos;
      } else {
        _albunsStories.sort((a, b) {
          if (a.todosVistos && b.todosVistos) return 0;

          if (a.todosVistos) return 1;

          return -1;
        });
      }

      _setState();
    });
  }

  //endregion

  //region AlbunsFragment

  void _onAlbumClick(Album item) async {
    if (!item.isCollection && isUnindoAlbum) {
      _onUnirClick(item);
      return;
    }

    if (item.isCollection) {
      await Navigate.push(context, AlbumCollectionPage(album: item,), provider: item);
    } else {
      await Navigate.push(context, AlbumPage(album: item,), fullscreenDialog: true);
    }
    _setState();
  }

  void _onAlbumLongClick(Album item) async {
    if (isUnindoAlbum || !_auth.isAuthenticated) {
      return;
    }

    final result = await PopupAlbumOptions(context, item).show();

    if (result is Album || result == true) {
      _setState();
    }
  }

  void _onUnirClick(Album item) async {
    if (albumParaUnir == item) return;

    final result = await DialogBox(
      context: context,
      title: ui.unirAlbuns,
      content: [
        Text('${ui.unir} \'${albumParaUnir?.nome}\' ${ui.a} \'${item.nome}\'?')
      ],
    ).simNao();
    if (result.isPositive) {
      _setInProgress(true);
      await item.unirWith(albumParaUnir);
      albumParaUnir = null;
      _albunsMng.save();
    }

    // if (!isUnindoAlbum) {
    //   albumParaUnir = item;
    // } else {}
    _setInProgress(false);
  }

  void _onUnirCancelClick() {
    albumParaUnir = null;
    _setState();
  }

  //endregion

}

void onFavoritosClick(BuildContext context, [void Function(bool)? onProgress]) async {
  Navigate.push(context, AlbumPage(
    album: AlbunsProvider.i.favoritos,
    realOnly: true,
    showAddButton: false,
  ));
}

void onPostsSalvosClick(BuildContext context, [void Function(bool)? onProgress]) async {
  Navigate.push(context, AlbumPage(
    album: AlbunsProvider.i.salvos,
    realOnly: true,
    showAddButton: false,
  ));
}