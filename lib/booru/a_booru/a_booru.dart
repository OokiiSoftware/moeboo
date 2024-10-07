import '../../model/import.dart';
import '../../oki/import.dart';
import '../import.dart';
import 'dart:convert';

abstract class ABooru extends IBooru {

  final Log log = const Log('ABooru');

  bool isPersonalizado = false;

  ABooru(super.booruType, {super.options, this.isPersonalizado = false});

  //region Post

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    Map<String, dynamic> params = getPostsParams(query);

    var uri = createUrl(imageUrl, params: params, rating: query.rating);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    var obj = jsonDecode(response);

    var obj2 = obj;
    if (obj is Map) {
      if (obj.containsKey('post')) {
        obj2 = obj['post'];
      } else if (obj.containsKey('posts')) {
        obj2 = obj['posts'];
      }  else if (obj.containsKey('results')) {
        obj2 = obj['results'];
      } else if (obj.containsKey('data')) {
        obj2 = obj['data'];
      }
    }

    if (obj2 == null) return [];
    if (obj2 is Map) return getPosts(obj);

    return getPosts(obj2);
  }

  @override
  Future<int> findPostsCount(List<String>? tagsArg) async {
    List<String> tags = tagsArg ?? <String>[];

    final url = createUrl(countUrl, params: {'limit': '1', 'tags': tags.join('+')});
    log.d('getPostsCount', url);

    String json = '';

    try {
      if (useTagsXml) {
        json = await getXml(url);
      } else {
        json = await getJson(url);
      }
    } catch(e) {
      log.e('getPostsCount', e);
    }

    try {
      final data = jsonDecode(json);
      final count = data['counts']['posts'];
      return count;
    } catch(e) {
      log.e('getPostsCount', e);
    }

    return -1;
  }

  @override
  Future<List<Post?>> findParents(int id) async {
    try {
      var uri = createUrl(imageUrl, params: {'parent': '$id'});

      log.d(name, 'getParents', 'uri', uri);
      String? temp = await getJson(uri);
      var obj = jsonDecode(temp);

      return getPosts(obj);
    } catch(e) {
      return <Post?>[];
    }
  }

  @override
  Future<Post?> findPostByMd5(String md5) async {
    try {
      late Uri uri;
      switch(type) {
        case BooruType.danbooru:
          uri = createUrl(imageUrl, path: 'posts/$md5.json');
          break;
        case BooruType.moeBooru:
        case BooruType.sankaku:
          uri = createUrl(imageUrl, params: {'tags': 'md5:$md5'});
          break;
        default:
          uri = imageUrl;
      }

      log.d(name, 'getPostByMd5', 'uri', uri);
      String? temp = await getJson(uri);
      var obj = jsonDecode(temp);

      var obj2 = obj;
      if (obj is Map) {
        if (obj.containsKey('post')) {
          obj2 = obj['post'];
        } else if (obj.containsKey('results')) {
          obj2 = obj['results'];
        } else if (obj.containsKey('data')) {
          obj2 = obj['data'];
        }
      }

      if (obj2 == null) return null;
      if (obj2 is Map) return getPost(obj);

      return getPosts(obj2)[0];
    } catch(e) {
      return null;
    }
  }

  @override
  Future<Post?> findPostById(int id) async {
    late Uri uri;
    switch(type) {
      case BooruType.danbooru:
        uri = createUrl(imageUrl, path: 'posts/$id.json');
        break;
      case BooruType.gelbooru:
        uri = createUrl(imageUrl, params: {
          'page': 'dapi',
          'json': '1',
          'q': 'index',
          's': 'post',
          'id': '$id',
        });
        break;
      case BooruType.moeBooru:
      case BooruType.sankaku:
        uri = createUrl(imageUrl, params: {'tags': 'id:$id'});
        break;
      default:
        uri = imageUrl;
    }

    log.d(name, 'getPostById', 'uri', uri);
    String? temp = await getJson(uri);
    var obj = json.decode(temp);

    var obj2 = obj;
    if (obj is Map) {
      if (obj.containsKey('post')) {
        obj2 = obj['post'];
      } else if (obj.containsKey('results')) {
        obj2 = obj['results'];
      } else if (obj.containsKey('data')) {
        obj2 = obj['data'];
      }
    }

    if (obj2 == null) return null;
    if (obj2 is Map) return getPost(obj);

    return getPosts(obj2)[0];
  }

  //endregion

  //region Tags

  // todo erro na pesquisa
  // bleachbooru, artStation
  @override
  Future<List<Tag>> findTags(String? tagName) async {
    if (tagName == null || tagName.isEmpty) return [];

    Map<String, String> params = getTagsParams(tagName);

    var url = createUrl(tagUrl, params: params);
    log.d('getTagsAsync', url);

    late String response;
    if (useTagsXml) {
      response = await getXml(url);
    } else {
      response = await getJson(url);
    }

    var list = jsonDecode(response);

    return getTags(list);
  }

  @override
  Future<Tag?> findTagByName(String name) async {
    var url = createUrl(tagUrl, params: {'name': name});
    log.d('getTagByName', url);

    String? json;

    try {
      if (useTagsXml) {
        json = await getXml(url);
      } else {
        json = await getJson(url);
      }

      if (json.isEmpty) throw ' Sem resultado';
    } catch(e) {
      log.e('getTagByName 1', e);
      return null;
    }

    try {
      var data = jsonDecode(json.replaceAll('}}', ''));
      if (data is Map && data.containsKey('tag')) {
        data = (data['tag'] as List).first;
      } else if (data is List) {
        data = data.first;
      }
      return getTag(data);
    } catch(e) {
      log.e('getTagByName 2', e);
    }

    return null;
  }

  @override
  Future<Tag?> findTagById(int id) async {
    var url = createUrl(tagUrl, params: {'name': name});
    log.d('getTagByName', url);

    String? json;

    try {
      if (useTagsXml) {
        json = await getXml(url);
      } else {
        json = await getJson(url);
      }
    } catch(e) {
      log.e('getTagByName 1', e);
    }

    try {
      var data = jsonDecode(json?.replaceAll('}}', '') ?? '');
      if (data is Map && data.containsKey('tag')) {
        data = (data['tag'] as List).first;
      } else if (data is List) {
        data = data.first;
      }
      return getTag(data);
    } catch(e) {
      log.e('getTagByName 2', e);
    }

    return null;
  }

  //endregion

}