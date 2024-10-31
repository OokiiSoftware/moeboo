import '../../model/import.dart';
import '../import.dart';

abstract class IMoebooru extends ABooru {

  IMoebooru({List<BooruOptions>? options}) : super(BooruType.moeBooru, options: options);


  @override
  Uri get countUrl => newUri('counts/posts/index.json');

  @override
  Uri get imageUrl => newUri('post/index.json');

  @override
  Uri get tagUrl => newUri('tag/index.json');


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    params['page'] = '${query.page}';
    params['tags'] = query.tags.join('+');
    params['limit'] = '${query.postsLimit}';

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'name': tagName,
      'limit': '0',
    };
  }


  @override
  Post getPost(Map json) {
    json['booruName'] = name;
    dynamic score = json['score'];
    json['score'] = int.tryParse(score.toString());

    String? url = json['preview_url'];
    if (url != null && !url.contains('http')) {
      json['preview_url'] = '${baseUrl.scheme}${json['preview_url']}';
      json['sample_url'] = '${baseUrl.scheme}${json['sample_url']}';
      json['file_url'] = '${baseUrl.scheme}${json['file_url']}';
      json['jpeg_url'] = '${baseUrl.scheme}${json['jpeg_url']}';
    }

    if (json['file_ext'] == null) {
      var temp = json['sample_url'].toString().split('.');
      if (temp.isNotEmpty) {
        json['file_ext'] = temp[temp.length -1];
      }
    }

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
    if (name == Lolibooru.name_) {
      json['id'] = int.tryParse(json['id']);
      json['count'] = int.tryParse(json['post_count']);
      json['type'] = json['tag_type'];
    }

    return Tag(
      id: json['id'],
      name: json['name'],
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
      items.add(getTag(item));
    }
    return items;
  }


  @override
  Uri pageUri(List<String> tags) {
    var tag = '';
    if (tags.isEmpty) {
      tag = '';
    } else {
      tag = 'tags=${tags.join('+')}';
    }

    return Uri(
      scheme: useHttp ? 'http' : 'https',
      host: home,
      path: 'post',
      query: tag,
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri(
      scheme: useHttp ? 'http' : 'https',
      host: home,
      path: 'post/show/${hashId.toString()}',
    );
  }

}