import '../../model/import.dart';
import '../import.dart';

abstract class ISankaku extends ABooru {

  ISankaku({List<BooruOptions>? options}) :
        super(BooruType.sankaku, options: options?..add(BooruOptions.expireLinks));

  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};
    int limit = query.postsLimit;

    params['page'] = '${query.page}';
    params['tags'] = query.tags.join('+');
    params['limit'] = '$limit';

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'name': tagName,
    };
  }


  @override
  Post getPost(Map json) {
    String temp = json['file_type'];
    String ext = temp.split('/')[1];

    List? tags = json["tags"];
    List<String> tagsList = [];
    tags?.forEach((item) {
      tagsList.add(item['name_en'].replaceAll(' ', '_'));
    });

    json['booruName'] = name;
    json['file_ext'] = ext;
    json['score'] = json['total_score'];
    json['tags'] = tagsList.join(' ');
    return Post.fromJson(json);
  }

  @override
  List<Post> getPosts(List? json, {Function? onError}) {
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
      id: json['id'],
      name: json['name_en'].replaceAll(' ', '_'),
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
    return Uri(
      scheme: 'https',
      host: home,
      path: 'pt',
      query: 'tags=${tags.join('+')}',
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri(
      scheme: 'https',
      host: home,
      path: 'pt/post/show/${hashId.toString()}',
    );
  }

}