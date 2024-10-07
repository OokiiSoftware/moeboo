import '../../oki/import.dart';
import '../../model/import.dart';
import '../import.dart';

abstract class IFapello extends ABooru {

  @override
  int get firstPage => 0;

  IFapello({List<BooruOptions>? options}) : super(BooruType.fapello, options: options);

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

  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    Map<String, dynamic> params = getPostsParams(query);

    String path = '';
    if (query.tags.isEmpty) {
      path = '${imageUrl.path}${query.page + 1}';
    } else {
      path = '/ajax/model/${query.tags.first}/page-${query.page + 1}';
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

    String path = '/search/$tagName/';

    var url = createUrl(tagUrl.replace(path: path));
    log.d('getTagsAsync', url);

    String response = await getJson(url);
// print(response);
    return getTags(_findTags(response, tagName));
  }

  List<Map> _findPosts(String content, bool isUser) {
    List<Map> items = [];
    if (isUser) {
      final elements = getElementByName(content, 'max-w-full');

      for (var element in elements) {
        final isVideo = element.getElementsByClassName('w-16 h-16').isNotEmpty;
        final img = element.getElementsByClassName('w-full h-full');

        final elem = img.first;

        String? url = elem.attributes['src'];
        url = url?.replaceAll('_300px', '');
        if (isVideo) {
          url = url?.replaceAll('.jpg', '.mp4');
        }

        items.add({
          'id': randomInt(50000),
          'tags': elem.attributes['alt']?.toLowerCase().replaceAll(' ', '-'),
          'preview_url': elem.attributes['src'],
          'file_url': url,
          'file_ext': isVideo ? 'mp4': 'jpg',
        });
      }
    } else {
      final elements = getElementByName(content, 'grid grid-cols-2 gap-2 p-2');

      for (var element in elements) {
        final isVideo = element.getElementsByClassName('w-16 h-16').isNotEmpty;

        for (var a in element.children) {
          final img = a.children.first;

          String? url = img.attributes['src'];
          url = url?.replaceAll('_300px', '');
          if (isVideo) {
            url = url?.replaceAll('.jpg', '.mp4');
          }

          items.add({
            'id': randomInt(50000),
            'tags': a.attributes['href']?.replaceAll('https://fapello.com/', '').replaceAll('/', ''),
            'preview_url': img.attributes['src'],
            'file_url': url,
            'file_ext': isVideo ? 'mp4': 'jpg',
          });
        }
      }
    }

    return items;
  }

  List<Map> _findTags(String content, String tagName) {
    List<Map> items = [];
    final elements = getElementByName(content, 'flex flex-1');

    for (var element in elements) {
      String? tag = element.children.first.attributes['href'];

      tag = tag?.replaceAll('https://fapello.com/', '').replaceAll('/', '');

      if (tag != null && tag.contains(tagName)) {
        items.add({
          'id': items.length,
          'name': tag,
          'post_count': 0,
        });
      }
    }

    return items;
  }
}
