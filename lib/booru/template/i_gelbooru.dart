import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../booru/import.dart';
import '../../model/import.dart';
import '../../oki/import.dart';

abstract class IGelBooru extends ABooru {

  @override
  int get firstPage => 0;

  IGelBooru({super.options, BooruType? type}) : super(type ?? BooruType.gelbooru);


  @override
  Uri get countUrl => newUri('index.php');

  @override
  Uri get imageUrl => newUri('index.php');

  @override
  Uri get tagUrl => newUri('index.php');


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    params['json'] = '1';
    params['s'] = 'post';
    params['q'] = 'index';
    params['page'] = 'dapi';
    params['pid'] = '${query.page}';
    params['tags'] = query.tags.join('+');
    if (query.postsLimit > 0) {
      params['limit'] = '${query.postsLimit}';
    }

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'name_pattern': '%$tagName%',
      'json': '1',
      's': 'tag',
      'q': 'index',
      'page': 'dapi',
    };
  }


  @override
  Post? getPost(Map json) {
    String? temp = json['image'];
    String? ext = temp != null ? temp.split('.')[1] : '';

    String? directory;
    String? fileName;

    json['booruName'] = name;
    json['file_ext'] = ext;
    json['md5'] ??= json['hash'];

    directory = json['directory']?.toString();
    fileName = json['md5']?.toString();

    json['preview_url'] ??= 'https://$domain/thumbnails/$directory/thumbnail_$fileName.jpg';

    json['sample_url'] ??= 'https://$domain/samples/$directory/sample_$fileName.$ext';

    json['file_url'] ??= 'https://$domain/images/$directory/$fileName.$ext';

    if (name == Rule34.name_ && Post.videos.contains(ext)) {
      final parts = json['sample_url'].toString().split('.');
      final nExt = parts[parts.length -1];
      if (nExt != ext) {
        json['sample_url'] = json['sample_url'].toString().replaceAll(nExt, ext);
      }
    }

    // print('---- $map');
    return Post.fromJson(json);
  }

  @override
  List<Post?> getPosts(List? json) {
    List<Post?> items = [];
    if (json == null) return items;

    for (var item in json) {
      items.add(getPost(item));
    }
    return items;
  }

  @override
  Future<Post?> findPostByMd5(String md5) async {
    var url = baseUrl.replace(queryParameters: {
        'page': 'post',
        's': 'list',
        'md5': md5,
      });

    final redirectUrl = await http.read(url);
    int id = removeText(redirectUrl);

    return await findPostById(id);
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
      path: 'index.php',
      query: 'page=post&s=list&tags=${tags.join('+')}',
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'index.php',
      query: 'page=post&s=view&id=${hashId.toString()}',
    );
  }


  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    Map<String, dynamic> params = getPostsParams(query);

    var uri = createUrl(imageUrl, params: params, rating: query.rating);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    if (response.isEmpty) return [];

    var map = jsonDecode(response);
    if (map is List) {
      return getPosts(map);
    }

    return getPosts(map['post']);
  }

}

abstract class IGelBooru2 extends IGelBooru {

  IGelBooru2({required List<BooruOptions> options}) : super(type: BooruType.gelbooru2,
      options: options..addAll([BooruOptions.tagApiXml, BooruOptions.generalRating]));

  @override
  Post? getPost(Map json) {
    String? temp = json['image'];
    String? ext = temp != null ? temp.split('.')[1] : '';

    String? directory;
    String? fileName;

    json['booruName'] = name;
    json['file_ext'] = ext;
    json['md5'] ??= json['hash'];

    directory = json['directory']?.toString();

    fileName = json['image']?.toString();
    fileName = fileName?.replaceAll('.$ext', '');

    // print(json['sample_url']);
    // print(json['file_url']);

    json['preview_url'] ??= 'https://$domain/thumbnails/$directory/thumbnail_$fileName.jpg';

    json['sample_url'] ??= 'https://$domain/samples/$directory/sample_$fileName.$ext';

    json['file_url'] ??= 'https://$domain/images/$directory/$fileName.$ext';

    if (name == Rule34.name_ && Post.videos.contains(ext)) {
      final parts = json['sample_url'].toString().split('.');
      final nExt = parts[parts.length -1];
      if (nExt != ext) {
        json['sample_url'] = json['sample_url'].toString().replaceAll(nExt, ext);
      }
    }

    // print('---- $map');
    return Post.fromJson(json);
  }

}