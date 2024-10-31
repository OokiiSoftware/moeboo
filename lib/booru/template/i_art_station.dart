import 'dart:convert';
import '../../model/import.dart';
import '../import.dart';

abstract class IArtStation extends ABooru {

  IArtStation({List<BooruOptions>? options}) :
        super(BooruType.artStation, options: options?..add(BooruOptions.expireLinks));


  @override
  Uri get countUrl => newUri('projects.json');

  @override
  Uri get imageUrl => newUri('projects.json');

  @override
  Uri get tagUrl => newUri('projects.json');


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    params['sorting'] = 'date';
    params['page'] = '${query.page}';
    params['tags'] = query.tags.join('+');

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {};
  }


  @override
  Post getPost(Map json) {
    String tags = '';

    bool isMature = json['adult_content'] ?? false;
    json['rating'] = Rating.fromBool(isMature).valueTag;

    json['booruName'] = name;
    json['md5'] = json['hash_id'];

    if (json.containsKey('user')) {
      tags += 'user:${json['user']['subdomain']}';
      json['deviationUserId'] = 'user:${json['user']['id']}';
    }
    if (json.containsKey('title')) {
      tags += ' ${json['title']}';
    }

    if (json.containsKey('cover')) {
      json['sample_url'] = json['cover']['small_square_url'];
      json['preview_url'] = json['cover']['thumb_url'];
    }

    if (json.containsKey('sample_url')) {
      var temp = json['sample_url'].toString().split('?');
      if (temp.length <= 1) {
        temp = json['sample_url'].toString().split('.');
        json['file_ext'] = temp[temp.length - 1];
      } else {
        temp = temp[0].split('.');
        json['file_ext'] = temp[temp.length - 1];
      }
    }

    json['tags'] = tags;

    return Post.fromJson(json);
  }

  @override
  List<Post> getPosts(List? json) {
    List<Post> items = [];
    if (json == null) return items;

    for (var item in json) {
      items.add(getPost(item));
    }
    return items;
  }

  @override
  Tag getTag(Map json) {
    return Tag(
      id: 0,
      name: json['tag_name'],
      // count: json['count'],
      provider: name,
      // type: TagType.fromValue(json['type']),
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
    String tag = tags.join('+');
    bool isUser = tag.contains('user');
    tag = tag.replaceAll('user:', '');

    return Uri(
      scheme: 'https',
      host: home,
      path: isUser ? tag : 'search',
      query: isUser ? null : 'sort_by=date&query=$tag',
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'artwork/${hashId.toString()}',
    );
  }

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    Map<String, dynamic> params = getPostsParams(query);

    var uri = createUrl(imageUrl, params: params);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    if (response.isEmpty) return [];

    var map = jsonDecode(response);

    return getPosts(map['data']);
  }

  @override
  Future<List<Tag>> findTags(String? tagName) {
    throw 'O provedor não permite pesquisa por tags';
  }
}