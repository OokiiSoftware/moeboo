import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:showcaseview/showcaseview.dart';
import '../fragments/import.dart';
import '../util/util.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../res/import.dart';
import '../oki/import.dart';
import 'import.dart';

class AlbumPage extends StatefulWidget {
  final Album album;
  final Album? talvezParent;
  final bool showAddButton;
  final bool noGroup;
  final bool noOnline;
  final bool realOnly;
  const AlbumPage({required this.album, this.talvezParent,
    this.showAddButton = true,
    this.noGroup = false,
    this.noOnline = false,
    this.realOnly = false, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AlbumPage> with TickerProviderStateMixin {

  //region variaveis

  static const _log = Log('AlbumPage');
  static int _expandAlbumDraw = 0;

  late BuildContext context2;
  late BuildContext context3;

  AlbunsProvider get _albunsMng => AlbunsProvider.i;
  BooruProvider get _booruMng => BooruProvider.i;
  AuthManager get _auth => AuthManager.auth;

  ABooru get _booru => _booruMng.booru;
  List<String> get _rating => _booruMng.rating;

  Album? get _talvezParent => widget.talvezParent;

  bool get _inSelectMode => _selectedPosts.value > 0;
  bool get _canPop => !_inSelectMode && !_isAnalizing();

  final List<PostG> _posts = [];

  final ScrollController _cFragments = ScrollController();
  // final ScrollController _cMain = ScrollController();
  final RefreshController _cRefresh = RefreshController();
  final PageController _cPage = PageController();
  late AnimationController _cAnimation;

  final OkiInt _selectedPosts = OkiInt();
  final _stafKey = GlobalKey<ScaffoldState>();

  final _animDuration = const Duration(milliseconds: 300);

  static bool _inProgress = false;

  bool _isRoot = false;
  bool _isFavoritos = false;
  bool _isSavedPosts = false;
  bool _canChangeRating = false;
  bool _enableLongPress = true;
  bool _showAppBar = true;

  /// Serve pra impedir que [Navigator.pop] chame [PopScope] onde não deve
  bool _blockPop = false;

  /// Cria uma popup ao pressionar um post
  OverlayEntry? _postPopupEntry;

  Album get _albumWatch => context2.watch<Album?>() ?? widget.album;
  Album get _albumRead => context2.read<Album?>() ?? widget.album;

  bool _canSetAlbumAsCapa() => _albumWatch.isSalvo && !_albumWatch.isCapaOfCollection && !(_albumWatch.parent?.isRoot ?? true);
  bool _isAnalizing() => _albumRead.isAnalize;
  bool _canShowDeleteButton() => _albumWatch.isSalvo;
  bool _canShowSaveButton() => !_albumWatch.isSalvo;

  ILanguage get ui => idioma;

  final _groupBtnKey = GlobalKey();
  final _onlineBtnKey = GlobalKey();
  final _unirPostsBtnKey = GlobalKey();
  final _atualizarBtnKey = GlobalKey();
  final _setCapaBtnKey = GlobalKey();

  late AnimationController _popupAnimController;
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;

  void Function()? appBarSetState;

  /// Há um bug em [_cRefresh.position] em que o listener é removido.
  /// Essas duas variaveis servem pra resolver o problema.
  Timer? _timerScrollPosition;
  /// Armazena o hashCode do [_cRefresh.position] atual.
  int _currentScrollPosition = 0;

  //endregion

  //region widgets

  @override
  void dispose() {
    _popupAnimController.dispose();
    super.dispose();

    _addListeners(false);

    // _cFragments.dispose();
    _cRefresh.dispose();
    // _cMain.dispose();
    _cAnimation.dispose();
    _cPage.dispose();
  }

  @override
  void initState() {
    super.initState();

    _popupAnimController = AnimationController(vsync: this, duration: _animDuration);
    scaleAnimation = CurvedAnimation(parent: _popupAnimController, curve: Curves.easeOutExpo);
    opacityAnimation = Tween<double>(begin: 0.0, end: 0.6)
        .animate(CurvedAnimation(parent: _popupAnimController, curve: Curves.easeOutExpo));

    final album = widget.album;

    _isRoot = album.isRoot;
    _isFavoritos = album.id == AlbunsProvider.favoritosId;
    _isSavedPosts = album.id == AlbunsProvider.salvosId;
    _canChangeRating = !isPlayStory && _auth.isAuthenticated;

    List<GlobalKey> prepareKeys() {
      final items = <GlobalKey>[];

      if (!Tutorial.albumGroup) {
        Tutorial.albumGroup = true;
        items.add(_groupBtnKey);
      }

      if (!Tutorial.albumOnline) {
        Tutorial.albumOnline = true;
        items.add(_onlineBtnKey);
      }

      return items;
    }

    final keys = prepareKeys();
    if (keys.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => ShowCaseWidget.of(context3).startShowCase(keys));
    }

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.album,
      builder: (context, o) {
        context2 = context;

        if (_albumWatch.isCollection && !_albumWatch.isRoot) {
          return AlbumCollectionPage(album: _albumRead);
        }

        return PopScope(
          canPop: _canPop,
          onPopInvoked: (value) => _onPopScope(value, true),
          child: Scaffold(
            key: _stafKey,
            endDrawer: _drawer(),
            drawerScrimColor: Colors.transparent,
            drawerEdgeDragWidth: MediaQuery.of(context).size.width / 5,
            floatingActionButton: _floatingButton(),
            body: _body(),
          ),
        );
      },
    );
  }

  Widget _drawer() {
    final album = _albumWatch;

    return SafeArea(
      child: Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10)
        ),
      ),
      child: OkiStatefulBuilder(
        builder: (context, setState, a) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 10),
            children: [
              if (_auth.isAuthenticated)... [
                ExpansionPanelList(
                  expansionCallback: (i, b) {
                    _expandAlbumDraw = i;
                    _setState();
                  },
                  children: [
                    ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: _expandAlbumDraw == 0,
                      headerBuilder: (context, expanded) {
                        return ListTile(
                          title: Text(ui.album),
                          subtitle: expanded ? null : Text(ui.cliqueParaVerMais),
                        );
                      },
                      body: Column(
                        children: [
                          _menuItem(ui.novoAlbum, enabled: (album.parent != null || _isRoot) && widget.showAddButton),

                          if (_isRoot)...[
                            _menuItem(ui.favoritos),
                            _menuItem(ui.postsSalvos),
                          ] else if (!widget.realOnly)...[
                            _menuItem(ui.editarAlbum, enabled: !_canShowSaveButton()),

                            if (_canShowSaveButton())
                              _menuItem(ui.salvarAlbum),

                            _menuItem(ui.excluirAlbum, enabled: _canShowDeleteButton()),

                            // if (!showOnline.value)
                            //   _menuItem(Menus.reorder, enabled: !_isSavedPosts && !_isFavoritos),

                            if (album.isCapaManual)
                              _menuItem(ui.resetCapa)
                            else
                              SwitchListTile(
                                title: Text(ui.autoUpdateCapa),
                                subtitle: Text(menuSubtitle(context, ui.autoUpdateCapa)),
                                value: album.autoUpdateCapa,
                                onChanged: (value) =>_onAutoUpdateCapaClick(value),
                              ),

                            _menuItem(ui.useAlbumAsCapa, enabled: _canSetAlbumAsCapa()),
                          ],
                        ],
                      ),
                    ),  // Album options

                    ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: _expandAlbumDraw == 1,
                      headerBuilder: (context, expanded) {
                        return ListTile(
                          title: Text(ui.provedor),
                          subtitle: expanded ? null : Text(currentBooru),
                        );
                      },
                      body: Column(
                        children: [
                          _menuItem(currentBooru, enabled: showOnline.value),

                          if (_canChangeRating)
                            _menuItem(ui.maturidade),

                          _menuItem(ui.filtro),

                          _menuItem(ui.updatePosts,
                              subtitle: '${ui.atualizado} ${album.tempoDeAtualizado}', enabled: showOnline.value),

                          // _menuItem(ui.tagsInfo),
                        ],
                      ),
                    ),  // Provider
                  ],
                ),
              ],

              _menuItem(ui.goToPage),
              _menuItem(ui.openLink),

              _menuItem(ui.info),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _body() {
    final album = _albumWatch;

    final enableSwipe = showOnline.value && !_inSelectMode;

    bool isFirstPage = album.pagination == 0;
    bool isLastPage = album.pagination == album.maxPage -1;

    return Stack(
      children: [
        SmartRefresher(
          enablePullUp: enableSwipe && (isLastPage || !usePage),
          enablePullDown: enableSwipe && (isFirstPage || album.isOnlineEmpty),
          onRefresh: () => _onRefesh(),
          onLoading: () => _onRefesh(loadMore: true),
          controller: _cRefresh,
          header: CustomHeader(
            builder: (context, status) {
              final value = status == RefreshStatus.refreshing ? null : 80.0;

              return Center(child: CircularProgressIndicator(value: value));
            },
          ),
          footer: CustomFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
            builder: (c, m) {
              if (_albumWatch.noMoreResults) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(ui.noMoreResults),
                  ),
                );
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedBuilder(
                    animation: _cAnimation,
                    child: const Icon(Icons.refresh, size: 30,),
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: (_cAnimation.value) * 2 * pi,
                        child: child,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          child: PostsFragment(
            posts: _posts,
            controller: _cFragments,
            showOnline: showOnline.value,
            showBooruOptions: !_inProgress,
            gridMode: postsLatoyt == 0,
            onEditTap: _onEditAlbumClick,
            onDeleteTap: _onDeleteAlbumClick,
            builder: (item) {
              return PostTile(
                key: item.currentPost.key,// Key('${item.hashCode}'),
                post: item,
                showMarker: showOnline.value && _auth.isAuthenticated,
                onTap: _onPostTap,
                onLongTap: _onPostLongTap,
                onLongTapUp: _onPostLongTapUp,
                onDoubleTap: _onPostDoubleTap,
              );
            },
          ),
        ),
        _appBar(),
      ],
    );
  }

  // ignore: unused_element
  Widget _oldBody() {
    final album = _albumWatch;

    final enableSwipe = showOnline.value && !_inSelectMode;

    bool isFirstPage = album.pagination == 0;
    bool isLastPage = album.pagination == album.maxPage -1;

    return SmartRefresher(
      enablePullUp: enableSwipe && (isLastPage || !usePage),
      enablePullDown: enableSwipe && (isFirstPage || album.isOnlineEmpty),
      onRefresh: () => _onRefesh(),
      onLoading: () => _onRefesh(loadMore: true),
      controller: _cRefresh,
      header: CustomHeader(
        builder: (context, status) {
          final value = status == RefreshStatus.refreshing ? null : 80.0;

          return Center(child: CircularProgressIndicator(value: value));
        },
      ),
      footer: CustomFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
        builder: (c, m) {
          if (_albumWatch.noMoreResults) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(ui.noMoreResults),
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedBuilder(
                animation: _cAnimation,
                child: const Icon(Icons.refresh, size: 30,),
                builder: (_, child) {
                  return Transform.rotate(
                    angle: (_cAnimation.value) * 2 * pi,
                    child: child,
                  );
                },
              ),
            ),
          );
        },
      ),
      child: CustomScrollView(
        // controller: _cMain,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _appBar(),

          SliverToBoxAdapter(
            child: PostsFragment(
              posts: _posts,
              // controller: _cFragments,
              showOnline: showOnline.value,
              showBooruOptions: !_inProgress,
              gridMode: postsLatoyt == 0,
              onEditTap: () => _onEditAlbumClick(),
              onDeleteTap: () => _onDeleteAlbumClick(),
              builder: (item) {
                return PostTile(
                  key: Key('${item.hashCode}'),
                  post: item,
                  showMarker: showOnline.value && _auth.isAuthenticated,
                  onTap: _onPostTap,
                  onLongTap: _onPostLongTap,
                  onLongTapUp: _onPostLongTapUp,
                  onDoubleTap: _onPostDoubleTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    const appBarHeight = 55.0;
    const appBarPosition = 120.0;

    final width = MediaQuery.of(context).size.width;

    return ShowCaseWidget(
      builder: (context) {
        context3 = context;

        return OkiStatefulBuilder(
          initialize: (setState) {
            appBarSetState = setState;
          },
          builder: (context, setState, state) {
            return AnimatedPositioned(
              duration: _animDuration,
              top: _showAppBar ? (isMobile ? 25 : 0) : -100,
              child: Container(
                height: appBarHeight,
                width: width - 20,
                padding: const EdgeInsets.symmetric(vertical: 2),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: OkiStatefulBuilder(
                  dispose: (setState) => _selectedPosts.removeListener(setState),
                  builder: (context, setState, state) {
                    _selectedPosts.addListener(setState);

                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        AnimatedPositioned(
                          top: _inSelectMode ? -appBarPosition : 0,
                          left: 10,
                          height: appBarHeight,
                          width: width - 40,
                          duration: _animDuration,
                          child: _appBarNormal(),
                        ), // normal mode

                        AnimatedPositioned(
                          top: _inSelectMode ? 0 : appBarPosition,
                          height: appBarHeight,
                          width: width - 60,
                          duration: _animDuration,
                          child: _appBarOptions(),
                        ), // Select mode
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  Widget _oldAppBar() {
    const appBarHeight = 55.0;
    const appBarPosition = 120.0;

    final width = MediaQuery.of(context).size.width;

    return SliverSafeArea(
      top: true,
      sliver: SliverPadding(
        padding: const EdgeInsets.all(5),
        sliver: SliverAppBar(
          floating: true,
          forceElevated: true,
          centerTitle: true,
          leading: _isRoot ? null : IconButton(
            tooltip: ui.voltar,
            icon: const Icon(Icons.arrow_back_ios, size: 20,),
            onPressed: () {
              if (!_canPop) {
                _onPopScope(false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          // backgroundColor: backgroundColor.withOpacity(0.5),
          // shadowColor: shadowColor,
          toolbarHeight: appBarHeight,
          bottom: usePage ? TabBar(
            indicatorColor: Colors.transparent,
            controller: TabController(length: 1, vsync: this),
            tabs: [
              OkiStatefulBuilder(
                dispose: (setState) => _selectedPosts.removeListener(setState),
                builder: (context, setState, state) {
                  _selectedPosts.addListener(setState);

                  return Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: width / 1.5,
                        child: Spinner<int>(
                          space: 15,
                          value: _albumWatch.pagination +1,
                          values: List<int>.generate(_albumWatch.maxPage, (index) => index + 1),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          onEnd: (value) => _onPageChanged(value),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ) : null,
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: OkiStatefulBuilder(
                dispose: (setState) => _selectedPosts.removeListener(setState),
                builder: (context, setState, state) {
                  _selectedPosts.addListener(setState);

                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      AnimatedPositioned(
                        top: _inSelectMode ? -appBarPosition : 0,
                        left: 45,
                        height: appBarHeight,
                        width: width - 100,
                        duration: _animDuration,
                        child: _appBarNormal(),
                      ), // normal mode

                      AnimatedPositioned(
                        top: _inSelectMode ? 0 : appBarPosition,
                        height: appBarHeight,
                        width: width - 60,
                        duration: _animDuration,
                        child: _appBarOptions(),
                      ), // Select mode
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBarNormal() {
    return OkiStatefulBuilder(
      dispose: (setState) => _selectedPosts.removeListener(setState),
      builder: (context, setState, state) {
        _selectedPosts.addListener(setState);

        return Row(
          children: [
            if (!_isRoot)
              _backButton(),

            Expanded(
              child: Text(_albumWatch.nome,
                maxLines: 1,
                style: const TextStyle(fontSize: 20),
              ),
            ),  // title

            if (_albumWatch.filtro.isNotEmpty)
              IconButton(
                tooltip: ui.filtroAtivado,
                icon: const Icon(Icons.filter_alt),
                onPressed: _inSelectMode ? null : () => _onFiltroClick(),
              ), // Filtro

            if (!widget.noGroup)
              Showcase(
                key: _groupBtnKey,
                title: ui.agruparPosts,
                description: ui.infoAgrupar,
                child: IconButton(
                  tooltip: ui.agruparPosts,
                  icon: Icon(usePostsGroup.value ? Icons.group_work : Icons
                      .group_work_outlined),
                  onPressed: _inSelectMode /*|| _inReorderMode.value*/ ? null : () => _onAgruparClick(),
                ),
              ), // Group

            if (_auth.isAuthenticated)...[
              if (!_isFavoritos && !_isSavedPosts && !widget.noOnline)
                Showcase(
                  key: _onlineBtnKey,
                  title: '${ui.online}/${ui.offline}',
                  description: ui.infoOnOff,
                  child: IconButton(
                    tooltip: showOnline.value ? ui.online : ui.offline,
                    icon: Icon(showOnline.value ? Icons.cloud : Icons.cloud_outlined),
                    onPressed: _inSelectMode /*|| _inReorderMode.value*/ ? null : () => _onShowOnlineClick(),
                  ),
                ), // Online
            ],

            DrawerButton(onPressed: _stafKey.currentState!.openEndDrawer),
          ],
        );
      },
    );
  }

  Widget _appBarOptions() {
    return OkiStatefulBuilder(
      dispose: (setState) => _selectedPosts.removeListener(setState),
      builder: (context, setState, state) {
        _selectedPosts.addListener(setState);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!_isRoot)
              _backButton(),

            if (_selectedPosts.value != _posts.length)
              BottomSheetItem(
                tooltip: ui.selecionarTudo,
                icon: Icons.select_all,
                onPressed: () => _onSelectAllClick(),
              ) // Select all
            else
              BottomSheetItem(
                tooltip: ui.desselecionarTudo,
                icon: Icons.border_all,
                onPressed: () => _onUnselectAllClick(),
              ), // select none

            if(showOnline.value)...[
              BottomSheetItem(
                tooltip: ui.curtir,
                icon: Icons.favorite_border,
                onPressed: _selectedPosts.value != 0 ? () => _onSavePostsClick() : null,
              ),
            ] else...[
              if (_isAnalizing())...[
                if (_inSelectMode)...[
                  if (_getSelectedPosts(false)[0].isSalvo)
                    BottomSheetItem(
                      tooltip: ui.curtir,
                      icon: Icons.favorite,
                      onPressed: _inSelectMode ? () => _onRemovePostsClick() : null,
                    )
                  else
                    BottomSheetItem(
                      tooltip: ui.curtir,
                      icon: Icons.favorite_border,
                      onPressed: _selectedPosts.value != 0 ? () => _onSavePostsClick() : null,
                    )
                ],
              ] else...[
                BottomSheetItem(
                  tooltip: ui.curtir,
                  icon: Icons.favorite,
                  onPressed: _inSelectMode ? () => _onRemovePostsClick() : null,
                ),

                  Showcase(
                    key: _unirPostsBtnKey,
                    title: ui.unirPosts,
                    description: ui.infoUnirPosts,
                    child: Builder(
                      builder: (context) {
                        if (_selectedPosts.value == 1) {
                          return BottomSheetItem(
                            tooltip: ui.desfazerGrupo,
                            icon: Icons.join_inner,
                            onPressed: _getSelectedPosts(showOnline.value)[0].isGroup
                                ? _onUnirPostsClick : null,
                          );
                        }

                        return BottomSheetItem(
                          tooltip: ui.unirPosts,
                          icon: _selectedPosts.value > 1
                              ? Icons.join_full : Icons.join_inner,
                          onPressed: _selectedPosts.value > 0
                              ? _onUnirPostsClick : null,
                        );
                      },
                    ),
                  ),

                Showcase(
                  key: _atualizarBtnKey,
                  title: ui.atualizar,
                  description: ui.infoAtualizarPost,
                  child: BottomSheetItem(
                    tooltip: ui.atualizar,
                    icon: Icons.refresh,
                    onPressed: !showOnline.value && _selectedPosts.value > 0 ? _onAtualizarPostsClick : null,
                  ),
                ), // atualizar

              ],
            ],

            Showcase(
              key: _setCapaBtnKey,
              title: ui.capaAlbum,
              description: ui.infoSetCapaPost,
              child: BottomSheetItem(
                tooltip: ui.capaAlbum,
                icon: Icons.photo_album,
                onPressed: _selectedPosts.value == 1 ? () => _onSetAlbumCapa() : null,
              ),
            ), // setCapa

          ],
        );
      },
    );
  }

  Widget _backButton() {
    return IconButton(
      tooltip: ui.voltar,
      icon: const Icon(Icons.arrow_back_ios, size: 20,),
      onPressed: () => _onPopScope(_canPop),
    );
  }

  Widget? _floatingButton() {
    if (_inProgress) {
      return const CircularProgressIndicator();
    }

    return OkiStatefulBuilder(
      dispose: (setState) => _selectedPosts.onChanged = null,
      builder: (contextt, setState, state) {
        _selectedPosts.onChanged = setState;

        if (_selectedPosts.value == 0) {
          return const SizedBox(
            width: 0,
            height: 0,
          );
        }
        return FloatingActionButton.extended(
          label: Text('(${_selectedPosts.value}) ${ui.cancelar}'),
          onPressed: () => _onPopScope(_canPop),
        );
      },
    );
  }

  Widget _menuItem(String value, {String? subtitle, bool enabled = true}) {
    subtitle ??= menuSubtitle(context, value);
    Color? color = enabled ? null : disabledTextColor;

    return ListTile(
      title: Text(value,
        style: TextStyle(color: color),
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle,
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
      leading: MenuIcon(value, size: 22),
      focusColor: color,
      onTap: enabled ? () => _onMenuItemClick(value) : null,
    );
  }

  //endregion

  //region metodos

  void _init() async {
    final album = widget.album;

    if (_isFavoritos || _isSavedPosts) {
      showOnline.value = false;
    } else if (album.isSalvo && !showOnline.value) {
      showOnline.value = !_auth.isAuthenticated;
    }

    if (widget.noGroup) {
      usePostsGroup.value = false;
    }
    if (widget.noOnline) {
      showOnline.value = false;
    }

    album.agrupar = usePostsGroup.value;

    _cAnimation = AnimationController(
      vsync: this,
      duration: _animDuration,
    );

    _setInProgress(true);
    await album.computPosts();

    if (album.isOnlineEmpty && !_isFavoritos && !_isSavedPosts) {
      if (album.isPostsEmpty) {
        showOnline.value = true;
      }
      await _updatePosts();
    }

    _updateLocalList();

    _addListeners(true);

    _setInProgress(false);

    _mostrarAvisos();
  }

  /// [blockPop] impede que o app trave ao voltar usando o botão de voltar do dispositivo
  void _onPopScope(bool value, [bool blockPop = false]) {
    if (_blockPop) return;

    if (_inSelectMode) {
      _onUnselectAllClick();
      return;
    }

    if (_albumRead.autoUpdateCapa && !_albumRead.isCapaManual) {
      _onResetCapaClick(false);
    }

    if (_isAnalizing()) {
      _albumRead.agrupar = true;
      Navigator.pop(context, _albumRead.groupList);
      return;
    }

    pref.setBool(PrefKey.showPosstsOnlineKey, showOnline.value);
    pref.setBool(PrefKey.usePostGroupsKey, usePostsGroup.value);

    if (value) {
      _albumRead.close();
      if (!blockPop) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _onRefesh({bool loadMore = false}) async {
    void onComplete() {
      _cRefresh.refreshCompleted();
      _cRefresh.loadComplete();
    }

    if ((loadMore && _albumRead.noMoreResults) || _inSelectMode) {
      onComplete();
      return;
    }

    await _updatePosts(clearData: !loadMore, showProgess: loadMore,);
    onComplete();
  }

  Future<void> _updatePosts({bool clearData = false, bool showProgess = true}) async {
    if (!showOnline.value) return;
    if (showProgess) _setInProgress(true);
    if (clearData) _onUnselectAllClick();

    final int postsCount = _posts.length;
    final int oldPage = _albumRead.maxPage;

    try {
      await _albumRead.baixarPosts(
        booru: _booru,
        clearData: clearData,
        rating: _rating,
      );
      _albunsMng.save();
    } catch(e) {
      _log.e('_updatePosts', e);
      String tags = '';
      _albumRead.tags.forEach((key, value) {
        tags += '\n$key: ${value.join(', ')}';
      });

      if (mounted) {
        Log.snack('Erro na solicitação',
          isError: true,
          actionClick: DialogBox(
            context: context,
            title: 'Detalhes',
            content: [
              const Text('Class: AlbumPage'),
              const Text('Method: updatePosts'),
              Text('Provider: $currentBooru'),
              Text('Tags: $tags'),
              const Divider(),
              Text(e.toString()),
            ],
          ).ok,
      );
      }
      _cRefresh.footerMode?.setValueWithNoNotify(LoadStatus.failed);
    }

    _updateLocalList(false);

    if (usePage) {
      final int newPage = _albumRead.maxPage;
      final int postsCount2 = _posts.length;

      if (postsCount2 == postsCount) {
        if (oldPage  < newPage) {
          _onPageChanged(_albumRead.pagination +2);
        }
      }
    }

    _setInProgress(false);
  }


  void _mostrarAvisos() async {
    await Future.delayed(_animDuration);

    if (!mounted) return;

    if (!Tutorial.postClick) {
      final size = MediaQuery.of(context).size;
      final pos = Offset(size.width / 4, size.height / 2);

      OverlayEntry? entry;
      entry = OverlayEntry(
        builder: (context) {
          Widget bloco(IconData icon, String text) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon),
                  const SizedBox(width: 5),
                  Text(text),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Positioned(
                top: pos.dy,
                left: pos.dx,
                child: Material(
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      bloco(Icons.touch_app, ui.infoPostLongTap),
                      bloco(Icons.ads_click, ui.infoPostDoubleTap),

                      ElevatedButton(
                        onPressed: () {
                          Tutorial.postClick = true;
                          entry?.remove();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      );

      Overlay.of(context).insert(entry);
    }

    if (_booru.hasExpireLinks) {
      if (Tutorial.avisoLinkExpireMostrado) return;

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(ui.aviso),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentBooru),
                  Text(ui.providerExprireTip1),
                  Text(ui.providerExprireTip2),

                  CheckboxListTile(
                    title: Text(ui.naoMostrarNovamente),
                    value: Tutorial.avisoLinkExpireMostrado,
                    onChanged: (nValue) {
                      Tutorial.avisoLinkExpireMostrado = nValue!;
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

  }

  void _setInProgress(bool b) {
    _inProgress = b;
    _setState();
  }

  void _setState() {
    if (mounted) {
      try {
        setState(() {});
      } catch(e) {
        _log.e('_onPageChanged', e);
      }
    }
  }

  //endregion

  //region menu

  Map<String, void Function()?> get menu => {
    ui.novoAlbum: _onAddAlbumClick,
    ui.favoritos: _onFavoritosClick,
    ui.postsSalvos: _onPostsSalvosClick,
    ui.editarAlbum: _onEditAlbumClick,
    ui.excluirAlbum: _onDeleteAlbumClick,
    ui.salvarAlbum: _onSaveAlbumClick,
    ui.resetCapa: _resetCapaTrue,
    ui.useAlbumAsCapa: _onUseAsCapaClick,
    ui.maturidade: _onRatingClick,
    ui.filtro: _onFiltroClick,
    ui.info: _onInfoClick,
    ui.goToPage: _onGoToPageClick,
    ui.openLink: _onOpenLinkClick,
    ui.tagsCount: _onInfoTagsClick,
    ui.updatePosts: _updatePosts,
    ui.unirPosts: _onUnirPostsClick,
    currentBooru: _onBooruClick,
  };

  void _onMenuItemClick(String value) {
    _blockPop = true;
    Navigator.pop(context);
    _blockPop = false;
    menu[value]?.call();
  }

  void _onAddAlbumClick({Album? album, bool showCustonParent = true}) async {
    void onResult(Album result) {
      if (_albumRead.containsKey(result.id)) {
        Navigate.push(context, AlbumPage(album: result));
      } else {
        Navigator.pop(context);
        Navigate.push(context, AlbumCollectionPage(album: result),
          provider: result,
        );
      }
    }

    _addListeners(false);

    var result = await Navigate.push(context, AddAlbumPage(album: album, parent: _albumRead, showCustomParent: !_isRoot && showCustonParent,));
    if (result != null && result is Album) {
      onResult(result);
    }

    _addListeners(true);
    // _setState();
  }

  void _onSaveAlbumClick() async {
    // _album.id ??= randomString();
    if (await popupSalvarAlbum(context, _albumRead, _talvezParent)) {
      // _setState();
      _albunsMng.save();
      _resetCapaTrue();
      Log.snack(ui.albumSalvo);
    }
  }

  void _onEditAlbumClick() async {
    _addListeners(false);

    final tags = _albumRead.tags.toString();
    var result = await Navigate.push(context, AddAlbumPage(album: _albumRead));
    if (result != null && result is Album) {
      if (tags != result.tags.toString()) {
        _updatePosts(clearData: true);
      } else {
        // _setState();
      }
      // Log.d(TAG, '_onAlbumEdit');
    }

    _addListeners(true);
  }

  void _onDeleteAlbumClick([Album? item]) async {
    popupDeleteAlbum(context, item ?? _albumRead).then((value) {
      if (value) {
        if(item == null) {
          Navigator.pop(context);
        } else {
          // _setState();
        }
        _albunsMng.save();
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
    _albumRead.useAsCapa();
    _albunsMng.save();
    Log.snack(ui.capaAlterada);
  }

  void _resetCapaTrue() {
    _onResetCapaClick(true);
  }

  void _onResetCapaClick(bool alowNull) {
    _albumRead.resetCapa(alowNull: alowNull);
    _albunsMng.save();
    // _setState();
  }

  void _onAutoUpdateCapaClick(bool value) {
    _albumRead.autoUpdateCapa = value;
    _albunsMng.save();
    _setState();
  }

  //------------------------------------------------------

  void _onBooruClick() => popupChangeBooru(context, currentBooru);

  void _onRatingClick() => popupChangeRating(context);

  void _onFiltroClick() async {
    var result = await Navigate.push(context, FiltroPage(
      _albumRead,
      online: showOnline.value,
      filtroAtual: _albumRead.filtro,
    ));

    if (result is OkiList<String>) {
      _albumRead.setFiltro(result.toList());
      _updateLocalList();
    }
  }


  void _onInfoClick() {
    popupAlbumInfo(context, _albumRead);
  }

  void _onInfoTagsClick() async {
    _setInProgress(true);

    final tags = _albumRead.tags[currentBooru] ?? <String>[];

    if (tags.isEmpty) {
      await DialogBox(
        context: context,
        content: [
          Text('${ui.infoTagTip} $currentBooru'),
        ],
      ).ok();
      _setInProgress(false);
      return;
    }

    int count = 0;
    if (tags.length == 1) {
      final tag = await _booruMng.booru.findTagByName(tags.first);
      count = tag?.count ?? -1;
    } else {
      count = await _booruMng.booru.findPostsCount(tags);
    }

    void popup() {
      DialogBox(
        context: context,
        dismissible: false,
        content: [
          Text(tags.join('\n')),
          const Text(''),
          if (count == -1)
            Text(ui.erroPesquisa)
          else if (count == 0)
            Text(ui.semPost)
          else
            Text('Count: $count'),
        ],
      ).ok();
    }

    popup();
    _setInProgress(false);
  }

  void _onGoToPageClick() async {
    final album = _albumRead;

   final controller = TextEditingController(text: '${album.query.page +1}');
   final controller2 = TextEditingController(text: '${album.query.eQueryIndex +1}');
   if (_booru.isEHentai) {
     controller.text = '${album.query.eQueryPage +1}';
   }

   final result = await DialogBox(
      context: context,
      dismissible: false,
      content: [
        Text(ui.buscarPostPage),
        const Text(''),
        OkiTextField(
          controller: controller,
          textInputType: TextType.numero,
          hint: ui.nPage,
        ),

        if (_booru.isEHentai)
          OkiTextField(
            controller: controller2,
            textInputType: TextType.numero,
            hint: ui.indiceBusca,
          ),
      ],
    ).cancelOK();
   if (!result.isPositive || controller.text.isEmpty) return;

   String indie = controller2.text;
   if (indie.isEmpty) indie = '0';

   if (_booru.isEHentai) {
     album.query.eQueryPage = int.parse(controller.text);
     album.query.eQueryIndex = int.parse(controller2.text);

     if (album.query.eQueryPage >= 1) album.query.eQueryPage--;
     if (album.query.eQueryIndex >= 1) album.query.eQueryIndex--;
   } else {
      album.query.page = int.parse(controller.text);
      if (album.query.page >= 1) album.query.page--;

      album.currentPage = album.query.page;
    }

   _updatePosts();
  }

  void _onOpenLinkClick() async {
    final tags = _albumRead.getTags(currentBooru);
    final ratings = _booruMng.rating.values;
    String rating = '';

    bool removeRat = false;

    switch (ratings.length) {
      case 1:
        rating = ratings.first[0];
        break;
      case 2:
        removeRat = true;
        rating += Rating.values.firstWhere((e) => !ratings.contains(e), orElse: () => '')[0];
        break;
    }

    if (rating.isNotEmpty) {
      if (rating == 's') {
        if (_booruMng.booru.options.contains(BooruOptions.generalRating)) {
          rating = 'g';
        }
      }

      if (removeRat) {
        tags.add('-rating:$rating');
      } else {
        tags.add('rating:$rating');
      }
    }

    OkiManager.i.openUrl(_booru.pageUri(tags).toString());
  }

  //region AppBar

  void _onShowOnlineClick() {
    showOnline.invert();

    if (showOnline.value && _albumRead.isOnlineEmpty) {
      _updatePosts();
    } else {
      _updateLocalList();
    }
    // _onUnselectAllPostsClick();
  }

  void _onAgruparClick() {
    usePostsGroup.invert();

    _albumRead.agrupar = usePostsGroup.value;
    _updateLocalList(false);
    _onUnselectAllClick();
  }

  // --------------------------------------- Options AppBar

  void _onSavePostsClick() async {
    final album = _albumRead;
    if (!album.isSalvo) {
      final res = await popupAlbumNaoSalvo(context, album, widget.talvezParent);
      if (!res) return;
    }

    var temp = _getSelectedPosts(true);
    final items = <Post>[];
    for (var postG in temp) {
      for (var post in postG.posts) {
        items.add(post);
      }
    }

    album.addAllPosts(items);
    _albunsMng.salvos.addAllPosts(items);

    _albunsMng.save();

    _onUnselectAllClick();
  }

  void _onRemovePostsClick() async {
    try {
      var groups = _getSelectedPosts(false);
      List<Post> items = [];
      for (var group in groups) {
        items.addAll(group.posts);
      }

      if (await popupDeletePosts(context, _albumRead, items, isAnalize: _isAnalizing())) {
        /*final itemsNoSelected = [..._posts]..removeWhere((x) => !x.isSelected);
        final first = items.first;
        Post? firstNoSelected;

        if (itemsNoSelected.isNotEmpty) {
          firstNoSelected = itemsNoSelected.first.posts.first;
        }

        if (firstNoSelected != null) {
          for (var group in itemsNoSelected) {
            for (var post in group.posts) {
              post.id = firstNoSelected.id;
            }
          }
        }*/

        // verificar se algum post está em favoritos
        for (var item in items) {
          /*if (_isAnalizing()) {
            item.parentId = first.id;
          } else */{
            final temp = _albunsMng.favoritos.getPost(item.idName);
            if (temp != null) {
              _albunsMng.favoritos.removePost(item.idName);
            }
          }
        }

        // if (_isAnalizing()) {
        //   _talvezParent?.addAllPosts(items);
        //   _talvezParent?.addAllGroups(itemsNoSelected);
        // }

        _albumRead.removeAllPosts(items);
        _albunsMng.salvos.removeAllPosts(items);

        _albumRead.updateGroups(online: false);
        _updateLocalList(false);
        _albunsMng.save();

        _onUnselectAllClick();
      }
    } catch(e) {
      Log.snack(ui.erroTenteNovamente, isError: true, actionClick: () {
        DialogBox(
          context: context,
          content: [
            Text(e.toString()),
          ],
        ).ok();
      });
    }
  }

  void _onSetAlbumCapa() async {
    try {
      if (_selectedPosts.value == 0) {
        throw (ui.semPostSelecionado);
      }
      if (_selectedPosts.value != 1) {
        throw (ui.selecioneUmPost);
      }

      Post post = _getSelectedPosts(showOnline.value).first.currentPost;

      _albumRead.setCapa(post, isManual: true);
      _albunsMng.save();
      Log.snack(ui.capaAlterada);

      _onUnselectAllClick();
    } catch (e) {
      Log.snack(e.toString(), isError: true, actionClick: DialogBox(
        context: context,
        content: [Text(e.toString())],
      ).ok);
    }
  }

  void _onUnirPostsClick() {
    final album = _albumRead;

    try {
      final selecteds = _getSelectedPosts(false);
      final first = selecteds.first;

      if (selecteds.length == 1) { // Desfazer o grupo
        for (var post in first.posts) {
          post.parentId = null;
        }
      } else { // Fazer o grupo
        for (var postG in selecteds) {
          for (var post in postG.posts) {
            post.parentId = first.id;
          }
        }
      }

      album.updateGroups(online: false);
      _updateLocalList(false);
      _selectedPosts.value = 0;
      album.saveSavedPosts();
      _albunsMng.save();
    } catch(e) {
      _log.e('_onUnirPostsClick', e);
      Log.snack(ui.erroUnirPost, isError: true, actionClick: () {
        DialogBox(
          context: context,
          content: [
            Text(e.toString()),
          ],
        ).ok();
      });
    }
  }

  void _onAtualizarPostsClick() async {
    final selecteds = _getSelectedPosts(false);

    _setInProgress(true);
    for (var post in selecteds) {
      await post.refresh();
    }
    _setInProgress(false);
  }

  void _onSelectAllClick() {
    _albumRead.setSelectedAll(showOnline.value, true);
    _selectedPosts.value = _posts.length;
  }

  void _onUnselectAllClick() {
    _albumRead.setSelectedAll(showOnline.value, false);
    _selectedPosts.value = 0;
  }

  //endregion

  //endregion

  //region listener

  void _onBooruChanged(Snapshot booru) {
    if (_albumRead.isOnlineEmpty) {
      _updatePosts();
    } else {
      _updateLocalList();
    }
  }

  void _onRattingChanged(Snapshot ratting) {
    _albumRead.updateGroups(rating: _booruMng.rating);
    _updateLocalList(false);
  }

  void _onPageChanged(value) async {
    _albumRead.pagination = value -1;

    _updateLocalList();
  }

  void _onAlbumChanged() {
    if (!showOnline.value) {
      _updateLocalList();
    }
  }

  void _refreshListener() {
    switch(_cRefresh.footerStatus) {
      case LoadStatus.idle:
        _cAnimation.reset();
        break;
      case LoadStatus.canLoading:
        break;
      case LoadStatus.loading:
        _cAnimation.repeat();
        break;
      case LoadStatus.noMore:
        Log.snack(ui.noMoreResults);
        break;
      case LoadStatus.failed:
        break;
      case null:
    }
  }

  void _addListeners(bool value) {
    final album = widget.album;

    if (value) {
      _timerScrollPosition = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentScrollPosition != _cRefresh.position?.hashCode) {
          _currentScrollPosition = _cRefresh.position?.hashCode ?? 0;

          _cRefresh.position?.addListener(_scrollListener);
        }
      });

      database.child(Childs.booru).addListener(_onBooruChanged);
      database.child(Childs.rating).addListener(_onRattingChanged);

      _cRefresh.footerMode?.addListener(_refreshListener);

      album.addListener(_onAlbumChanged);
      album.onTagsChanged = () => _updatePosts(clearData: true);
      album.onNoMoreResults = () => Log.snack(ui.noMoreResults);

      usePostsGroup.onChanged = _setState;
      showOnline.onChanged = _setState;
    } else {
      _timerScrollPosition?.cancel();
      _timerScrollPosition = null;

      database.child(Childs.booru).removeListener(_onBooruChanged);
      database.child(Childs.rating).removeListener(_onRattingChanged);

      _cRefresh.footerMode?.removeListener(_refreshListener);
      _cRefresh.position?.removeListener(_scrollListener);

      album.removeListener(_onAlbumChanged);
      album.onNoMoreResults =
      album.onTagsChanged =

      usePostsGroup.onChanged =
      showOnline.onChanged = null;
    }
  }

  /// É chamado quanto tem alteração no album
  /// se [gotoInit] == true a lista volta pro topo
  void _updateLocalList([bool gotoInit = true]) async {
    _posts.clear();
    final album = _albumRead;

    if (usePage) {
      _posts.addAll(album.getPage(showOnline.value, page: album.pagination));
    } else {
      _posts.addAll(album.getGroup(showOnline.value));
    }

    _setState();
    await Future.delayed(const Duration(milliseconds: 100));

    if (gotoInit) {
      try {
        _cRefresh.position?.animateTo(0, duration: _animDuration, curve: Curves.fastOutSlowIn);
      } catch(e) {
        _log.e('_onPageChanged', e);
      }
    }

  }

  void _scrollListener() {
    final direction = _cRefresh.position?.userScrollDirection ?? ScrollDirection.idle;
    if (direction == ScrollDirection.idle) return;

    if (direction == ScrollDirection.forward) {
      _onScrollUp();
    } else {
      _onScrollDown();
    }
  }

  void _onScrollUp() {
    if (!_showAppBar) {
      _showAppBar = true;
      appBarSetState?.call();
    }
  }

  void _onScrollDown() {
    if (_showAppBar) {
      _showAppBar = false;
      appBarSetState?.call();
    }
  }

  //endregion

  //region PostsFragment

  List<PostG> _getSelectedPosts(bool online) {
    return _albumRead.getSelectedPosts(online, true);
  }

  void _onPostTap(PostG item) async {
    final album = _albumRead;

    if ((showOnline.value && album.isOnlineEmpty) || (!showOnline.value && album.isPostsEmpty)) {
      Log.snack(ui.postsCarregando);
      return;
    }

    if (_inSelectMode) {
      item.isSelected = !item.isSelected;

      if (item.isSelected) {
        _selectedPosts.value++;
      } else {
        _selectedPosts.value--;
      }

    } else {
      int initIndex = album.indexOfPostG(item, showOnline.value);
      if (initIndex < 0) initIndex = 0;

      final currentBooru = _booru.name;
      _addListeners(false);

      final result = await Navigate.push(context, PostPage(
          showOnline: showOnline.value,
          initialIndex: initIndex,
          album: album,
          talvezParent: widget.talvezParent,
          canAnalizze: !showOnline.value,
          returnType: album.isAnalize ? List<PostG> : bool,
        ),
        heroAnim: true,
        // fullscreenDialog: true,
      );

      if (result == true) {
        album.updateGroups(online: false);
        _updateLocalList(false);
      } else if (result is List<PostG>) {
        album.clearPosts();
        album.addAllGroups(result);
        _updateLocalList(false);
      }
      _addListeners(true);

      if (currentBooru != _booru.name) {
        _onBooruChanged(Snapshot());
      }
    }
  }

  void _onPostLongTap(PostG item) async {
    if (!_enableLongPress) return;
    _enableLongPress = false;

    _postPopupEntry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final post = item.getAt(0)!;

        MediaController? video;
        if (post.isVideo) {
          video = MediaController();
          // video.open(url: post.fileUrl, mute: videoIsMute);
        }

        Future<void>? loading;

        return Material(
          color: Colors.black.withOpacity(opacityAnimation.value),
          child: OkiStatefulBuilder(
            dispose: (setState) {
              _popupAnimController.removeListener(setState);
            },
            initialize: (setState) {
              _popupAnimController.addListener(setState);
              _popupAnimController.forward();
            },
            builder: (context, setState, state) {
              return Center(
                child: FadeTransition(
                  opacity: scaleAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Container(
                        height: size.height,
                        width: size.width,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            child: Container(
                              color: backgroundColor,
                              child: OkiStatefulBuilder(
                                dispose: (setSatte) {
                                  video?.pause();
                                  video?.dispose();
                                },
                                initialize: (setState) {
                                  Future<void> temp() async {
                                    await post.custonLoad();
                                    video?.open(
                                      url: post.fileUrl,
                                      mute: videoIsMute,
                                      headers: post.booru.headers,
                                    );
                                    setState();
                                  }
                                  loading ??= temp();
                                },
                                builder: (context, setState, state) {
                                  return FutureBuilder(
                                    future: loading,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState != ConnectionState.done) {
                                        const Center(child: CircularProgressIndicator());
                                      }

                                      final ratio = post.aspectRatio ?? post.aspectRatioPreview ?? 1.0;

                                      return AspectRatio(
                                        aspectRatio: ratio,
                                        child: Stack(
                                          children: [
                                            ImageWidet(
                                              post: post,
                                              onLoadComplete: (post) {
                                                post.computeDimension();
                                              },
                                            ),

                                            if (post.isVideo && video!.isLoaded)...[
                                              Center(child: PlayerVideo(
                                                player: video,
                                                aspectRatio: ratio,
                                              )),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    Overlay.of(context).insert(_postPopupEntry!);
  }

  void _onPostLongTapUp(PostG item) {
    _popupAnimController.reverse().then((o) {
      _postPopupEntry?.remove();
      _enableLongPress = true;
    });
  }

  void _onPostDoubleTap(PostG item) {
    if (_isFavoritos || _isSavedPosts || _inProgress || !_auth.isAuthenticated) return;

    if (!item.isSelected) {
      _selectedPosts.value++;
      item.isSelected = true;

      if (!showOnline.value) {


        List<GlobalKey> prepareKeys() {
          final items = <GlobalKey>[];

          if (!Tutorial.unirPosts) {
            Tutorial.unirPosts = true;
            items.add(_unirPostsBtnKey);
          }

          if (!Tutorial.atualizarPost) {
            Tutorial.atualizarPost = true;
            items.add(_atualizarBtnKey);
          }

          if (!Tutorial.setCapaPost) {
            Tutorial.setCapaPost = true;
            items.add(_setCapaBtnKey);
          }

          return items;
        }

        final keys = prepareKeys();
        if (keys.isNotEmpty) {
          Future.delayed(_animDuration, () {
            ShowCaseWidget.of(context3).startShowCase(keys);
          });
        }
      }
    }
  }

  //endregion

}