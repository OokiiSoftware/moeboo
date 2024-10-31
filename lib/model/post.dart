import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../util/util.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../oki/import.dart';
import 'import.dart';

class PostG extends ChangeNotifier {
  final int id;
  final Map<int?, Post> _items = {};
  final Album album;

  int currentView = 0;

  List<Post> get posts => _items.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  PostG({required this.id, required this.album, List<Post>? posts}) {
    posts?.forEach((item) {
      _items[item.id] = item;
    });
  }

  Post get currentPost => posts[currentView];

  bool _isSelected = false;
  bool _isAnalizing = false;
  bool get isSelected => _isSelected;
  bool get isAnalizing => _isAnalizing;
  set isSelected(value) {
    _isSelected = value;
    notifyListeners();
  }
  set isAnalizing(value) {
    _isAnalizing = value;
    notifyListeners();
  }

  double get aspectRatio {
    return getAt(0)?.aspectRatio ?? 0;
  }

  int get savedCount {
    return posts.where((item) => item.isSalvo).length;
  }

  File get previewFile => posts[0].previewFile;

  bool get hasPostFile => posts.where((x) => x.hasPostSampleFile).isNotEmpty;
  bool get hasPreviewFile => posts.where((x) => x.hasPreviewCacheFile).isNotEmpty;

  int get length => _items.length;

  bool get isNotEmpty => _items.isNotEmpty;
  bool get isEmpty => _items.isEmpty;

  bool get isGroup => _items.length > 1;
  bool get isVideo => posts[0].isVideo;
  bool get hasFavorito => posts.where((e) => e.isFavorito).isNotEmpty;
  bool get isSalvo => posts.where((e) => !e.isSalvo).isEmpty;

  List<String> tagsToList() {
    List<String> items = [];
    for (var value in posts) {
      items.addAll(value.tags);
    }
    final ids = items.map((e) => e).toSet();
    items.retainWhere((e) => ids.remove(e));
    items.sort((a, b) => a.compareTo(b));
    return items;
  }

  Post? getAt(int index) {
    if (index < posts.length) {
      return posts[index];
    }
    return null;
  }

  void add(Post item) {
    item.parentId = id;
    _items[item.id] = item;
  }
  void addAll(List<Post> itens) {
    for (var i in itens) {
      add(i);
    }
  }

  Post? remove(Object? key) {
    return _items.remove(key);
  }
  void removeWhere(bool Function(Post) test) {
    _items.removeWhere((key, value) => test(value));
  }

  void clear() {
    _items.clear();
  }

  void nextPost() {
    currentView++;
    if (currentView >= _items.length) {
      currentView = 0;
    }
    notifyListeners();
    // currentViewChanged?.call();
  }
  void previousPost() {
    if (currentView > 0) {
      currentView--;
      notifyListeners();
      // currentViewChanged?.call();
    }
  }

  Future<bool> findParents() async {
    await _items[id]?.refresh();
    var v = await BooruProvider.i.booru.findParents(id);
    if (v.isEmpty || (v.length == 1 && v[0]?.id == getAt(0)?.id)) {
      v = await BooruProvider.i.booru.findParents(getAt(0)!.id);
    }

    for (var post in v) {
      if (post != null) {
        add(post);
      }
    }
    return v.isNotEmpty;
  }

  Future<bool> refresh() async {
    bool result = false;
    for (var post in _items.values) {
      await post.refresh();
    }
    return result;
  }

  @override
  String toString() {
    return _items.toString();
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is PostG && hashCode == other.hashCode;
  }
}

class Post extends ChangeNotifier {

  //region variaveis

  StorageManager get _storage => StorageManager.i;

  static const _log = Log('Post');
  static const List<String> videos = ['mp4', '3gp', 'webm', 'mkv', 'avi', 'zip'];

  bool vistoInStore = false;

  void Function()? onCompressDone;

  bool comprimindo = false;

  String? booruName;

  // Uri? _postUrl;
  // Uri get postUrl {
  //   if (customUrl != null) {
  //     return Uri.parse(customUrl!);
  //   }
  //   if (_postUrl != null) {
  //     return _postUrl!;
  //   }
  //
  //   String path = '';
  //   String? host;
  //   Map<String, dynamic>? params;
  //   var booru = Boorus.get(booruName);
  //   switch(booru?.type) {
  //     case BooruType.moeBooru:
  //       path = 'post/show/$id';
  //       break;
  //     case BooruType.danbooru:
  //       path = 'posts/$id';
  //       break;
  //     case BooruType.gelbooru:
  //       path = 'index.php';
  //       params = {'page': 'post', 's': 'view', 'id': '$id',};
  //       break;
  //     case BooruType.sankaku:
  //       path = 'post/show/$id';
  //       host = booru?.baseUrl.host.replaceAll('capi-v2', 'beta');
  //       break;
  //     case BooruType.deviant:
  //
  //       break;
  //     case BooruType.artStation:
  //       path = 'artwork/$md5';
  //       break;
  //     case null:
  //   }
  //   _postUrl = booru?.newUri(path, host: host, params: params);
  //   return _postUrl ?? Uri();
  // }

  Rating rating = Rating.safe;
  List<String> tags = [];

  String? fileUrl;
  String? fileExt;
  String? previewUrl;
  String? sampleUrl;
  String? customUrl;
  String? source;
  String? md5;
  String? deviationId;
  String? deviationUserId;

  int get id => _id ?? 0;
  set id(value) => _id = value;
  int? _id;
  int? parentId;
  int? size;
  int? sampleSize;
  int? height;
  int? width;
  int? score;
  int? previewHeight;
  int? previewWidth;

  /// Posição da imagem no preview do provider [EHentai]
  int? previewIndex;
  /// Número de previews que contém na imagem do provider [EHentai]
  int? previewLength;
  int? maiorHeight;

  late Album album;

  final key = GlobalKey();

  bool get isFavorito => AlbunsProvider.i.favoritos.getPost(idName) != null;

  // MediaController? video;

  //endregion

  //region construtores

  Post.fromJson(Map map, [Album? album]) {
    if (album != null) this.album = album;
    _set(map);
  }

  // static Map<String, Post> _fromJsonList(dynamic map, Album album) {
  //   Map<String, Post> items = {};
  //   if (map == null) {
  //     return items;
  //   }
  //
  //   if (map is List) {
  //     for (var value in map) {
  //       var item = Post.fromJson(value, album);
  //       items['${item.booruName}_${item.idName}'] = item;
  //     }
  //   }
  //   if (map is Map) {
  //     map.forEach((key, value) {
  //       var item = Post.fromJson(value, album);
  //       items['${item.booruName}_${item.idName}'] = item;
  //     });
  //   }
  //   return items;
  // }

  Map<String, dynamic> toJson() => {
    'file_url': fileUrl,
    'sample_url': sampleUrl,
    'preview_url': previewUrl,
    'custom_url': customUrl,
    'deviationid': deviationId,
    'deviationUserId': deviationUserId,
    'source': source,
    'id': id,
    'tags': tags.join(' '),
    'score': score,
    'md5': md5,
    'file_size': size,
    'sample_file_size': sampleSize,
    'preview_width': previewWidth,
    'preview_height': previewHeight,
    'preview_index': previewIndex,
    'preview_length': previewLength,
    'maior_height': maiorHeight,
    'width': width,
    'height': height,
    'rating': rating.valueTag,
    'booruName': booruName,
    'parent_id': parentId,
    'file_ext': fileExt,
    'isFavorito': isFavorito,
  };

  void _set(Map map, [Album? album]) {
    if (album != null) {
      this.album = album;
    }

    booruName = map['booruName'] ?? booruName;
    previewIndex = map['preview_index'] ?? previewIndex;
    previewLength = map['preview_length'] ?? previewLength;
    maiorHeight = map['maior_height'] ?? maiorHeight;
    _id = map['id'] ?? id;
    parentId = map['parent_id'] ?? parentId;

    fileUrl = map['file_url'] ?? fileUrl;
    sampleUrl = map['sample_url'] ?? sampleUrl;
    previewUrl = map['preview_url'] ?? previewUrl;
    customUrl = map['custom_url'] ?? customUrl;
    deviationId = map['deviationid'] ?? deviationId;
    deviationUserId = map['deviationUserId'] ?? deviationUserId;
    source = map['source'] ?? source;

    width = map['width'] ?? width;
    height = map['height'] ?? height;
    previewWidth = map['preview_width'] ?? previewWidth;
    previewHeight = map['preview_height'] ?? previewHeight;

    md5 = map['md5'] ?? md5;
    score = map['score'] ?? score;
    size = map['file_size'] ?? size;
    sampleSize = map['sample_file_size'] ?? sampleSize;
    fileExt = map['file_ext'] ?? fileExt;

    String? tagsTemp = map['tags'];
    if (tagsTemp != null) {
      tags.addAll(tagsTemp.split(' '));
    }

    String? rat = map['rating'];
    if (rat != null) {
      rating = Rating.fromString(rat[0]);
    }

    // if (isVideo) {
    //   video = MediaController(this);
    // }
  }

  //endregion

  //region metodos

  Future<void> refresh({bool forcePostBooru = true}) async {
    if (booruName == EHentai.name_ || booruName == Kemono.name_ || booruName == Coomer.name_) {
      await custonLoad(false);
      return;
    }

    Post? post;

    if (forcePostBooru) {
      post = await booru.findPostById(id);
    } else if (booruName == currentBooru) {
      post = await BooruProvider.i.booru.findPostById(id);
    } else {
      post = await BooruProvider.i.booru.findPostByMd5(md5!);
    }

    if (post == null) {
      if (forcePostBooru) {
        return refresh(forcePostBooru: false);
      }
    } else {
      await deleteFiles();
      _set(post.toJson());
      notifyListeners();
    }
  }

  Future<bool> deleteFiles() async {
    if (hasPreviewCacheFile) {
      await previewFile.delete();
    }

    if (hasPostSampleFile) {
      await postSampleFile.delete();
    }

    if (hasPostOriginalFile) {
      await postOriginalFile.delete();
    }

    // if (hasPostCompressedFile) {
    //   await postCompressedFile.delete();
    // }

    if (hasPreviewSalvoFile) {
      await previewSalvoFile.delete();
    }

    return true;
  }

  Future<String?> savePostFile({bool original = false}) async {
    try {
      String erro = 'Post não salvo';
      File? file;

      if (await postSalvoFile.exists()) {
        return null;
      }

      if (original && hasPostOriginalFile) {
        file = postOriginalFile;
      } else if (!original && hasPostSampleFile) {
        file = postSampleFile;
      }

      if (file == null) throw(erro);

      await file.rename(postSalvoFile.path);
      return null;
    } catch(e) {
      return e.toString();
    }
  }

  @Deprecated('Funcionalidade descontinuada')
  Future<String?> movePost() async {
    try {
      // if (isSalvo) {
      //   await previewCompressedCacheFile.rename(previewCompressedFile.path);
      //   await postCompressedCacheFile.rename(postCompressedFile.path);
      // } else {
      //   await previewCompressedFile.rename(previewCompressedCacheFile.path);
      //   await postCompressedFile.rename(postCompressedCacheFile.path);
      // }

      return null;
    } catch(e) {
      return e.toString();
    }
  }

  /// Comprime a imagem e salva como [previewSalvoFile]
  Future<String?> compressPreview([bool override = false]) async {
    if (isGif || isVideo) return null;

    final img = await compute(computeCompressPart1, ComputeParams(
      postSampleFile: postSampleFile,
      postOriginalFile: postOriginalFile,
      previewSalvoFile: previewSalvoFile,
      sobrescrever: override,
    ));

    if (img == null) return null;

    final e = await compute(computeCompressPart2, ComputeParams(
      file: img,
      previewSalvoFile: previewSalvoFile,
    ));

    if (e == null) {
      notifyListeners();
      return null;
    }

    notifyListeners();
    return e;
  }

  Future<Size> _calculateImageDimension(File file) {
    Completer<Size> completer = Completer();
    Image image = Image.file(file);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }
  Future<void> computeDimensionPreview() async {
    if (previewWidth != null && previewHeight != null) return;

    final size = await _calculateImageDimension(previewFile);

    previewWidth = size.width.toInt();
    previewHeight = size.height.toInt();
  }
  Future<void> computeDimension() async {
    if (width != null && height != null) return;
    final size = await _calculateImageDimension(postOriginalFile);

    width = size.width.toInt();
    height = size.height.toInt();
  }

  /// Usado pra obter dados do post em provedores que não tem api
  Future<void> custonLoad([bool ignoreLoad = true]) async {
    if (ignoreLoad) {
      if (fileUrl != null) return;
      if (hasAnyFile) return;
    }

    final booru = BooruProvider.i.booru;

    try {
      String url = customUrl ?? source!;

      final temp = await booru.findCustomPost(url);

      if (temp != null) {
        fileUrl = temp.fileUrl;
        sampleUrl = temp.sampleUrl;
        width = temp.width ?? width;
        height = temp.height ?? height;
        size = temp.size ?? size;

        if (temp.tags.isNotEmpty) {
          tags = temp.tags;
        }
      }

    } catch(e) {
      _log.e('custonLoad', e);
    }
  }


  String originalSizeName() {
    int s = size ?? 0;
    if (s == 0 && hasPostOriginalFile) {
      s = postOriginalFile.lengthSync();
    }

    final d = _calculeSize(s);
    return '${d[0].toStringAsFixed(2)} ${d[1]}';
  }

  String sampleSizeName() {
    int s = sampleSize ?? 0;
    if (s == 0 && hasPostSampleFile) {
      s = postSampleFile.lengthSync();
    }

    final d = _calculeSize(s);
    return '${d[0].toStringAsFixed(2)} ${d[1]}';
  }

  List<dynamic> _calculeSize(int size) {
    var kb = size / 1024;
    if (kb < 1024) {
      return [kb, 'Kb'];
    }

    var mb = kb / 1024;

    if (mb < 1000) {
      return [mb, 'Mb'];
    }

    var gb = mb / 1024;
    return [gb, 'Gb'];
  }

  //endregion

  //region get

  IBooru get booru => Boorus.get(booruName)!;

  bool get isGif => fileExt == 'gif';
  bool get isVideo => videos.contains(fileExt);
  bool get isSalvo => album.getPost(idName) != null;

  int get fileSize => postSampleFile.lengthSync();

  bool get hasAnyFile {
    return hasPostSampleFile || hasPostOriginalFile || hasPostSalvoFile ;
  }

  bool get hasAnyPreview {
    return hasPreviewCacheFile || hasPreviewSalvoFile;
  }

  File? get anyFile {
    // if (hasCompressedCacheFile) {
    //   return postCompressedCacheFile;
    // }
    if (hasPostSalvoFile) {
      return postSalvoFile;
    }
    if (hasPostSampleFile) {
      return postSampleFile;
    }
    if (hasPostOriginalFile) {
      return postOriginalFile;
    }
    return null;
  }

  bool get hasPostSalvoFile => postSalvoFile.existsSync();
  // bool get hasPostCompressedFile => postCompressedFile.existsSync();
  bool get hasPreviewSalvoFile => previewSalvoFile.existsSync();

  bool get hasPostSampleFile => postSampleFile.existsSync();
  bool get hasPostOriginalFile => postOriginalFile.existsSync();
  bool get hasPreviewCacheFile => previewFile.existsSync();


  File get postSalvoFile => _storage.file(_postSalvoName, path: Directorys.posts);
  // File get postCompressedFile => _storage.file(_postSalvoName, path: Directorys.postsCompressed);
  File get previewSalvoFile => _storage.file(_previewName, path: Directorys.previews);

  File get postSampleFile => _storage.file(_postSampleName, path: Directorys.posts, cache: true);
  File get postOriginalFile => _storage.file(_postOriginalName, path: Directorys.posts, cache: true);
  File get previewFile => _storage.file(_previewName, path: Directorys.previews, cache: true);

  String get _previewName => '$idName.jpg';
  String get _postSalvoName => '$idName.$fileExt';
  String get _postSampleName => '${idName}_sample.$fileExt';
  String get _postOriginalName => '${idName}_original.$fileExt';

  String get idName {
    return md5 ?? '${booruName}_$id';
  }

  double? get aspectRatio {
    return calculeAspectRatio(width, height);
  }

  double? get aspectRatioPreview {
    return calculeAspectRatio(previewWidth, previewHeight);
  }

  //endregion

  @override
  String toString() => toJson().toString();

}

class PostP extends ChangeNotifier implements Map<int, PostP> {

  final Map<int, PostP> _items = {};

  //region variaveis

  // StorageManager get _storage => StorageManager.i;

  static const _log = Log('Post');
  static const List<String> videos = ['mp4', '3gp', 'webm', 'mkv', 'avi', 'zip'];

  bool vistoInStore = false;
  bool isSankaku = false;
  int fileToShow = 0;

  void Function()? onPreviewCompress;
  void Function()? onCompressDone;

  bool comprimindo = false;

  String? booruName;

  String? fileUrl;
  String? fileExt;
  String? previewUrl;
  String? sampleUrl;
  String? devUrl;
  String? deviationId;
  String? deviationUserId;

  Uri? _postUrl;
  Uri get postUrl {
    if (devUrl != null) {
      return Uri.parse(devUrl!);
    }
    if (_postUrl != null) {
      return _postUrl!;
    }

    String path = '';
    String? host;
    Map<String, dynamic>? params;
    var booru = Boorus.get(booruName);
    switch(booru?.type) {
      case BooruType.moeBooru:
        path = 'post/show/$id';
        break;
      case BooruType.danbooru:
        path = 'posts/$id';
        break;
      case BooruType.gelbooru:
        path = 'index.php';
        params = {'page': 'post', 's': 'view', 'id': '$id',};
        break;
      case BooruType.sankaku:
        path = 'post/show/$id';
        host = booru?.baseUrl.host.replaceAll('capi-v2', 'beta');
        break;
      case BooruType.deviant:

        break;
      case BooruType.artStation:
        path = 'artwork/$md5';
        break;
      case null:
    }
    _postUrl = booru?.newUri(path, host: host, params: params);
    return _postUrl ?? Uri();
  }

  Rating rating = Rating.safe;
  List<String> tags = [];

  late int id;
  int? parentId;
  int? size;
  int? sampleSize;
  int? height;
  int? width;
  int? score;
  int? previewHeight;
  int? previewWidth;

  /// Posição da imagem no preview do provider [EHentai]
  int? previewIndex;
  /// Número de previews que contém na imagem do provider [EHentai]
  int? previewLength;

  DateTime? creation;
  String? source;
  String? md5;

  Album? album;

  late GlobalKey key;

  // bool get isFavorito => AlbunsManager.i.favoritos.getPost(idName) != null;

  MediaController? video;
  late Uint8List? imageMemory;

  bool get isVideo => videos.contains(fileExt);

  //endregion

  //region construtores

  PostP({this.fileUrl = '',
    this.previewUrl = '',
    this.sampleUrl = '',
    this.rating = Rating.safe,
    this.tags = const [],
    this.id = 0,
    this.size = 0,
    this.sampleSize = 0,
    this.height = 0,
    this.width = 0,
    this.previewHeight = 0,
    this.previewWidth = 0,
    this.creation,
    this.source = '',
    this.score = 0,
    this.md5 = '',
    this.parentId = 0,
    this.booruName = '',
    this.fileExt = '',
    this.album,
  }) {
    if (isVideo) {
      // video = VideoController(this);
    }
    isSankaku = booruName == Sankaku.name_;
    key = GlobalKey();
  }

  PostP.fromJson(Map map, [this.album]) {
    key = GlobalKey();
    _set(map);
  }

  Map<String, dynamic> toJson() => {
    'file_url': fileUrl,
    'sample_url': sampleUrl,
    'preview_url': previewUrl,
    'deviationid': deviationId,
    'deviationUserId': deviationUserId,
    'source': source,
    'id': id,
    'tags': tags.join(' '),
    'score': score,
    'md5': md5,
    'file_size': size,
    'sample_file_size': sampleSize,
    'preview_width': previewWidth,
    'preview_height': previewHeight,
    'preview_index': previewIndex,
    'preview_length': previewLength,
    'width': width,
    'height': height,
    'rating': rating.valueTag,
    'booruName': booruName,
    'parent_id': parentId,
    'file_ext': fileExt,
  };

  static Map<String, Post> fromJsonList(dynamic map, Album album) {
    Map<String, Post> items = {};
    if (map == null) {
      return items;
    }

    if (map is List) {
      for (var value in map) {
        var item = Post.fromJson(value, album);
        items['${item.booruName}_${item.idName}'] = item;
      }
    }
    if (map is Map) {
      map.forEach((key, value) {
        var item = Post.fromJson(value, album);
        items['${item.booruName}_${item.idName}'] = item;
      });
    }
    return items;
  }

  void _set(Map map, [Album? album]) {
    if (album != null) {
      this.album = album;
    }

    booruName = map['booruName'];
    previewIndex = map['preview_index'] ?? 0;
    previewLength = map['preview_length'] ?? 0;
    id = map['id'] ?? 0;
    parentId = map['parent_id'];

    fileUrl = map['file_url'];
    sampleUrl = map['sample_url'];
    previewUrl = map['preview_url'];
    devUrl = map['devUrl'];
    deviationId = map['deviationid'];
    deviationUserId = map['deviationUserId'];
    source = map['source'];

    width = map['width'];
    height = map['height'];
    previewWidth = map['preview_width'];
    previewHeight = map['preview_height'];

    md5 = map['md5'];
    score = map['score'];
    size = map['file_size'];
    sampleSize = map['sample_file_size'];
    fileExt = map['file_ext'];

    String? tagsTemp = map['tags'];
    if (tagsTemp != null) {
      tags.addAll(tagsTemp.split(' '));
    }

    String? rat = map['rating'];
    if (rat != null) {
      rating = Rating.fromString(rat[0]);
    }

    if (isVideo) {
      // video = VideoController(this);
    }

    isSankaku = booruName == Sankaku.name_;
  }

  //endregion

  //region overrides

  void add(PostP value) {
    _items[value.id] = value;
    notifyListeners();
    _log.d('add', value.id, 'em', id);
  }

  @override
  PostP? operator [](Object? key) => _items[key];

  @override
  void operator []=(int key, PostP value) {
    add(value);
  }

  @override
  void addAll(Map<int, PostP> other) {
    _items.addAll(other);
    notifyListeners();
  }

  @override
  PostP? remove(Object? key) {
    if (containsKey(key)) {
      final item = _items.remove(key);
      notifyListeners();
      _log.d('remove', item?.id, 'de', id);
      return item;
    }
    return null;
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }

  @override
  Iterable<MapEntry<int, PostP>> get entries => _items.entries;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterable<int> get keys => _items.keys;

  @override
  Iterable<PostP> get values => _items.values;

  @override
  int get length => _items.length;

  @override
  bool containsKey(Object? key) => _items.containsKey(key);

  @override
  bool containsValue(Object? value) => _items.containsValue(value);

  @override
  void addEntries(Iterable<MapEntry<int, PostP>> newEntries) => _items.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _items.cast();

  @override
  void forEach(void Function(int key, PostP value) action) => _items.forEach(action);

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(int key, PostP value) convert) => _items.map(convert);

  @override
  PostP putIfAbsent(int key, PostP Function() ifAbsent) => _items.putIfAbsent(key, ifAbsent);

  @override
  void removeWhere(bool Function(int key, PostP value) test) {
    _items.removeWhere(test);
    notifyListeners();
  }

  @override
  PostP update(int key, PostP Function(PostP value) update, {PostP Function()? ifAbsent}) => _items.update(key, update);

  @override
  void updateAll(PostP Function(int key, PostP value) update) => _items.updateAll(update);

  //endregion

}
