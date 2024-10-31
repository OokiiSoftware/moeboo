import 'dart:async';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../util/util.dart';
import '../fragments/import.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../res/import.dart';
import '../oki/import.dart';
import 'import.dart';

/// Não uso o PopScope ao voltar pq causa bug na versão release
class PostPage extends StatefulWidget {
  final bool showOnline;
  final Album album;
  final Album? talvezParent;
  final int initialIndex;
  final bool canAnalizze;
  // final BuildContext context;
  final Type? returnType;
  const PostPage({
    // required this.context,
    required this.album,
    this.showOnline = false,
    this.canAnalizze = true,
    this.initialIndex = 0,
    this.talvezParent,
    this.returnType, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PostPage> with SingleTickerProviderStateMixin {

  //region variaveis

  static const _log = Log('PostPage');
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  static MediaController video = MediaController();

  late BuildContext context3;

  IBooru get _booru => BooruProvider.i.booru;
  AuthManager get _auth => AuthManager.auth;
  AlbunsProvider get _albunsMng => AlbunsProvider.i;

  late List<PostG> _postsList;
  // final Map<int, Post> _postsControllers = {};

  Album get _album => widget.album;
  int get initialIndex => widget.initialIndex;

  final Duration _animDuration = const Duration(milliseconds: 500);
  late PageController _pageControllerH;
  late AnimationController _animPlayButton;

  final _pageControllerV = PageController(initialPage: 1);
  final _transitionController = TransformationController();
  final _tagsController2 = ScrollController();

  final backgroundColor = const Color.fromRGBO(46, 46, 46, 1);
  final _iconColor = Colors.white;

  String get _currentBooruName => _currentPost.booruName ?? '';

  PostG get _currentGroup => _postsList[_currentPageHIndex];
  Post get _currentPost => _currentGroup.currentPost;
  // Post? get _oldPost => _data[_oldPageIndex].currentPost;

  bool _pageBlock = false;
  bool _inProgress = false;
  bool _backgroundTransparent = false;
  bool _showingAppBarCache = true;
  bool _isplayng = false;
  bool _imgCompressCompleted = false;

  int _currentPageHIndex = 0;
  int _currentPageVIndex = 1;
  int _oldPageIndex = 0;
  int _qualityImage = 2;

  final OkiBool _showAppBar = OkiBool(true);

  Timer? _timer;
  dynamic _popResult;

  ILanguage get ui => idioma;

  final _tagsBtnKey = GlobalKey();
  final _favBtnKey = GlobalKey();
  final _saveBtnKey = GlobalKey();
  final _likeBtnKey = GlobalKey();
  final _qualitBtnKey = GlobalKey();

  //endregion

  //region widgets

  @override
  void dispose() {
    _pageControllerV.removeListener(_pageControllerVListener);
    video.pause();

    super.dispose();
    _pageControllerH.dispose();
    _pageControllerV.dispose();
    _tagsController2.dispose();

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    _transitionController.dispose();
    // _postsControllers.forEach((key, value) {
      // value.video?.dispose();
      // value.video = MediaController();
    // });
  }

  @override
  void initState() {
    super.initState();
    _postsList = _album.getGroup(widget.showOnline);

    _currentPageHIndex = initialIndex;
    _pageControllerH = PageController(initialPage: initialIndex);
    _animPlayButton = AnimationController(vsync: this, duration: _animDuration);

    List<GlobalKey> prepareKeys() {
      final items = <GlobalKey>[];

      if (!Tutorial.postPageTags) {
        Tutorial.postPageTags = true;
        items.add(_tagsBtnKey);
      }

      if (!Tutorial.postPageLike) {
        Tutorial.postPageLike = true;
        items.add(_likeBtnKey);
      }

      if (!Tutorial.postPageQualit) {
        Tutorial.postPageQualit = true;
        items.add(_qualitBtnKey);
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
    if (_postsList.isEmpty) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: _drawerE(_currentPost),
      endDrawer: _drawerD(_currentPost),
      drawerEdgeDragWidth: size.width / 6,
      drawerEnableOpenDragGesture: true,
      drawerScrimColor: Colors.transparent,
      body: Stack(
        children: [
          _body(),
          // _debug(),
          _appBar(_currentPost),  // AppBar
          _bottomAppBar(_currentPost),
        ],
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  // ignore: unused_element
  Widget _debug() {
    final size = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        height: 200,
        width: size,
        color: Colors.white,
        margin: const EdgeInsets.only(top: 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('DEBUG'),

              Text('Posts Count: ${_postsList.length}'),
              const Divider(),
              Builder(builder: (context) {
                try {
                  return Text('pageControllerV: ${_pageControllerV.page}');
                } catch(e) {
                  return Text('pageControllerV: $e');
                }
              }),
              const Divider(),
              Builder(builder: (context) {
                try {
                  return Text('tagsController2: ${_tagsController2.offset}');
                } catch(e) {
                  return const Text('tagsController2: null');
                }
              }),
              const Divider(),
              Text('_pageBlock: $_pageBlock'),
              Text('_inProgress: $_inProgress'),
              Text('_backgroundTransparent: $_backgroundTransparent'),
              Text('_showingAppBarCache: $_showingAppBarCache'),
              Text('_isplayng: $_isplayng'),
              Text('_imgCompressCompleted: $_imgCompressCompleted'),
              Text('_currentPageHIndex: $_currentPageHIndex'),
              Text('_currentPageVIndex: $_currentPageVIndex'),
              Text('_oldPageIndex: $_oldPageIndex'),
              Text('_qualityImage: $_qualityImage'),
              Text('_showAppBar: ${_showAppBar.value}'),
              const Divider(),
              Text('_timer: ${_timer?.tick}'),
              Text('_popResult: $_popResult'),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return PageView.builder(
      controller: _pageControllerH,
      itemCount: _postsList.length,
      physics: _pageBlock ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: _onPageHChanged,
      itemBuilder: (context, index) => _viewPage(_postsList[index], _postsList[index].currentPost),
    );
  }

  Widget _appBar(Post post) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
    );
    return AnimatedPositioned(
      duration: _animDuration,
      top: _showAppBar.value ? 0 : -100,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, -15),
                blurRadius: 50,
              ),
            ],
          ),
          height: 50,
          child: Row(
            children: [
              const SizedBox(width: 10),

              IconButton(
                tooltip: ui.voltar,
                icon: Icon(Icons.arrow_back_ios,
                  color: _iconColor,
                  size: 20,
                ),
                onPressed: _pop,
              ),  // backButton

              OkiShadowText(_currentBooruName,
                style: textStyle,
              ),  // Booru Name

              if (!_booru.isEHentai && !_booru.isDeviant)
                OkiShadowText(' [${post.id}]',
                  style: textStyle,
                ),  // Post ID

              OkiShadowText(' (${_currentPageHIndex +1}/${_postsList.length})',
                style: textStyle,
              ),  // Posts Count
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerE(Post post) {
    return Drawer(
      backgroundColor: backgroundColor.withOpacity(0.5),
      child: _tagsLayout(post),
    );
  }

  Widget _drawerD (Post post) {
    Map<String, bool> items = {
      ui.wallpaper: !post.isVideo,
      ui.capaAlbum: _album.isSalvo && !_album.isSalvos,
      ui.share: true,
      ui.openLink: true,
      ui.findParents: true,
      ui.refreshPost: true,

      if (_currentGroup.isGroup)
        ui.refreshGroup: true,

      // if (_currentGroup.isGroup)
      //   ui.analizarGrupo: widget.canAnalizze,

      if (_currentGroup.isGroup)
        ui.removeDoGrupo: widget.canAnalizze,

      ui.recriarMiniatura: post.isSalvo,

      ui.excluirImagem: post.hasAnyFile || post.hasAnyPreview,
    };
    final list = items.keys.toList();

    return Drawer(
      backgroundColor: backgroundColor.withOpacity(0.5),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 40),
        itemCount: list.length,
        reverse: true,
        itemBuilder: (context, i) {
          final item = list[i];
          bool enabled = items[item]!;

          final color = enabled ? Colors.white : Colors.white30;

          return ListTile(
            textColor: color,
            iconColor: color,
            title: Text(item),
            leading: MenuIcon(item),
            onTap: enabled ? () {
              Navigator.pop(context);
              _onMenuItemClick(item);
            } : null,
          );
        },
      ),
    );
  }

  Widget _bottomAppBar(Post post) {
    final width = MediaQuery.of(context).size.width;
    final isSalvo = post.isSalvo;
    const tintColor = Colors.white;

    IconData? iconQuality() {
      switch(_qualityImage) {
        case 0:
          return Icons.hd_outlined;
        case 1:
          return Icons.hd;
        default:
          return Icons.motion_photos_auto;
      }
    }

    return AnimatedPositioned(
      duration: _animDuration,
      bottom: _showAppBar.value ? 0 : -100,
      child: ShowCaseWidget(
        builder: (context) {
          context3 = context;
          return SafeArea(
            child: Container(
              height: 40,
              width: width,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 15),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Showcase(
                    key: _tagsBtnKey,
                    title: ui.tags,
                    description: ui.infoTags,
                    child: IconButton(
                      tooltip: ui.tags,
                      icon: const Icon(Icons.flag, color: tintColor),
                      onPressed: () => _click(() => _onMenuClick(false)),
                    ),
                  ),  // Tags

                  if (_auth.isAuthenticated)...[
                    if (isSalvo)...[
                      Showcase(
                        key: _favBtnKey,
                        title: ui.favoritos,
                        description: ui.infoFav,
                        child: IconButton(
                          tooltip: ui.favoritos,
                          icon: Icon(post.isFavorito? Icons.bookmark : Icons.bookmark_border, color: tintColor),
                          onPressed: () => _click(_onFavoritoClick),
                        ),
                      ), // Favorito
                      Showcase(
                        key: _saveBtnKey,
                        title: ui.salvarOffline,
                        description: ui.infoSave,
                        child: IconButton(
                          tooltip: ui.salvarOffline,
                          icon: const Icon(Icons.download, color: tintColor),
                          onPressed: () => _click(_onDownloadClick),
                        ),
                      ), // Salvar post offline
                    ],

                    if (!_album.isSalvos)
                      Showcase(
                        key: _likeBtnKey,
                        title: ui.curtir,
                        description: ui.infoLike,
                        child: IconButton(
                          tooltip: ui.curtir,
                          icon: Icon(isSalvo ? Icons.favorite : Icons.favorite_border, color: tintColor),
                          onPressed: () => _click(isSalvo ? _onRemoveClick : _onSaveClick),
                        ),
                      ), // Salvar/Remover
                  ],

                  Showcase(
                    key: _qualitBtnKey,
                    title: ui.qualidade,
                    description: ui.infoQualit,
                    child: IconButton(
                      tooltip: ui.qualidade,
                      icon: Icon(iconQuality(), color: tintColor),
                      onPressed: () => _click(_onQualityClick),
                    ),
                  ), // Qualidade da imagem

                  IconButton(
                    tooltip: ui.mais,
                    icon: const Icon(Icons.more_vert, color: tintColor),
                    onPressed: () => _click(() => _onMenuClick(true)),
                  ), // Menu
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _floatingButton() {
    Widget widget(Widget child) {
      return Padding(
        padding: EdgeInsets.only(bottom: _currentPost.isVideo ? 120 : 60),
        child: child,
      );
    }

    if (_inProgress) {
      return widget(CircularProgressIndicator(key: GlobalKey(debugLabel: 'uUGyg'),));
    }

    if (isDesktop) {
      Widget clip (IconData icon, String tooltip, void Function() onTap) {
        return AbsorbPointer(
          absorbing: !_showAppBar.value,
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 70,
                ),
              ],
            ),
            child: IconButton(
              tooltip: tooltip,
              icon: Icon(icon),
              color: Colors.white,
              onPressed: () => _click(onTap),
            ),
          ),
        );
      }

      return widget(AnimatedOpacity(
        opacity: _showAppBar.value ? 1 : 0,
        duration: _animDuration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            clip(Icons.keyboard_arrow_left, ui.anterior, _onPreviewClick,),
            clip(Icons.keyboard_arrow_right, ui.proximo, _onNextClick,),
          ],
        ),
      ));
    }

    return null;
  }

  /// Foto
  Widget _viewPage(PostG group, Post post) {
    double progressValue = 0;

    return CustomPageView(
      viewportDirection: false,
      controller: _pageControllerV,
      scrollDirection: Axis.vertical,
      physics: _pageBlock ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: _onPageVChanged,
      children: [
        Container(),
        OkiStatefulBuilder(
          builder: (context, setState, state) {
            final image = Hero(
              tag: post.idName,
              child: AnimatedSwitcher(
                duration: _animDuration,
                child: ImageWidet(
                  key: ValueKey(post.id),
                  post: post,
                  index: _qualityImage,
                  loadingProgress: (p) {
                    progressValue = p.cumulativeBytesLoaded / (p.expectedTotalBytes ?? 1);
                    _imgCompressCompleted = false;
                    setState(const Duration(milliseconds: 200));
                  },
                  onLoadComplete: (post) {
                    if (_imgCompressCompleted) return;
                    progressValue = 0;

                    setState(const Duration(milliseconds: 200));
                    _onImageLoadingComplete(post);
                    _imgCompressCompleted = true;
                  },
                ),
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: child,
                  );
                },
              ),
            );

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
              color: _backgroundTransparent ? Colors.transparent : backgroundColor,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    PinchZoom(
                      onTap: _handleTap,
                      onZoom: _onZoomChange,
                      maxScale: _getMaxZoom(),
                      child: Stack(
                        children: [
                          image,

                          if (post.isVideo && video.isLoaded)...[
                            Center(child: PlayerVideo(
                              player: video,
                              aspectRatio: post.aspectRatio,
                            )),
                          ],
                        ],
                      ),
                    ),

                    if (progressValue != 0 && progressValue != 1)
                      LinearProgressIndicator(
                        value: progressValue,
                      ),

                    if (post.isVideo && video.isLoaded)...[
                      _videoPlayerControl(post),
                    ],
                  ],
                ),
                floatingActionButton: group.isGroup && _showAppBar.value ?
                Padding(
                  padding: EdgeInsets.only(bottom: post.isVideo ? 100 : 60),
                  child: FloatingActionButton(
                    onPressed: () => _click(_onSwithPostClick),
                    child: Text('${group.currentView +1}/${group.length}'),
                  ),
                ) : null,
                floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
              ),
            );
          },
        ),
        _tagsLayout(_currentPost, opaco: true),
      ],
    );
  }

  Widget _tagsLayout(Post post, {bool opaco = false}) {
    return TagsListView(
      post: post,
      textColor: Colors.white,
      backgroundColor: opaco ? backgroundColor : Colors.transparent,
      controller: _tagsController2,
      physics: const BouncingScrollPhysics(),
      onTap: _onTagClick,
      // onLongPress: _auth.isAuthenticated ? _onTagLongClick : null,
      onAddClick: _album.isSalvo && _auth.isAuthenticated ? (tag) => _onAddTagClick(false, tag) : null,
      onRemoveClick: _album.isSalvo && _auth.isAuthenticated ? (tag) => _onAddTagClick(true, tag) : null,
    );
  }

  Widget _videoPlayerControl(Post post) {
    if (!video.isLoaded) {
      return Container();
    }

    final width = MediaQuery.of(context).size.width;

    IconButton volumeButton(void Function(bool)? onPressed) {
      return IconButton(
        padding: const EdgeInsets.only(right: 5),
        color: tintColor,
        icon: Icon(videoIsMute ? Icons.volume_off : Icons.volume_up),
        onPressed: () {
          videoIsMute = !videoIsMute;
          onPressed?.call(videoIsMute);
          _setState();
        },
      );
    }

    return AnimatedPositioned(
      duration: _animDuration,
      bottom: _showAppBar.value ? 50 : -100,
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: StreamBuilder(
          stream: video.positionStream,
          builder: (context, snapshot) {
            var videoDuration = video.duration;
            var videoPosition = video.position;

            try {
              return Stack(
                children: [
                  Positioned(
                    left: 65,
                    child: Text(videoPosition.toString().substring(0, 7),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),  // Tempo atual
                  Positioned(
                    right: 65,
                    child: Text(videoDuration.toString().substring(0, 7),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),  // Tempo total

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          video.playOrPause();

                          if (video.isPlaying) {
                            _animPlayButton.reverse();
                          } else {
                            _animPlayButton.forward();
                          }
                        },
                        padding: const EdgeInsets.only(left: 5),
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: _animPlayButton,
                          color: tintColor,
                          // size: 70,
                        ),
                      ),  // play / pause

                      Expanded(
                        child: Slider(
                          value: videoPosition.inSeconds.toDouble(),
                          max: videoDuration.inSeconds.toDouble(),
                          mouseCursor: SystemMouseCursors.click,
                          thumbColor: Colors.transparent,
                          onChanged: (value) {
                            video.seek(Duration(seconds: value.toInt()));
                          },
                          onChangeStart: (value) {
                            _cancelTimer();
                            _isplayng = video.isPlaying;
                            video.pause.call();
                            _setState();
                          },
                          onChangeEnd: (value) {
                            _initTimer();
                            if (_isplayng) {
                              video.play.call();
                            }
                            _setState();
                          },
                        ),
                      ),

                      volumeButton(video.setMute),
                    ],
                  ),  // Slider
                ],
              );
            } catch(e) {
              _log.e('_videoPlayerControl', e, videoDuration.inSeconds, videoPosition.inSeconds);
              return Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(ui.ocorreuUmErro,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  //endregion

  //region metodos

  void _init() async {
    _pageControllerV.addListener(_pageControllerVListener);

    _showAppBar.onUpdate = _setState;

    if (!Tutorial.postPageSlide) {
      Tutorial.postPageSlide = true;

      void popup() {
        const style = TextStyle(fontSize: 20, color: Colors.white);
        DialogFullScreen(
            context: context,
            alignment: MainAxisAlignment.center,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OkiShadowText(ui.tipVoltar,
                  style: style,
                  center: true,
                  maxLines: 2,
                ),
                const Icon(Icons.arrow_downward, color: Colors.white,),

                const SizedBox(height: 20,),
                const Divider(),
                const SizedBox(height: 20,),

                const Icon(Icons.arrow_upward, color: Colors.white,),
                OkiShadowText(ui.tipTags,
                  style: style,
                  center: true,
                  maxLines: 2,
                ),

                const SizedBox(height: 100,),
              ],
            )
        ).show();
      }

      await Future.delayed(const Duration(milliseconds: 200));
      popup();
    }

    _initTimer();

    _setInProgress(true);
    await _currentPost.custonLoad();
    _setInProgress(false);
    _setVideoPlayer();
  }

  // ignore: unused_element
  void _onPopScope(bool value) async {
    if (!value) {
      _pageControllerV.animateToPage(1,
        duration: const Duration(milliseconds: 200),
        curve: const SawTooth(1),
      );
      return;
    }

    _pop();
  }

  void _pop() {
    try {
      Navigator.pop(context, _popResult);
    } catch(e) {
      //
    }
  }

  Future<void> _setFullScreen(bool value) async {
    await ThemeManager.i.setFullScreen(value);
  }


  double _getMaxZoom() {
    final p = _currentPost;
    double v = 0;
    final width = p.width ?? 1;
    final height = p.height ?? 1;

    if (height > width) {
      v = height / width;
    } else {
      v = width / height;
    }

    int base = 1;
    if (height > 6000 || width > 6000) {
      base = 18;
    } else if (height > 5000 || width > 5000) {
      base = 14;
    } else if (height > 4000 || width > 4000) {
      base = 10;
    } else if (height > 3000 || width > 3000) {
      base = 7;
    } else if (height > 2000 || width > 2000) {
      base = 5;
    } else if (height > 1000 || width > 1000) {
      base = 3;
    }

    return v * base;
  }

  void _setVideoPlayer() {
    if (!_currentPost.isVideo) return;

    /*if (video.isLoaded) {
      video.play();
    } else*/ {
      video.open(url: _currentPost.fileUrl ?? '', mute: videoIsMute, headers: _currentPost.booru.headers);
      // _postsControllers[_currentPost.id] = _currentPost;
      _animPlayButton.forward();
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
        //
      }
    }
  }

  //endregion

  //region click

  void _click(void Function() click) {
    click.call();

    _cancelTimer();
    _initTimer();
  }

  void _onSwithPostClick() {
    _currentGroup.nextPost();

    _setVideoPlayer();

    _onPageHChanged(_currentPageHIndex);
  }

  void _onTagClick(Tag tag) async {
    Album searchAlbum = Album(
      id: randomString(),
      nome: tag.toName(),
    )..tags.addAll({currentBooru: [tag.name]});

    _setFullScreen(false);
    await Navigate.push(context, AlbumPage(album: searchAlbum, talvezParent: _album));
    _setFullScreen(!_showAppBar.value);
  }

  // ignore: unused_element
  void _onTagLongClick(Tag tag) async {
    popupBloquearTag(context, tag.name);
  }

  void _onAddTagClick(bool negative, Tag tag) async {
    Album? parent = _album.parent;
    String finalTag = negative ? '-${tag.name}' : tag.name;

    Album newAlbum(Album? parent, int result) {
      var temp = Album(
        id: randomString(),
        nome: tag.toName(remove: '(${parent?.nome})'),
        parent: parent,
      );
      temp.addTag(currentBooru, finalTag);

      if (result == DialogResult.positiveValue) {
        final provider = currentBooru;
        _album.tags[provider]?.forEach((tag) {
          temp.addTag(provider, tag);
        });
      }
      return temp;
    }

    Future<int> addTags() async {
      var result = await DialogBox(
        dismissible: false,
        context: context,
        content: [
          Text(ui.addTagsAtual),
        ],
      ).simNaoCancel();
      return result.value;
    }

    DialogBox(
      context: context,
      title: '${negative ? ui.bloquear : ui.adicionar} ${ui.aTagEm}..',
      content: [
        if (!_album.isFavoritos && !_album.isSalvos)
          TagItem(
            text: _album.nome,
            subText: ui.albumAtual,
            onTap: () {
              _album.addTag(currentBooru, finalTag);
              Log.snack(ui.tagAdicionada);
              Navigator.pop(context);
            },
          ),
        if (!negative)...[
          TagItem(
            text: ui.criarNovoAlbum,
            subText: ui.naPastaRaiz,
            onTap: () async {
              int v = await addTags();
              if (v < 0) return;

              var album = newAlbum(null, v);
              _albunsMng.album.add(album);
              Log.snack(ui.albumCriado);
              _pop();
            },
          ),
          if (parent != null && parent.id != AlbunsProvider.rootId)...[
            TagItem(
              text: ui.criarNovoAlbum,
              subText: '${ui.em} ${parent.nome}',
              onTap: () async {
                int v = await addTags();
                if (v < 0) return;

                var album = newAlbum(parent, v);
                parent.add(album);
                Log.snack(ui.albumCriado);
                _pop();
              },
            ),
          ],
        ],

        const Divider(),
        for (var a in (parent?.values.toList() ?? <Album>[])
          ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase())))
          if (_album.id != a.id)
            TagItem(
              text: '- ${a.nome}',
              subText: '- ${negative ? ui.bloquear : ui.add} ${ui.nesteAlbum}',
              onTap: () {
                a.addTag(currentBooru, finalTag);
                Log.snack(ui.tagAdicionada);
                Navigator.pop(context);
              },
            ),
      ],

    ).cancel();
  }

  void _onPreviewClick() {
    _pageControllerH.animateToPage(
      _currentPageHIndex-1,
      duration: _animDuration,
      curve: Curves.linear,
    );
  }

  void _onNextClick() {
    _pageControllerH.animateToPage(
      _currentPageHIndex+1,
      duration: _animDuration,
      curve: Curves.linear,
    );
  }


  void _handleTap() {
    _showAppBar.value = !_showAppBar.value;

    _cancelTimer();
    _initTimer();

    _setFullScreen(!_showAppBar.value);
    _setState();
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  void _initTimer() {
    _timer = Timer(Duration(seconds: _currentPost.isVideo ? 5 : 30), () {
      _showAppBar.value = false;
      _timer?.cancel();
    });
  }

  //endregion

  //region listener

  void _onZoomChange(value) {
    _pageBlock = value > 2;
    _setState();
  }

  void _onPageHChanged(int i) {
    _oldPageIndex = _currentPageHIndex;
    _currentPageHIndex = i;
    _setInProgress(true);
    _currentPost.custonLoad().then((value) {
      _setInProgress(false);
      _setVideoPlayer();
    });

    // _oldPost?.video?.pause();
    _setState();
  }

  void _onPageVChanged(int i) {
    _currentPageVIndex = i;
    if (i == 0) {
      _pop();
      _setFullScreen(false);
    }
    _setState();
  }

  void _pageControllerVListener() {
    if (!_showingAppBarCache) {
      _showingAppBarCache = _showAppBar.value;
    }

    if (_pageControllerV.page == 1) {
      final b = _backgroundTransparent;
      _backgroundTransparent = false;

      if (_showingAppBarCache) {
        _showAppBar.value = true;
      }
      _showingAppBarCache = false;
      if (b) {
        _setState();
      }
    }
    else if ((_pageControllerV.page ?? 0) > 1) {
      if (_showAppBar.value) {
        _showAppBar.value = false;
      }
    }
    else {
      if (_backgroundTransparent) return;

      _backgroundTransparent = (_pageControllerV.page ?? 0) < 1;
      _showAppBar.value = false;
    }
  }

  void _onImageLoadingComplete(Post item) {
    item.computeDimension();
    if (criarPreviewsDeQualidade && item.isSalvo) {
      item.compressPreview();
    }
  }

  //endregion

  //region Menu

  void _onMenuClick(bool endDrawer) {
    if (endDrawer) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  Map<String, void Function()?> get menu => {
    ui.capaAlbum: _onSetAlbumCapaClick,
    ui.wallpaper: _onWallpaperClick,
    ui.openLink: _onOpenLinkClick,
    ui.findParents: _onFindParentsClick,
    ui.refreshGroup: _onRefreshGroupClick,
    ui.refreshPost: _onRefreshPostClick,
    ui.share: _onShareClick,
    ui.sobrescrever: _onSobrescreverDadosClick,
    ui.analizarGrupo: _onAnalizarGrupoClick,
    ui.removeDoGrupo: _onRemoveDoGrupoClick,
    ui.recriarMiniatura: _onRecriarMiniaturaClick,
    ui.excluirImagem: _popupDeletePostDispositivo,
  };

  void _onMenuItemClick(String value) {
    menu[value]?.call();

    // switch(value) {
    //   case Menus.capaAlbum:
    //     _onSetAlbumCapaClick();
    //     break;
    //   case Menus.wallpaper:
    //     _onWallpaperClick();
    //     break;
    //   case Menus.openLink:
    //     _onOpenLinkClick();
    //     break;
    //   case Menus.findParents:
    //     _onFindPParentsClick();
    //     break;
    //   case Menus.refreshGroup:
    //     _onRefreshGroupClick();
    //     break;
    //   case Menus.refreshPost:
    //     _onRefreshPostClick();
    //     break;
    //   case Menus.share:
    //     _onShareClick();
    //     break;
    //   case Menus.sobrescrever:
    //     _onSobrescreverDadosClick();
    //     break;
    //   case Menus.analizarGrupo:
    //     _onAnalizarGrupoClick();
    //     break;
    //   case Menus.removeDoGrupo:
    //     _onRemoveDoGrupoClick();
    //     break;
    //   case Menus.recriarMiniatura:
    //     _onRecriarMiniaturaClick();
    //     break;
    //   case Menus.excluirImagem:
    //     popupDeletePostDispositivo(context, _currentPost);
    //     break;
    // }
  }

  //--------------------------------------------

  void _onFavoritoClick() {
    if (_albunsMng.favoritos.getPost(_currentPost.idName) == null) {
      _albunsMng.favoritos.addPost(_currentPost);
    } else {
      _albunsMng.favoritos.removePost(_currentPost.idName);
    }

    _albunsMng.save();
    _setState();
  }

  void _onDownloadClick() async {
    final result = await _selectQuality();
    if (result < 0 || result > 2) return;
    _onDownloadClickAux(result == 1);
  }

  void _onDownloadClickAux([bool originalPost = false]) async {
    // if (_album.id != AlbunsProvider.favoritosId && _album.id != AlbunsProvider.salvosId && !_album.isSalvo) {
    //   _msgAlbumNaoSalvo();
    //   return;
    // }

    if (_booru.isSankaku && originalPost) {
      Log.snack(ui.postNaoCarregado, isError: true);
      return;
    }

    String? result = await _currentPost.savePostFile(original: originalPost);
    if (result == null) {
      _setState();
      Log.snack(ui.postSalvo);
    } else {
      Log.snack(result, isError: true);
    }
  }

  void _onSaveClick() async {
    if (!_album.isSalvo) {
      final res = await popupAlbumNaoSalvo(context, _album, widget.talvezParent);
      if (!res) return;
    }

    _currentPost.album.addPost(_currentPost);
    _albunsMng.salvos.addPost(_currentPost);

    if (!_album.isAnalize) {
      _albunsMng.save();
    }

    _onRecriarMiniaturaClick();
    _setState();

    List<GlobalKey> prepareKeys() {
      final items = <GlobalKey>[];

      if (!Tutorial.postPageFav) {
        Tutorial.postPageFav = true;
        items.add(_favBtnKey);
      }

      if (!Tutorial.postPageSave) {
        Tutorial.postPageSave = true;
        items.add(_saveBtnKey);
      }

      return items;
    }

    final keys = prepareKeys();
    if (keys.isNotEmpty) {
      if (!_showAppBar.value) {
        _showAppBar.value = true;
        await Future.delayed(_animDuration);
      }

      if (context3.mounted) {
        // ignore: use_build_context_synchronously
        ShowCaseWidget.of(context3).startShowCase(keys);
      }
    }

  }

  void _onRemoveClick() async {
    if (await popupDeletePosts(context, _currentPost.album, [_currentPost])) {
      // _currentPost.isFavorito = false;
      if (_currentPost.isFavorito) {
        _albunsMng.favoritos.removePost(_currentPost.idName);
      }
      _album.removePost(_currentPost.idName);
      _albunsMng.salvos.removePost(_currentPost.idName);

      if (!widget.showOnline) {
        _currentGroup.remove(_currentPost.id);
        if (_currentGroup.isEmpty) {
          _postsList.remove(_currentGroup);
        }

        final type = widget.returnType;
        if (type == bool) {
          _popResult = true;
        } else if (type == List<PostG>) {
          _popResult = _album.groupList;
        }

        if (_postsList.isEmpty) {
          _pop();
          return;
        }

        if (_currentPageHIndex >= _postsList.length) {
          _currentPageHIndex = _postsList.length - 1;
        }

        _currentGroup.previousPost();
      }
      if (!_album.isAnalize) {
        _albunsMng.save();
      }
      _setState();
    }
  }

  void _onQualityClick() {
    _qualityImage++;
    if (_qualityImage == 3) _qualityImage = 0;

    _setState();
  }

  void _popupDeletePostDispositivo() {
    popupDeletePostDispositivo(context, _currentPost);
  }

  //--------------------------------------------

  void _onSetAlbumCapaClick() async {
    if (_album.isAnalize) return;

    try {
      _album.setCapa(_currentPost, isManual: true);
      _album.saveSavedPosts();
      _albunsMng.save();
      Log.snack(ui.capaAlterada);
    } catch(e) {
      Log.snack(ui.capaNaoAlterada, isError: true);
    }
  }

  void _onWallpaperClick() async {
    await popupSetWallpaper(context, _currentPost);
  }

  //--------------------------------------------

  void _onFindParentsClick() async {
    _setInProgress(true);
    if (await _currentGroup.findParents()) {
      _album.saveSavedPosts();
      _albunsMng.save();
    }
    _setInProgress(false);
  }

  void _onRefreshGroupClick() async {
    _setInProgress(true);
    if (await _currentGroup.refresh()) {
      _album.saveSavedPosts();
      _albunsMng.save();
    }
    _setInProgress(false);
  }

  void _onRefreshPostClick() async {
    _setInProgress(true);

    try {
      await _currentPost.refresh();
      _album.saveSavedPosts();
      _albunsMng.save();
    } catch(e) {
      _log.e('onRefreshPostClick', e);
      Log.snack(ui.postNaoAtualizado, isError: true, actionClick: () {
        DialogBox(
          context: context,
          content: [
            Text(e.toString()),
          ],
        ).ok();
      });
    }

    _setInProgress(false);
  }

  //--------------------------------------------

  void _onShareClick() async {
    try {
      void onError(e) {
        DialogBox(
          context: context,
          title: ui.erroCompartilhar,
          content: [
            Text(e.toString()),
          ],
        ).ok();
      }

      String? filePath;
      if (_currentPost.hasPostSampleFile) {
        filePath = _currentPost.postSampleFile.path;
      } else if (_currentPost.hasPostOriginalFile) {
        filePath = _currentPost.postOriginalFile.path;
      } else if (_currentPost.hasPostSalvoFile) {
        filePath = _currentPost.postSalvoFile.path;
      }

      if (filePath == null) throw (ui.imgNaoCarregada);

      if (!await OkiManager.i.share(filePath, text: 'Compartilhado pelo app ${Ressources.appName}', onError: onError)) {
        Log.snack(ui.erroCompartilhar, isError: true);
      }
    } catch (e) {
      Log.snack(e.toString(), isError: true);
    }
  }

  void _onRecriarMiniaturaClick() async {
    _setInProgress(true);
    final res = await _currentPost.compressPreview(true);

    if (res != null) {
      Log.snack('Erro ao criar miniatura', isError: true, actionClick: () {
        DialogBox(
          context: context,
          content: [Text(res)],
        ).ok();
      });
    }
    _setInProgress(false);
  }

  /// Sobrescreve as informações do post como prvedor, links, etc.
  void _onSobrescreverDadosClick() {
    // _currentPost.isSankaku = CURRENT_BOORU == SankakuComplex.name_;
    _album.addPost(_currentPost, update: true);
    _albunsMng.save();
  }

  //--------------------------------------------

  void _onOpenLinkClick() {
    try {
      OkiManager.i.openUrl(LinkConsert.tryConsert(_currentPost));
    } catch(e) {
      Log.snack('Indisponível nesse provedor', isError: true);
      _log.e('_onOpenLinkClick', e);
    }
  }

  //--------------------------------------------

  void _onAnalizarGrupoClick() async {
    final result = await Navigate.push(context, AnalizePage(
      album: _album,
      group: _currentGroup,
    ));
    if (result is bool && result) {
      _popResult = true;
      _postsList = _album.getGroup(widget.showOnline);
      _setState();
    }
  }

  void _onRemoveDoGrupoClick() {
    _postsList.add(PostG(id: _currentPost.id, album: _album, posts: [_currentPost]));

    _currentPost.parentId = null;
    _album.addPost(_currentPost, update: true);
    _currentGroup.remove(_currentPost.id);

    _albunsMng.save();

    for (var item in _currentGroup.posts) {
      item.parentId = _currentGroup.posts.first.id;
    }

    _currentGroup.previousPost();

    _popResult = true;
    _setState();
  }


  /// 0 = sample; 1 = original
  Future<int> _selectQuality() async {
    final original = _currentPost.hasPostOriginalFile;
    final sample = _currentPost.hasPostSampleFile;

    if (original) {
      final r = await DialogBox(
        context: context,
        title: ui.opcoesQualidade,
        content: [
          if (sample)
            ListTile(
              title: const Text('Sample'),
              subtitle: Text(_currentPost.sampleSizeName()),
              onTap: () => Navigator.pop(context, DialogResult(0)),
            ),
          ListTile(
            title: const Text('Original'),
            subtitle: Text(_currentPost.originalSizeName()),
            onTap: () => Navigator.pop(context, DialogResult(1)),
          ),
        ],
      ).cancel();
      return r.value;
    } else {
      return 0;
    }
  }

  //endregion

}

class TagItem extends StatelessWidget {
  final String text;
  final String subText;
  final void Function()? onTap;
  const TagItem({
    this.text = '',
    this.subText = '',
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      subtitle: Text(subText),
      onTap: onTap,
    );
  }
}
