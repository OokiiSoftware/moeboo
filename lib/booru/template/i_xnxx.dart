import '../../model/import.dart';
import '../import.dart';

abstract class IXnxx extends ABooru {

  @override
  int get firstPage => 0;

  IXnxx({List<BooruOptions>? options}) : super(BooruType.xnxx, options: options);


  @override
  Uri get countUrl => baseUrl;

  @override
  Uri get imageUrl => baseUrl;

  @override
  Uri get tagUrl => baseUrl;


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    // params['page'] = '${query.page}';
    // params['tags'] = query.tags.join('+');
    // params['limit'] = '${query.postsLimit}';

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      // 'search[fuzzy_name_matches]': tagName,
    };
  }


  @override
  Post getPost(Map json) {
    json['booruName'] = name;
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
      path: 'search/${tags.join('+')}',
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

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    Map<String, dynamic> params = getPostsParams(query);

    String path = '';
    if (query.tags.isEmpty) {
      path = 'search/pussy/${query.page}';
    } else {
      path = 'search/${query.tags.first}/${query.page}';
    }

    Uri temp = imageUrl.replace(path: path);

    var uri = createUrl(temp, params: params, rating: query.rating);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);
    // print(response);
    if (response.isEmpty) return [];

    return getPosts(_findPosts(response, query.tags.isNotEmpty));
  }

  @override
  Future<List<Tag>> findTags(String? tagName) async {
    if (tagName == null || tagName.isEmpty) return [];

    // /search/$tagName/

    String path = '/tags';

    var url = createUrl(tagUrl.replace(path: path));
    log.d(name, 'getTagsAsync', url);

    String response = await getJson(url);
// print(response);
    return getTags(_findTags(response, tagName));
  }

  @override
  Future<Post?> findCustomPost(String url) async {
    final res = await getJson(Uri.parse(url));
    final divVideo = getElementById(res, 'html5video_base');
    final a = divVideo?.getElementsByTagName('a');

    final aTags = getElementByName(res, 'is-keyword');
    final Map map = {};
    String tags = '';

    int i = 0;
    a?.forEach((element) {
      if (i == 0) {
        map['file_url'] = element.attributes['href'];
      } else if (i == 1) {
        map['sample_url'] = element.attributes['href'];
      }
      i++;
    });

    for (var element in aTags) {
      String? tag = element.attributes['href'];
      tag = tag?.replaceAll('/search/', '');

      if (tag != null) {
        tags += '$tag ';
      }
    }
    map['tags'] = tags;

    return getPost(map);
  }


  List<Map> _findPosts(String content, bool isUser) {
    List<Map> items = [];

    final elements = getElementByName(content, 'thumb-inside');

    for (var element in elements) {
      final a = element.getElementsByTagName('a');
      final img = element.getElementsByTagName('img');

      items.add({
        'id': int.tryParse(img.first.attributes['data-videoid'] ?? '0') ?? 0,
        'preview_url': img.first.attributes['data-src'],
        'custom_url': 'https://$domain${a.first.attributes['href']}',
        'file_ext': 'mp4',
      });
    }

    return items;
  }

  List<Map> _findTags(String content, String tagName) {
    List<Map> items = [];
    final elements = getElementById(content, 'tags');

    if (elements == null) return items;

    for (var element in elements.children) {
      final a = element.getElementsByTagName('a');
      final strong = element.getElementsByTagName('strong');

      String? tag = a.first.attributes['href'];
      String? count = strong.first.text;

      tag = tag?.replaceAll('/search/', '');
      count = count.replaceAll(',', '');

      if (tag != null && tag.contains(tagName)) {
        items.add({
          'id': items.length,
          'name': tag,
          'post_count': int.tryParse(count) ?? 0,
        });
      }
    }

    return items;
  }
}
