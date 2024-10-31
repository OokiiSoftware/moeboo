import 'dart:convert';
import '../../model/import.dart';
import '../../oki/import.dart';
import '../import.dart';

abstract class ISex extends ABooru {

  ISex({List<BooruOptions>? options}) : super(BooruType.sex, options: options);


  @override
  Uri get countUrl => baseUrl;

  @override
  Uri get imageUrl => baseUrl;

  @override
  Uri get tagUrl => baseUrl;


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query, [bool isUser = false]) {
    Map<String, dynamic> params = {};
    query.page++;
    int limit = query.postsLimit;
    if (limit > limitedPosts) {
      limit = limitedPosts;
    }

    params['pageNumber'] = '${query.page}';
    if (query.tags.isNotEmpty) {
      if (isUser) {
        params['username'] = query.tags.join(',').replaceAll('_', '-');
      } else {
        params['tags'] = query.tags.join(',').replaceAll('_', '-');
      }
    }
    // params['username'] = 'jennyco';
    // params['mediaType'] = 'video';
    params['visibility'] = 'public';
    params['pageSize'] = '$limit';

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'query': tagName,
    };
  }


  @override
  Post getPost(Map json) {
    List? tags = json["tags"];
    List<String> tagsList = [];
    tags?.forEach((item) {
      tagsList.add(item.toString());
    });

    if (json.containsKey('user')) {
      tagsList.add('user:${json['user']['username']}');
    }

    json['booruName'] = name;
    json['rating'] = 'explicit';
    json['id'] = (json['videoUid'] ?? json['pictureUid']).toString().removeText();
    json['preview_url'] = json['publicFullPath'] ?? json['thumbnail']?['fullPath'];
    json['sample_url'] = json['preview']?['fullPath'];
    json['file_url'] = json['fullPath'] ?? (json['sources'] as List).first['fullPath'];

    json['file_ext'] = (json['fileType'] ?? (json['sources'] as List).first['fileType']).toString().split('/')[1];
    json['score'] = json['likes'];
    json['tags'] = tagsList.join(' ');

    return Post.fromJson(json);
  }

  @override
  List<Post> getPosts(List? json, [bool isUser = false]) {
    List<Post> items = [];
    if (json == null) return items;

    for (var item in json) {
      if (isUser) {
        items.add(getPost(item['media']));
      } else {
        items.add(getPost(item));
      }
    }
    return items;
  }

  @override
  Tag getTag(Map json) {
    return Tag(
      id: json['id'],
      name: json['name_en'],
      count: json['count'],
      provider: name,
      type: TagType.fromValue(json['type']),
    );
  }

  @override
  List<Tag> getTags(List? json) {
    List<Tag> items = [];
    if (json == null) return items;

    for (var item in json) {
      items.add(Tag(id: randomInt(5), name: item));
    }
    return items;
  }

  @override
  Uri pageUri(List<String> tags) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'pt/videos',
      query: 'search=${tags.join('+')}',
    );
  }

  // @override
  // Uri postUri(dynamic hashId) {
  //   return Uri(
  //     scheme: 'https',
  //     host: home,
  //     path: 'pt/post/show/${hashId.toString()}',
  //   );
  // }

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    bool isUser = false;

    for (int i = 0; i < query.tags.length; i++) {
      if (query.tags[i].contains('user:')) {
        query.tags[i] = query.tags[i].replaceAll('user:', '');
        isUser = true;
      }
    }

    Map<String, dynamic> params = getPostsParams(query, isUser);

    String? path = 'api/media/listMedia';
    if (isUser) {
      path = 'api/feed/listUserItems';
    }

    var uri = createUrl(imageUrl, params: params, rating: query.rating, path: path);

    log.d(name, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri, headers: headers);

    if (response.isEmpty) return [];

    var map = jsonDecode(response);

    return getPosts(map['page']['items'], isUser);
  }

  @override
  Future<List<Tag>> findTags(String? tagName, {int page = 1}) async {
    if (tagName == null || tagName.isEmpty) return [];

    String? path = 'api/tags/listTags';

    Map<String, String> params = getTagsParams(tagName);
    params['pageNumber'] = '$page';

    var url = createUrl(tagUrl, path: path, params: params);
    log.d('getTagsAsync', url);

    String response = await getJson(url);

    var map = jsonDecode(response);

    if (map['page']['pageInfo']['hasNextPage'] == true && page < 5) {
      return getTags(map['page']['items']) + (await findTags(tagName, page: page +1));
    }

    return getTags(map['page']['items']);
  }

}
