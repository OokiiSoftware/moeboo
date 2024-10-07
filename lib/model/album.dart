import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../util/util.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../oki/import.dart';
import 'import.dart';

class Album extends ChangeNotifier implements Map<String, Album> {

  //region variaveis

  static const _log = Log('Album');

  StorageManager get _storage => StorageManager.i;

  final Map<String, Album> _items = {};
  /// <provider, date>
  final Map<String, int?> _dataAtualizacao = {};
  /// <provier, value>
  final Map<String, bool> _noMoreResults = {};
  /// <provider, List<tags>>
  final Map<String, List<String>> tags = {};

  late String id;
  late String _nome;

  bool isOculto = false;
  bool isCapaManual = false;
  bool autoUpdateCapa = true;
  String? _capaChildId;
  String? _capa;

  Album? _parent;

  late AlbumQuery query = AlbumQuery();

  /// Página atual para mostrar no app
  int pagination = 0;
  int maxPage = 0;

  final List<String> _filtro = [];
  bool blockTagsDoFiltro = false;

  final key = GlobalKey();

  void Function()? onTagsChanged;
  void Function()? onNoMoreResults;

  //----------------------- POSTS

  /// Posts salvos
  final OkiMap<String, Post> _posts = OkiMap();
  final OkiMap<String, Post> postsAnalize = OkiMap();

  final Map<int, PostG> _groups = {};
  final Map<String, Map<int, PostG>> _groupsOnline = {};
  final Map<String, Map<String, Post>> _postsOnline = {};

  int currentPage = 0;
  bool _agrupar = true;

  //endregion

  //region construtores

  Album({required this.id, required String nome, Album? parent, List<Post>? posts}) {
    _parent = parent;
    _nome = nome;

    if (posts != null) {
      addAllPosts(posts);
    }
    // postsAnalize?.forEach((post) {
    //   _postsAnalize[post.idName] = post;
    // });
    _posts.addListener(_onPostChanged);
  }

  Album.fromJson(Map<String, dynamic>? map, {Album? parente}) {
    set(map, parente);
  }

  Map<String, dynamic> toJson([bool recursive = false]) {
    final map = {
      'id': id,
      'nome': nome,
      'capa': _capa,
      'capaChildId': _capaChildId,
      'autoUpdateCapa': autoUpdateCapa,
      'isOculto': isOculto,
      'currentPage': currentPage,
      'dataAtualizacao': _dataAtualizacao,
      'tags': _tagsToMap(),
      'albuns': _albunsToMap(),
      'posts': _postsToMap(),
      'query': query.toJson(),
      'isCapaManual': isCapaManual,
    };

    if (recursive) {
      map['parent'] = parent?.toJson(recursive);
    }

    return map;
  }

  Map<String, dynamic> mapToSave() => {
    'id': id,
    'nome': nome,
    'capa': _capa,
    'capaChildId': _capaChildId,
    'autoUpdateCapa': autoUpdateCapa,
    'isOculto': isOculto,
    'dataAtualizacao': _dataAtualizacao,
    'tags': _tagsToMap(),
    'albuns': _albunsToMap(toSave: true),
    'isCapaManual': isCapaManual,
  };

  @override
  toString() => toJson().toString();

  void set(Map<String, dynamic>? map, Album? parente) {
    if (map == null) return;
    _parent = parente;

    if (parente == null && map.containsKey('parent')) {
      _parent = Album.fromJson(map['parent']);
    }

    id = map['id'];
    nome = map['nome'] ?? '';

    _capa = map['capa'];
    _capaChildId = map['capaChildId'];
    autoUpdateCapa = map['autoUpdateCapa'] ?? true;
    isCapaManual = map['isCapaManual'] ?? false;
    isOculto = map['isOculto'] ?? false;
    currentPage = map['currentPage'] ?? 0;

    Map? tagsTemp = map['tags'];
    tagsTemp?.forEach((key, value) {
      if (!tags.containsKey(key)) {
        tags[key] = [];
      }
      if (value is List) {
        for (var tag in value) {
          tags[key]?.add(tag);
        }
      }
    });

    Map? albunsTemp = map['albuns'];
    final mapAlbuns = <String, Album>{};
    albunsTemp?.forEach((key, value) {
      mapAlbuns[key] = Album.fromJson(value, parente: this);
    });
    addAll(mapAlbuns);

    Map? postsTemp = map['posts'];
    postsTemp?.forEach((key, value) {
      _posts[key] = Post.fromJson(value, this);
    });

    Map? dataTemp = map['dataAtualizacao'];
    dataTemp?.forEach((provider, data) {
      _dataAtualizacao[provider] = data;
    });

    query = AlbumQuery.fromJson(map['albuns']);

    updateGroups();

    _posts.addListener(_onPostChanged);
  }

  //endregion

  //region metodos

  void _onPostChanged([String? key, Post? value]) {
    updateGroups(online: false);
    // save('_onPostChanged');
  }

  void reset() {
    clear();
    isCapaManual = false;
    _capa = null;
    tags.clear();
    _groupsOnline.clear();
    _postsOnline.clear();
    _groups.clear();
    _posts.clear();

    onTagsChanged?.call();
    notifyListeners();
  }

  Future<void> computPosts({bool recursive = false}) async {
    if (recursive && isCollection) {
      for(var value in values) {
        await value.computPosts(recursive: recursive);
      }
      return;
    }
    if (isCollection) return;

    final data = await compute(computeOnlinePosts, ComputeParams(
      path: _storage.file(albumFileName, path: Directorys.search, cache: true).path,
    ));

    data.forEach((key, value) {
      value.forEach((key, value) {
        value.album = this;
      });
    });
    _postsOnline.addAll(data);
    // await _computeOnlinePosts(
    //   _storage.file(albumFileName, path: Directorys.search, cache: true).path,
    //   this,
    // ).then((value) => _postsOnline.addAll(value));

    if (isSalvo) {
      final data = await compute(computePosts, ComputeParams(
        path: _storage.file(albumFileName, path: Directorys.search).path,
      ));

      data.forEach((key, value) {
        value.album = this;
      });
      _posts.addAllNoListener(data);
      // await _computePosts(
      //   _storage.file(albumFileName, path: Directorys.search).path,
      //   this,
      // ).then((value) => _posts.addAllNoListener(value));
    }

    updateGroups();
  }

  Future<String?> _saveOnlinePosts() async {
    if (isCollection || isOnlineEmpty) return null;

    return await compute(computeSave, ComputeParams(
      path: _storage.file(albumFileName, path: Directorys.search, cache: true).path,
      data: _postsOnlineToMap(),
    ));
  }
  Future<String?> saveSavedPosts() async {
    if (isCollection) return null;

    return await compute(computeSave, ComputeParams(
      path: _storage.file(albumFileName, path: Directorys.search).path,
      data: _postsToMap(),
    ));
  }

  Future<String?> criarArquivosPostsSalvos() async {
    if (isCollection) {
      for (var value in values) {
        var e = await value.criarArquivosPostsSalvos();
        if (e != null) return e;
      }
      return null;
    } else {
      return await saveSavedPosts();
    }
  }

  void close() {
    // print('${parent?.id}');
    // print(parent != null);
    // print(isSalvos);
    if (!isFavoritos && !isSalvos) {
      _posts.clear();
      _postsOnline.clear();
    }
  }

  List<String> getTags(String booru) {
    if (tags.containsKey(booru)) {
      return tags[booru] ?? <String>[];
    }

    if (tags.isNotEmpty) {
      return tags.values.first;
    }

    return [];
  }

  List<Album> getAlbuns({bool addOcultos = true, bool recursive = true, bool onlyCollections = false}) {
    List<Album> list = [];
    if (!addOcultos && isOculto) return list;

    if (isCollection) {
      if (recursive) {
        forEach((key, value) {
          list.addAll(value.getAlbuns(addOcultos: addOcultos, recursive: recursive, onlyCollections: onlyCollections));
        });
      } else {
        list.addAll(values.toList());
      }
    } else {
      list.add(this);
    }
    list.removeWhere((x) => onlyCollections ? !x.isCollection : false);
    return list;
  }

  bool get noMoreResults {
    return _noMoreResults[currentBooru] ?? false;
  }


  Map<String, dynamic> _tagsToMap() {
    Map<String, dynamic> items = {};
    tags.forEach((key, value) {
      items[key] = value;
    });
    return items;
  }

  Map<String, dynamic> _postsToMap() {
    Map<String, dynamic> items = {};
    _posts.forEach((key, value) {
      items[key] = value.toJson();
    });
    return items;
  }

  Map<String, Map<String, dynamic>> _postsOnlineToMap() {
    Map<String, Map<String, dynamic>> items = {};
    _postsOnline.forEach((povider, value) {
      items[povider] = {};
      value.forEach((key, value) {
        items[povider]![key] = value.toJson();
      });
    });
    return items;
  }

  Map<String, dynamic> _albunsToMap({bool toSave = false}) {
    Map<String, dynamic> items = {};
    forEach((key, value) {
      if (toSave) {
        items[key] = value.mapToSave();
      } else {
        items[key] = value.toJson();
      }
    });
    return items;
  }

  //endregion

  //region albuns

  bool get capaIsFile => capa?.contains(Ressources.appName) ?? false;

  void resetCapa({bool recursive = false, bool alowNull = true}) {
    if (alowNull) _capa = null;

    if (recursive && isCollection) {
      forEach((key, album) {
        album.resetCapa(recursive: recursive, alowNull: alowNull);
      });
      return;
    }
    try {
      bool canSet(Post item) => _canSetPostAsCapa(item, false);

      Post? novaCapa;

      for (var item in _posts.values) {
        if (canSet(item)) {
          novaCapa = item;
          break;
        }
      }

      if (novaCapa == null) {
        for (var item in _postsOnline[currentBooru]?.values ?? <Post>[]) {
          if (canSet(item)) {
            novaCapa = item;
            break;
          }
        }
      }

      if (novaCapa == null && !alowNull) return;

      setCapa(novaCapa, isManual: false, reset: true);
    } catch(e) {
      return;
    }
  }

  void setCapa(Post? post, {bool isManual = false, bool reset = false}) async {
    if (post == null) {
      if (reset) {
        _capa = null;
        isCapaManual = isManual;
        notifyListeners();
      }
      return;
    }

    if (isCapaManual && !isManual && !reset) return;

    if (!_canSetPostAsCapa(post, isManual)) return;

    String novaCapa = '';
    if (await post.previewSalvoFile.exists()) {
      novaCapa = post.previewSalvoFile.path;
    } else if (await post.previewFile.exists()) {
      novaCapa = post.previewFile.path;
    } else {
      novaCapa = post.previewUrl ?? '';
    }

    if (novaCapa != _capa) {
      _capa = novaCapa;
      isCapaManual = isManual;
      _setParentCapa(novaCapa);
      notifyListeners();
    }
  }

  void _setParentCapa(String capa) {
    _parent?._capa = capa;
    notifyListeners();
    if (_parent?._parent != null) {
      _parent?._setParentCapa(capa);
    }
  }

  bool _canSetPostAsCapa(Post post, bool isManual) {
    if (isManual) {
      return true;
    }

    if (post.isVideo) {
      return false;
    }

    if(useOnlySafeAsCapa) {
      return post.rating == Rating.safe;
    }

    return true;
  }

  /// Usar este album como capa a coleção
  void useAsCapa() {
    if (!isSalvo || isCapaOfCollection) return;

    parent?._capaChildId = id;
  }

  void addTag(String? booru, String? tag) {
    if (booru == null || tag == null) return;

    if (tags[booru] == null) {
      tags[booru] = [];
    }

    var b = tags[booru];
    if (!(b?.contains(tag) ?? true)) {
      b?.add(tag);
    }
    onTagsChanged?.call();
  }

  Future<void> unirWith(Album? item) async {
    if (item == null) return;

    await item.computPosts(recursive: true);
    await computPosts(recursive: true);

    item.tags.forEach((provider, tags) {
      if (!this.tags.containsKey(provider)) {
        this.tags[provider] = <String>[];
      }

      this.tags[provider]!.addAll(tags);
      this.tags[provider] = this.tags[provider]!.toSet().toList();
    });

    addAllPosts(item.valuesPosts.toList());
    item.parent?.remove(item.id);
  }

  void setFiltro(List<String> filtro) {
    _filtro.clear();
    _filtro.addAll(filtro);
  }

  List<Post> getFavoritos({bool recursive = false}) {
    final items = <Post>[];
    items.addAll(_posts.values.where((x) => x.isFavorito));

    if (recursive) {
      forEach((key, value) {
        items.addAll(value.getFavoritos(recursive: recursive));
      });
    }
    return items;
  }

  List<Post> getSavedPosts({bool recursive = false, bool needExist = false, List<String>? rating}) {
    final items = <Post>[];
    rating = rating ?? [];

    items.addAll(_posts.values.where((x) {
      if (!x.isSalvo) return false;

      if (rating!.isNotEmpty && !rating.contains(x.rating.value)) return false;

      if (needExist) return x.hasPostSampleFile;

      return true;
    }));

    // for (var item in _posts.values) {
    //   if (item.isSalvo) {
    //     if (needExist) {
    //       if (item.hasPostSampleFile) {
    //         items.add(item);
    //       }
    //     } else {
    //       items.add(item);
    //     }
    //   }
    // }
    if (recursive && isNotEmpty) {
      forEach((key, value) {
        items.addAll(value.getSavedPosts(recursive: recursive, needExist: needExist, rating: rating));
      });
    }

    return items/*..removeWhere((post) => IBooru.removeWithRating(post, rating??[]))*/;
  }

  List<String> getPostsTags([bool online = true]) {
    List<String> items = [];
    for (var value in (online ? (_groupsOnline[currentBooru] ?? <int, PostG>{}) : _groups).values) {
      items.addAll(value.tagsToList());
    }
    return items.toSet().toList()..sort((a, b) => a.compareTo(b));
  }

  Album? findAlbum(String id) {
    Album? album;
    if (isCollection) {
      for (var value in values) {
        album = value.findAlbum(id);
        if (album != null) {
          return album;
        }
      }
    }

    if (id == this.id) {
      return this;
    }
    return album;
  }

  List<Album> findAlbums(String query) {
    List<Album> items = [];
    if (isCollection) {
      for (var value in _items.values) {
        items.addAll(value.findAlbums(query));
      }
    }

    if (!isRoot && !isFavoritos && nome.toLowerCase().contains(query)) {
      items.add(this);
    }

    return items;
  }

  Album copy() => Album.fromJson(toJson());

  //endregion

  //region posts

  Future<void> baixarPosts({required IBooru booru, bool clearData = false, List<String>? rating}) async {
    final booruName = booru.name;

    _postsOnline[booruName]??= {};

    if (clearData || _postsOnline[booruName]!.isEmpty) {
      currentPage = booru.firstPage;
      query.page = currentPage;
      _noMoreResults.remove(booruName);

      query.resetEHent();
      query.resetDev();
    }

    List<Post?>? newData;

    Future<List<Post?>> baixarPosts(List<String> tags, [ABooru? booruAux]) async {
      // List<String> blackList = [];
      // _booru.blackList.forEach((tag) => blackList.add('-$tag'));

      // print('${_query.eQueryPage}, ${_query.eQueryIndex}, ${_query.eGaleryPage}, ${_query.eGaleryIndex}');

      query = query.copy(
        tags: tags.toList(),
        page: currentPage,
        postsLimit: booru.limitedPosts,
        rating: [...rating ?? <String>[]],
        onCursorCreated: (cursor, offset) {
          query.deviantCursor = cursor;
          query.deviantOffset = offset;
        },
      );
      currentPage++;

      return await (booruAux ?? booru).findPosts(query: query).then((value) {
        // print('${_query.eQueryPage}, ${_query.eQueryIndex}, ${_query.eGaleryPage}, ${_query.eGaleryIndex}');
        return value;
      });
    }

    if (tags.isEmpty || tags.containsKey(booruName)) {
      newData = await baixarPosts(getTags(booruName));
    } else {
      final tagsVerificadasList = <List<String>>[];
      for (var testTags in tags.values) {
        //region verificação de tags já pesquisadas
        bool tagsVerificadas = false;
        for (var list in tagsVerificadasList) {
          if (list.join() == testTags.join()) {
            tagsVerificadas = true;
          }
        }
        if (tagsVerificadas) {
          continue;
        }
        tagsVerificadasList.add(testTags);
        //endregion

        newData = await baixarPosts(testTags);
        if (newData.isNotEmpty) {
          tags[booruName] = testTags;
          break;
        }
      }
    }

    if (newData == null) return;

    if (clearData) {
      _postsOnline[booruName]!.clear();
    }

    for (var item in newData) {
      if (item != null) {
        if (_postsOnline.containsKey(item.idName)) {
          _postsOnline.remove(item.idName);
        }

        item.album = this;
        _postsOnline[booruName]![item.idName] = item;
      }
    }

    _noMoreResults[booruName] = false;

    int limit = booru.limitedPosts;

    if (booru.isDeviant && tagsString.contains('user:')) {
      limit = 24;
    }
    _noMoreResults[booruName] = newData.length < limit;

    if (_noMoreResults[booruName]!) {
      onNoMoreResults?.call();
    }

    updateGroups(offline: false);
    _dataAtualizacao[booruName] = DateTime.now().millisecondsSinceEpoch;

    if (isSalvo) {
      _saveOnlinePosts();
    }
  }

  void updateGroups({bool online = true, bool offline = true, List<String> rating = const []}) {
    if (offline) {
      _updateGroupsAux(postsToList(), _groups, rating);
    }
    if (online) {
      if (!_groupsOnline.containsKey(currentBooru)) {
        _groupsOnline[currentBooru] = {};
      }
      _updateGroupsAux(_postsOnline[currentBooru]?.values.toList(), _groupsOnline[currentBooru], rating);

      maxPage = ((_groupsOnline[currentBooru]?.length ?? 0) / postsPorPage).ceilToDouble().toInt();
    }

    if (usePage && maxPage > 0 && query.page >= maxPage) {
      query.page = maxPage -1;
    }
  }

  void _updateGroupsAux(List<Post>? posts, Map<int, PostG>? groups, List<String> rating) {
    if (posts == null || groups == null) return;

    groups.clear();

    for (var post in posts) {
      int id = 0;
      if (_agrupar && ((post.parentId ?? 0) != 0)) {
        id = post.parentId ?? 0;
      } else {
        id = post.id;
      }

      if (_agrupar && (groups.containsKey(id))) {
        groups[id]?.add(post);
      } else {
        groups[id] = PostG(id: id, album: this, posts: [post]);
      }
    }

    groups.removeWhere((key, value) {
      bool permitir = IBooru.permitirWithRating(value, rating);

      if (permitir) return false;

      if (value.isEmpty) return true;

      if (filtro.isEmpty) return false;

      final filtroS = filtro.join(',');
      final tags = value.tagsToList().toSet().toList();

      bool containsTag = true;
      for(var tag in tags) {
        if (!filtroS.contains(tag)) {
          containsTag = false;
          break;
        }
      }

      if (blockTagsDoFiltro) {
        containsTag = !containsTag;
      }

      return containsTag;
    });
  }

  List<PostG> getGroup(bool online) {
    List<PostG> items;
    if (online) {
      List<PostG> getList() => _groupsOnline[currentBooru]?.values.toList() ?? <PostG>[];

      items = getList();
      if (items.isEmpty) {
        updateGroups(offline: false);
        items = getList();
      }

    } else {
      items = _groups.values.toList();
    }
    return items.where((value) {
      if (value.isEmpty) return false;

      bool permitir = IBooru.permitirWithRating(value, BooruProvider.i.rating);
      if (!permitir) return false;

      if (filtro.isEmpty) return true;

      final filtroS = filtro.join(',');
      final tags = value.tagsToList().toSet().toList();

      bool containsTag = false;
      for(var tag in tags) {
        if (filtroS.contains(tag)) {
          containsTag = true;
          break;
        }
      }


      if (blockTagsDoFiltro) return !containsTag;

      return containsTag;
    }).toList();
  }

  // List<PostG> _getGroup(bool online) {
  //   if (online) {
  //     List<PostG> getList() => _groupsOnline[currentBooru]?.values.toList() ?? <PostG>[];
  //
  //     List<PostG> items = getList();
  //     if (items.isEmpty) {
  //       updateGroups(offline: false);
  //       items = getList();
  //     }
  //
  //     return items.where((value) {
  //     if (value.isEmpty) return false;
  //
  //     // bool permitir = _booru.booru.permitirWithRating(value, rating);
  //     // if (!permitir) return false;
  //
  //     if (filtro.isEmpty) return true;
  //
  //     final filtroS = filtro.join(',');
  //     final tags = value.tagsToList().toSet().toList();
  //
  //     bool containsTag = false;
  //     for(var tag in tags) {
  //       if (filtroS.contains(tag)) {
  //         containsTag = true;
  //         break;
  //       }
  //     }
  //
  //     if (blockTagsDoFiltro) {
  //       containsTag = !containsTag;
  //     }
  //
  //     return containsTag;
  //   }).toList();
  //   }
  //   return _groups.values.toList();
  // }

  List<PostG> getPage(bool online, {int page = 0}) {
    try {
      List<PostG> items = getGroup(online);

      int itemsCount = items.length;

      if (itemsCount == 0) {
        return [];
      }

      maxPage = (itemsCount / postsPorPage).ceilToDouble().toInt();

      if (maxPage > 0 && page >= maxPage) {
        page = maxPage -1;
      }

      pagination = page;

      if (maxPage >= page) {
        int start = page * postsPorPage;
        int end = (page +1) * (postsPorPage);
        if (end > itemsCount) {
          end = itemsCount;
        }
        // Log.d(_tag, 'getPage', page, items.length, start, end);

        return items.sublist(start, end);
      }
    } catch(e) {
      _log.e('getPage', e, nome);
    }
    return [];
  }

  List<List<PostG>> getPages(bool online, {int page = 0}) {
    try {
      var list = getGroup(online);
      List<List<PostG>> items = [[]];

      int itemsCount = list.length;
      int itemsPorPage = postsPorPage;

      if (itemsCount == 0) {
        return [];
      }

      int contador = 0;
      for (int i = 0; i < list.length; i++) {
        contador++;
        if (contador == itemsPorPage +1) {
          items.add([]);
          contador = 0;
        }
        items[items.length-1].add(list[i]);
      }

      maxPage = (itemsCount / itemsPorPage).ceilToDouble().toInt();
      // Log.d(_TAG, 'getPage', page);
      if (maxPage > 0 && page >= maxPage) {
        page = maxPage -1;
      }

      query.page = page;

      // if (maxPage >= page) {
      //   int start = page * itemsPorPage;
      //   int end = page * itemsPorPage + itemsPorPage;
      //   if (end > itemsCount) {
      //     end = itemsCount;
      //   }
      //
      //   return items.sublist(start, end);
      // }
      return items;
    } catch(e) {
      _log.e('getPage', e, nome);
    }
    return [];
  }

  Post? getRandomPost(List<String> rating) {
    final list = [...postsToList()];
    list.removeWhere((e) {
      if (!e.hasAnyFile) {
        return true;
      }

      if (/*e.rating.isGeral && */rating.contains(Rating.safeValue)) {
        return false;
      }
      if (!rating.contains(e.rating.value)) {
        return true;
      }
      return false;
    });
    if (list.isEmpty) {
      return null;
    }
    int i = random.nextInt(list.length);
    return list.elementAt(i);
  }

  Post? getPostAt(bool online, int index) {
    try {
      return (online ? postsOnlineToList : postsToList)()[index];
    } catch(e) {
      return null;
    }
  }

  List<Post> postsToList() => _posts.values.toList();
  List<Post> postsOnlineToList() => _postsOnline[currentBooru]!.values.toList();

  Post? getPost(String postId) {
    return _posts[postId];
  }

  int indexOfPostG(PostG item, bool online) {
    try {
      int index = 0;
      final map = getGroup(online);

      for (var post in (map)) {
        if (item.id == post.id) {
          return index;
        }
        index++;
      }
    } catch(e) {
      return -1;
    }
    return -1;
  }

  int setSelectedAll(bool online, bool value) {
    final items = getSelectedPosts(online, !value);
    for (var item in items) {
      item.isSelected = value;
    }
    return items.length;
  }

  List<PostG> getSelectedPosts(bool online, bool value) {
    return getGroup(online)..removeWhere((item) => item.isSelected != value);
  }

  void setOrdenadedList(List<Post> items) {
    if (_posts.length != items.length) {
      throw ('A lista de posts do album não corresponde com esta lista');
    }

    _posts.clear();
    final temp = <String, Post>{};
    for (var item in items) {
      temp[item.idName] = item;
    }

    _posts.addAll(temp);
  }

  void reorderPosts(int Function(Post, Post) func) {
    final items = postsToList();
    items.sort(func);
    setOrdenadedList(items);
  }

  //endregion

  //region get

  String get nome => _nome;
  set nome(String value) {
    _nome = value;
    notifyListeners();
  }

  List<String> get filtro => _filtro.toSet().toList();

  String get tempoDeAtualizado {
    var timeNow = DateTime.now();
    int? booru = _dataAtualizacao[currentBooru];
    if (booru == null) {
      return 'nenhuma vez';
    }

    var data = DateTime.fromMillisecondsSinceEpoch(booru);

    int dias = timeNow.difference(data).inDays;
    int horas = timeNow.difference(data).inHours;
    int minutos = timeNow.difference(data).inMinutes;

    if (dias == 0) {
      if (minutos < 60) {
        return 'a $minutos minutos';
      }
      if (horas < 24) {
        return 'a $horas horas';
      }
    }
    if (dias == 1) {
      return 'Ontem';
    }

    return 'a $dias dias';
  }

  String get albumFileName {
    if(isSalvo) {
      return '${id.replaceAll(':', '')}.json';
    }
    return '$currentBooru ${tags[currentBooru]?.toString() ?? id}.json';
  }

  String get albumPath {
    var p = nome;
    if (parent != null && !(parent?.isRoot ?? true)) {
      p = '${parent?.albumPath}/$nome';
    }

    return p;
  }

  String get tagsString {
    String v = '';
    tags.forEach((provider, tags) {
      v += '$provider: ${tags.join(', ')}\n';
    });
    return v;
  }

  String? get capa {
    String? capaPath;
    if (_capaChildId != null && containsKey(_capaChildId)) {
      capaPath = _items[_capaChildId]?.capa;
      if (capaPath != null) {
        return capaPath;
      }
    }
    capaPath = _capa ?? '';

    for (var album in values) {
      final capaTemp = album.capa;
      if (capaTemp == null) {
        continue;
      }

      if (capaTemp.toLowerCase().contains(Ressources.appName.toLowerCase())) {
        return capaTemp;
      }

      if (capaTemp.contains('http') && (capaPath?.isEmpty ?? true)) {
        capaPath = capaTemp;
      }
    }

    return capaPath;
  }

  bool get isRoot => id == AlbunsProvider.rootId;
  bool get isFavoritos => id == AlbunsProvider.favoritosId;
  bool get isAnalize => id == AlbunsProvider.analizeId;
  bool get isSalvos => id == AlbunsProvider.salvosId;
  bool get isSalvo => parent != null;
  bool get isCollection => isNotEmpty;
  bool get isCapaOfCollection => isSalvo ? (parent?._capaChildId ?? '') == id : false;

  int get lengthSubAlbuns {
    int count = 0;
    forEach((key, value) {
      if (value.isCollection) {
        count++;
        count += value.lengthSubAlbuns;
      }
    });
    return count;
  }

  int get lengthNormalAlbuns {
    int count = 0;
    forEach((key, value) {
      if (value.isCollection) {
        count += value.lengthNormalAlbuns;
      } else {
        count++;
      }
    });
    return count;
  }

  Album? get parent => _parent;

  List<PostG> get groupList => _groups.values.toList();

  set agrupar(bool value) {
    if (value != _agrupar) {
      _agrupar = value;
      updateGroups();
    }
  }

  //endregion

  //region overrides

  void sort() {
    int albunsSort(Album a, Album b) => a.nome.compareTo(b.nome);
    final temp = _items.values.toList()..sort(albunsSort);

    _items.clear();
    final map = <String, Album>{};
    for (var item in temp) {
      map[item.id] = item;
    }
    _addAll(map);
  }

  void add(Album value) {
    value._parent = this;
    _items[value.id] = value;
    notifyListeners();
    sort();
    _log.d('addAlbum', value.nome, 'em', nome);
  }
  void addPost(Post? value, {bool update = false}) {
    if (value == null) return;

    if (update) {
      _posts[value.idName] = value;
    } else {
      final temp = {..._posts};

      _posts.clear();
      _posts.addAll({value.idName : value,...temp});
    }

    if (value.comprimindo) {
      value.onCompressDone = () => setCapa(value);
    } else {
      setCapa(value);
    }

    value.notifyListeners();
    notifyListeners();
    saveSavedPosts();
  }

  @override
  Album? remove(Object? key) {
    if (containsKey(key)) {
      final item = _items.remove(key);
      notifyListeners();
      _log.d('removeAlbum', item?.nome, 'de', nome);
      return item;
    }
    return null;
  }
  void removePost(Object key) {
    if (_posts.containsKey(key)) {
      final item = _posts[key];
      _posts.remove(key);
      item?.notifyListeners();

      notifyListeners();
      saveSavedPosts();
    }
  }
  void removeGroup(Object key) {
    if (_groups.containsKey(key)) {
      removeAllPosts(_groups[key]?.posts);
    }
  }
  void removeAllPosts(List<Post>? values) {
    List<String> temp = values?.map((e) => e.idName).toList() ?? [];

    _posts.removeWhere((key, value) => temp.contains(key));

    for (var item in values ?? <Post>[]) {
      item.notifyListeners();
    }

    notifyListeners();
    saveSavedPosts();
  }
  void removeAllGroups(List<PostG>? values) {
    for (var item in values ?? <PostG>[]) {
      removeGroup(item.id);
    }
  }

  @override
  Album? operator [](Object? key) => _items[key];

  @override
  void operator []=(String key, Album value) {
    add(value);
  }

  void _addAll(Map<String, Album> other) {
    _items.addAll(other);
  }

  @override
  void addAll(Map<String, Album> other) {
    _items.addAll(other);
    sort();
  }
  void addAllPosts(List<Post>? other) {
    other?.forEach((item) {
      _posts[item.idName] = item;
    });

    other?.forEach((item) {
      item.notifyListeners();
    });

    if (_posts.isNotEmpty) {
      setCapa(_posts.values.first);
    }

    notifyListeners();
    saveSavedPosts();
  }
  void addAllGroups(List<PostG>? other) {
    for (var item in other ?? <PostG>[]) {
      addAllPosts(item.posts);
    }
  }

  @override
  void clear() {
    _items.clear();
  }
  void clearPosts() {
    _posts.clear();
    forEach((key, item) {
      item.clearPosts();
    });
  }
  void clearPostsOnline() {
    _postsOnline.clear();
    forEach((key, item) {
      item.clearPostsOnline();
    });
  }
  void clearAll() {
    clearPosts();
    clearPostsOnline();
    clear();
  }

  @override
  bool get isEmpty => _items.isEmpty;
  bool get isPostsEmpty => _posts.isEmpty;
  bool get isOnlineEmpty => _postsOnline[currentBooru]?.isEmpty ?? true;

  @override
  bool get isNotEmpty => _items.isNotEmpty;
  bool get isPostsNotEmpty => _posts.isNotEmpty;
  bool get isOnlineNotEmpty => _postsOnline[currentBooru]?.isNotEmpty ?? false;

  @override
  Iterable<String> get keys => _items.keys;

  @override
  Iterable<MapEntry<String, Album>> get entries => _items.entries;

  @override
  int get length => _items.length;
  int get lengthPosts {
    int i = 0;
    forEach((key, value) {
      i += value.lengthPosts;
    });
    return i + _posts.length;
  }
  int get lengthFavoritos {
    int i = 0;
    if (isNotEmpty) {
      forEach((key, value) {
        i += value.lengthFavoritos;
      });
    }
    return i + _posts.values.where((e) => e.isFavorito).length;
  }
  int get lengthPostsOnline {
    return _postsOnline[currentBooru]?.length ?? 0;
  }

  @override
  void removeWhere(bool Function(String key, Album value) test) {
    _items.removeWhere(test);
  }
  void removePostsWhere(bool Function(String key, Post value) test) {
    _posts.removeWhere(test);
  }

  @override
  void addEntries(Iterable<MapEntry<String, Album>> newEntries) => _items.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _items.cast();

  @override
  bool containsKey(Object? key) => _items.containsKey(key);
  bool containsKeyPosts(Object? key) => _posts.containsKey(key);

  @override
  bool containsValue(Object? value) => _items.containsValue(value);
  bool containsValuePosts(Object value) => _posts.containsValue(value);

  @override
  void forEach(void Function(String key, Album value) action) => _items.forEach(action);
  void forEachPosts(void Function(String key, Post value) action) => _posts.forEach(action);

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String key, Album value) convert) => _items.map(convert);

  @override
  Album putIfAbsent(String key, Album Function() ifAbsent) => _items.putIfAbsent(key, ifAbsent);

  @override
  Album update(String key, Album Function(Album value) update, {Album Function()? ifAbsent}) => _items.update(key, update);

  @override
  void updateAll(Album Function(String key, Album value) update) => _items.updateAll(update);

  @override
  Iterable<Album> get values => _items.values;
  Iterable<Post> get valuesPosts => _posts.values;

  //endregion

}

class AlbumQuery {
  static const int eHentMaxIndex = 24;

  int eQueryPage = 0;
  int eQueryIndex = 0;
  int eGaleryPage = 0;
  int eGaleryIndex = 0;

  String? content;

  int postsLimit = 0;
  int page = 0;
  List<String>? rating;
  List<String> tags;

  String? deviantCursor;
  int? deviantOffset;

  Function(String?, int?)? onCursorCreated;

  AlbumQuery({
    this.page = 0,
    this.eQueryPage = 0,
    this.eQueryIndex = 0,
    this.eGaleryPage = 0,
    this.eGaleryIndex = 0,
    this.postsLimit = 0,
    this.rating,
    this.content,
    this.deviantCursor,
    this.deviantOffset = 0,
    this.onCursorCreated,
    this.tags = const <String>[],
  });

  AlbumQuery.fromJson(Map? map) : tags = [] {
    if (map == null) return;

    eQueryPage = map['eQueryPage'] ?? 0;
    eQueryIndex = map['eQueryIndex'] ?? 0;
    eGaleryPage = map['eGaleryPage'] ?? 0;
    eGaleryIndex = map['eGaleryIndex'] ?? 0;

    postsLimit = map['postsLimit'] ?? 0;
    page = map['page'] ?? 0;
    deviantOffset = map['deviantOffset'] ?? 0;

    content = map['content'] ?? '';
    deviantCursor = map['deviantCursor'] ?? '';
  }

  Map<String, dynamic> toJson() => {
    'eQueryPage': eQueryPage,
    'eQueryIndex': eQueryIndex,
    'eGaleryPage': eGaleryPage,
    'eGaleryIndex': eGaleryIndex,
    'content': content,
    'postsLimit': postsLimit,
    'page': page,
    'deviantCursor': deviantCursor,
    'deviantOffset': deviantOffset,
  };

  AlbumQuery copy({
    int? eQueryPage,
    int? eQueryIndex,
    int? eGaleryPage,
    int? eGaleryIndex,
    String? content,
    int? postsLimit,
    int? page,
    List<String>? rating,
    List<String>? tags,
    String? deviantCursor,
    int? deviantOffset,
    Function(String?, int?)? onCursorCreated,
  }) => AlbumQuery(
    eQueryPage: eQueryPage ?? this.eQueryPage,
    eQueryIndex: eQueryIndex ?? this.eQueryIndex,
    eGaleryPage: eGaleryPage ?? this.eGaleryPage,
    eGaleryIndex: eGaleryIndex ?? this.eGaleryIndex,
    content: content ?? this.content,
    postsLimit: postsLimit ?? this.postsLimit,
    page: page ?? this.page,
    rating: rating ?? this.rating,
    tags: tags ?? this.tags,
    deviantCursor: deviantCursor ?? this.deviantCursor,
    deviantOffset: deviantOffset ?? this.deviantOffset,
    onCursorCreated: onCursorCreated ?? this.onCursorCreated,
  );

  void resetEHent() {
    page = 0;
    eQueryPage = 0;
    eQueryIndex = 0;
    eGaleryPage = 0;
    eGaleryIndex = 0;
  }
  void resetDev() {
    deviantCursor = null;
    deviantOffset = null;
  }
}

class AlumCapaType {
  static const int auto = 0;
  static const int manual = 1;

  int value;

  AlumCapaType(this.value);

  bool get isAuto => value == auto;
  bool get isManual => value == manual;
}
