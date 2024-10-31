import 'dart:convert';
import '../../model/import.dart';
import '../import.dart';

abstract class ICreatePorn extends ABooru {

  ICreatePorn({List<BooruOptions>? options}) : super(BooruType.createPorn, options: options);


  @override
  Uri get countUrl => newUri('');

  @override
  Uri get imageUrl => newUri('post/collection');

  @override
  Uri get tagUrl => newUri('');

  @override
  Map<String, String>? get headers => {
    'authority': 'api.createporn.com',
    'origin': 'https://www.$home',
    'referer': 'https://www.$home/',
    'accept': 'application/json, text/plain, */*',
    'priority': 'u=1, i',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
  };


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};
    params['images'] = '1';
    params['views'] = '1';
    params['likes'] = '1';
    params['timespan'] = '1';
    params['sort'] = 'top';
    params['include'] = 'userLikes';
    params['cursor'] = 'eyJsaWtlcyI6MjcsInZpZXdzIjozMTEsIl9pZCI6IjY3MTkyZjBjYjMzM2JhMmRjMDg4NzVjNyJ9';
    // params['page'] = '${query.page}';
    // params['search'] = query.tags.join('+');
    // if (query.postsLimit > 0) {
    //   params['limit'] = '${query.postsLimit}';
    // }
    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'search[fuzzy_name_matches]': tagName,
    };
  }


  @override
  Post getPost(Map json) {
    json['booruName'] = name;
    json['preview_url'] = json['preview_file_url'];
    json['sample_url'] = json['large_file_url'];
    json['height'] = json['image_height'];
    json['width'] = json['image_width'];
    json['tags'] = json['tag_string'];

    return Post.fromJson(json);
  }

  @override
  List<Post> getPosts(List? json) {
    List<Post> items = [];
    if (json == null) return items;

    for (var item in json) {
      try {
        var temp = getPost(item);
        items.add(temp);
      } catch(e) {
        continue;
      }
    }
    return items;
  }

  @override
  Tag getTag(Map json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      count: json['post_count'],
      provider: name,
      type: TagType.fromValue(json['category']),
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
  Uri pageUri(List<String> tags) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'posts',
      query: 'tags=${tags.join('+')}',
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'posts/${hashId.toString()}',
    );
  }

}