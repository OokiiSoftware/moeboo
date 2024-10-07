import '../../model/import.dart';
import '../import.dart';

abstract class IDanbooru extends ABooru {

  IDanbooru({List<BooruOptions>? options}) : super(BooruType.danbooru, options: options);

  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    params['page'] = '${query.page}';
    params['tags'] = query.tags.join('+');
    if (query.postsLimit > 0) {
      params['limit'] = '${query.postsLimit}';
    }
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