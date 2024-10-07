import 'dart:convert';
import '../../booru/import.dart';
import '../../model/import.dart';
import '../../oki/import.dart';

abstract class IKemono extends ABooru {

  @override
  int get firstPage => 0;

  @override
  int get limitedPosts => 50;

  IKemono({super.options}) : super(BooruType.kemono);

  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    params['o'] = '${query.page * 50}';
    params['q'] = query.tags.join('+');

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {};
  }


  @override
  Post? getPost(Map json) {
    return Post.fromJson(json);
  }

  @override
  List<Post?> getPosts(List? json) {
    List<Post?> items = [];
    if (json == null) return items;

    List<String> paths = [];

    for (var item in json) {
      var post = _getPost(item['file'], item, 0);
      if (post != null) {
        items.add(post);
        paths.add(post.fileUrl!);
      }

      int i = 1;
      /// [{name, path}, {name, path}]
      List images = item['attachments'];
      for (var map in images) {
        post = _getPost(map, item, i);
        if (post != null) {
          if (paths.contains(post.fileUrl)) continue;
          items.add(post);
          i++;
        }
      }
    }
    return items;
  }

  @override
  Tag getTag(Map json) {
    return Tag(
      id: (int.tryParse(json['id'].toString()) ?? -1),
      name: json['name'] ?? json['tag'],
      count: int.tryParse(json['count'].toString()) ?? 0,
      provider: name,
      type: TagType.fromValue(json['type']),
    );
  }

  @override
  List<Tag> getTags(List? json) {
    List<Tag> items = [];
    if (json == null) return items;

    for (var item in json) {
      items.add(getTag(item));
    }
    return items;
  }

  @override
  Uri pageUri(List<String> tags) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'posts',
      query: 'q=${tags.join('+')}',
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri();
  }

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    Map<String, dynamic> params = getPostsParams(query);

    var uri = createUrl(imageUrl, params: params, rating: query.rating);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    if (response.isEmpty) return [];

    var map = jsonDecode(response);

    return getPosts(map);
  }

  @override
  Future<Post?> findCustomPost(String url) async {
    final sp = url.split('/');
    final id = sp[sp.length-1];
    final index = int.parse(id[id.length-1]);

    url = url.replaceAll('kemono.su', 'kemono.su/api/v1');
    url = url.substring(0, url.length-1);

    final res = await getJson(Uri.parse(url));
    final map = jsonDecode(res);

    return _getPost(map, map['file'], index);
  }

  @override
  Future<List<Tag>> findTags(String? tagName) async {
    if (tagName == null || tagName.isEmpty) return [];

    var url = createUrl(tagUrl.replace(path: 'posts/tags'));
    log.d('findTags', url);

    final response = await getJson(url);
    return getTags(_findTags(response, tagName));
  }

  Post? _getPost(Map map, Map item, int index) {
    item = {...item};
    String? path = map['path'];
    if (path == null) return null;

    final sp = path.split('.');
    final ext = sp[sp.length-1];

    const homePage = 'https://kemono.su';
    final id = item['id'];
    final service = item['service'];
    final user = item['user'];
    final source = '$homePage/$service/user/$user/post/$id$index';

    if (ext == 'zip') return null;

    return getPost(item..addAll({
      'id': int.parse('$id$index'),
      'booruName': name,
      'file_ext': ext,
      'rating': 'e',
      'source': source,
      'file_url': '$homePage$path',
      'preview_url': '$homePage/thumbnail/data$path',
    }));
  }

  List<Map<String, dynamic>> _findTags(String content, String tag) {
    List<Map<String, dynamic>> items = [];

    final container = getElementById(content, 'tag-container');

    if (container == null) return items;

    for (var a in container.children) {
      final spans = a.getElementsByTagName('span');
      if (spans.length < 2) continue;

      final name = spans[0].text;

      if (name.contains(tag)) {
        items.add({
          'id': randomInt(100000),
          'name': name.replaceAll(' ', '_'),
          'count': spans[1].text,
          'provider': name,
        });
      }
    }

    return items;
  }

}