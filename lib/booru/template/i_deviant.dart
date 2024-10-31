import 'dart:convert';
import '../../model/import.dart';
import '../import.dart';

abstract class IDeviantArt extends ABooru {
  IDeviantArt({List<BooruOptions>? options}) :
        super(BooruType.deviant, options: options?..add(BooruOptions.expireLinks));


  @override
  Uri get countUrl => baseUrl;

  @override
  Uri get imageUrl => baseUrl;

  @override
  Uri get tagUrl => baseUrl;


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    int limit = query.postsLimit;

    String tagsS = query.tags.join('+');
    if (tagsS.isEmpty) tagsS = 'girl';

    bool isUser = tagsS.contains('user:');

    if (isUser) {
      if (limit > 24) limit = 24;

      params['username'] = tagsS.replaceAll('user:', '');
    } else {
      if (limit > 50) limit = 50;
    }

    params['limit'] = '$limit';

    if (query.rating?.contains(Rating.explicit.value) ?? false) {
      params['mature_content'] = 'true';
    }

    if (deviantToken != null) {
      params['access_token'] = deviantToken;
    }
    if (query.deviantCursor != null) {
      params['cursor'] = '${query.deviantCursor}';
    }
    if (query.deviantOffset != null) {
      params['offset'] = '${query.deviantOffset}';
    }

    params['tag'] = tagsS;
    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'tag_name': tagName,
      'access_token': deviantToken??'',
    };
  }


  @override
  Post getPost(Map json) {
    Map nJson = {};
    String tags = '';

    String urlTemp = json['url'];
    String tagsTemp = urlTemp.split('/art/')[1];
    var d = tagsTemp.split('-');
    String id = '';
    if (d.isNotEmpty) {
      id = d[d.length-1];
    }

    bool isMature = json['is_mature'] ?? false;
    nJson['rating'] = Rating.fromBool(isMature).valueTag;

    nJson['booruName'] = name;
    nJson['id'] = int.parse(id);
    nJson['md5'] = json['deviationid'];
    nJson['file_size'] = json['download_filesize'];
    nJson['custom_url'] = json['url'];
    nJson['deviationid'] = json['deviationid'];

    if (json.containsKey('author')) {
      tags += 'user:${json['author']['username']}';
      nJson['deviationUserId'] = 'user:${json['author']['userid']}';
    }
    if (json.containsKey('title')) {
      tags += ' ${json['title']}';
    }
    if (json.containsKey('thumbs')) {
      List temp = json['thumbs'];
      if (temp.isNotEmpty) {
        nJson['preview_url'] = temp.last['src'];
        nJson['preview_width'] = temp.last['width'];
        nJson['preview_height'] = temp.last['height'];
      }
    }
    if (json.containsKey('preview')) {
      nJson['sample_url'] = json['preview']['src'];
      nJson['width'] = json['preview']['width'];
      nJson['height'] = json['preview']['height'];
    }
    if (json.containsKey('content')) {
      nJson['file_url'] = json['content']['src'];
      nJson['width'] = json['content']['width'];
      nJson['height'] = json['content']['height'];
      nJson['file_size'] = json['content']['filesize'];
    } else if (json.containsKey('videos')) {
      List temp = json['videos'];
      if (temp.isNotEmpty) {
        nJson['sample_url'] = temp.first['src'];
        nJson['sample_file_size'] = temp.first['filesize'];
        nJson['file_url'] = temp.last['src'];
        nJson['file_size'] = temp.last['filesize'];
      }
    }
    if (nJson.containsKey('file_url')) {
      var temp = nJson['file_url'].toString().split('?');
      if (temp.length <= 1) {
        temp = nJson['file_url'].toString().split('.');
        nJson['file_ext'] = temp[temp.length - 1];
      } else {
        temp = temp[0].split('.');
        nJson['file_ext'] = temp[temp.length - 1];
      }
    }


    nJson['tags'] = tags;

    // print(nJson);

    return Post.fromJson(nJson);
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
    return Uri(
      scheme: 'https',
      host: home,
      path: 'search',
      query: 'q=${tags.join('+')}',
    );
  }

  @override
  Uri postUri(hashId) {
    var tags = '';
    String user = '';
    for (var tag in (hashId as List<String>)) {
      if (tag.contains('user')) {
        user = tag.toLowerCase().replaceAll('user:', '');
      } else {
        tags += '$tag-';
      }
    }
    if (tags.isNotEmpty) {
      tags = tags.substring(0, tags.length -1);
    }

    return Uri(
      scheme: 'https',
      host: home,
      path: '$user/art/$tags',
    );
  }

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    //region variaveis

    Map<String, dynamic> params = getPostsParams(query);

    String? path;

    String tagsS = query.tags.join(' ');
    bool isDevUser = tagsS.contains('user:');

    if (isDevUser) {
      path = 'api/v1/oauth2/gallery/all';
    } else {
      path = 'api/v1/oauth2/browse/tags';
    }

    //endregion

    var uri = createUrl(imageUrl, params: params, path: path);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    if (response.isEmpty) return [];

    var map = jsonDecode(response);

    query.onCursorCreated?.call(map['next_cursor'], map['next_offset']);

    return getPosts(map['results']);
  }

  @override
  Future<List<Tag>> findTags(String? tagName) async {
    if (tagName == null || tagName.isEmpty) return [];

    String? path = 'api/v1/oauth2/browse/tags/search';

    Map<String, String> params = getTagsParams(tagName);

    await updateToken();

    var url = createUrl(tagUrl, path: path, params: params);
    log.d('getTagsAsync', url);

    String response = await getJson(url);

    var data = jsonDecode(response);

    return getTags(data['results']);
  }

}