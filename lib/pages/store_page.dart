import '../provider/import.dart';
import '../model/import.dart';
import '../pages/import.dart';
import '../res/import.dart';
import '../oki/import.dart';
import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {
  final List<Store> albuns;
  final int initialIndex;
  const StorePage({
    required this.albuns,
    this.initialIndex = 0,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<StorePage> with TickerProviderStateMixin {

  List<Store> get stores => widget.albuns;
  int get initialIndex => widget.initialIndex;

  Store get _store => stores[_currentAlbum];

  late PageController _controller;
  final _controllerV = PageController(initialPage: 1);

  int _currentAlbum = 0;

  bool _disableScroll = false;
  bool _backgroundTransparent = false;
  bool _showingAppBarCache = true;

  final OkiBool _showbackground = OkiBool(true);

  @override
  void dispose() {
    super.dispose();
    _controllerV.removeListener(_pageControllerVListener);
    _controller.dispose();
    _controllerV.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentAlbum = initialIndex;
    _controller = PageController(initialPage: initialIndex);

    _showbackground.onUpdate = _setState;
    _controllerV.addListener(_pageControllerVListener);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: _onPageChanged,
      physics: _disableScroll ? const NeverScrollableScrollPhysics() : null,
      children: [
        for (Store store in stores)...[
          Hero(
            tag: store.hashCode,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        var item = store.current;

                        var image = ImageWidet(
                          post: item,
                          onLoadComplete: _loadingComplete,
                        );
                        const tintColor = Colors.white;

                        return PageView(
                          scrollDirection: Axis.vertical,
                          controller: _controllerV,
                          physics: _disableScroll ? const NeverScrollableScrollPhysics() : null,
                          onPageChanged: _onPageChangedV,
                          children: [
                            Container(),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.linear,
                              color: _backgroundTransparent ? Colors.transparent : const Color.fromRGBO(46, 46, 46, 1),
                              child: Scaffold(
                                backgroundColor: Colors.transparent,
                                body: Stack(
                                  children: [
                                    PinchZoom(
                                      onZoom: _onImageZoon,
                                      child: Center(child: image),
                                    ),

                                    if (!_disableScroll)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _onLeftClick,
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _onRightClick,
                                            ),
                                          ),
                                        ],
                                      ),  // Detector de clicks

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            tooltip: idioma.voltar,
                                            icon: const Icon(Icons.arrow_back, color: tintColor,),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          OkiShadowText(store.album.nome,
                                            style: const TextStyle(fontSize: 18, color: tintColor),
                                            maxLines: 1,
                                          ),

                                          const Spacer(),
                                          IconButton(
                                            tooltip: idioma.irParaOAlbum,
                                            icon: const Icon(Icons.open_in_new, color: tintColor,),
                                            onPressed: () => _onAbrirAlbumClick(store),
                                          ),
                                        ],
                                      ),
                                    ),  // AppBar
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 50,
                                  // spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: TabPageSelector(
                              indicatorSize: 10,
                              color: Colors.black12,
                              selectedColor: Colors.white70,
                              controller: TabController(
                                length: store.postsLength,
                                initialIndex: store.storePosition,
                                vsync: this,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),  // TapPointsCount
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _onPageChanged(i) {
    _currentAlbum = i;
    _setState();
  }

  void _onPageChangedV(i) {
    if (i == 0) {
      Navigator.pop(context);
    }
  }

  void _onLeftClick() {
    if (_store.canPrevious) {
      _store.previousPost();
    } else {
      _currentAlbum--;
      if (_currentAlbum == -1) {
        _currentAlbum = 0;
      }
      _controller.animateToPage(
        _currentAlbum,
        duration: const Duration(milliseconds: 300),
        curve: const SawTooth(1),
      );
    }
    _setState();
  }
  void _onRightClick() {
    if (_store.canNext) {
      _store.nextPost();
    } else {
      _currentAlbum++;
      if (_currentAlbum == stores.length) {
        Navigator.pop(context);
        return;
      }
      if (_store.todosVistos) {
        Navigator.pop(context);
        return;
      }
      _controller.animateToPage(
        _currentAlbum,
        duration: const Duration(milliseconds: 300),
        curve: const SawTooth(1),
      );
    }

    _setState();
  }


  void _onImageZoon(double value) {
    _disableScroll = value >= 2;
    setState(() {});
  }

  void _loadingComplete(Post item) {
      item.vistoInStore = true;
      // item.compressPreview();
  }

  void _pageControllerVListener() {
    if (!_showingAppBarCache) {
      _showingAppBarCache = _showbackground.value;
    }

    if (_controllerV.page == 1) {
      final b = _backgroundTransparent;
      _backgroundTransparent = false;

      if (_showingAppBarCache) {
        _showbackground.value = true;
      }
      _showingAppBarCache = false;
      if (b) {
        _setState();
      }
    }
    else if ((_controllerV.page ?? 0) > 1) {
      if (_showbackground.value) {
        _showbackground.value = false;
      }
    }
    else {
      if (_backgroundTransparent) return;

      _backgroundTransparent = (_controllerV.page ?? 0) < 1;
      _showbackground.value = false;
    }
  }

  void _onAbrirAlbumClick(Store store) {
    Navigate.push(context, AlbumPage(album: store.album));
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

}