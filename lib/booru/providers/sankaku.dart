import '../../model/import.dart';
import '../import.dart';

/// SankakuComplex. https://chan.sankakucomplex.com/
class Sankaku extends ISankaku {
  static const String name_ = 'Sankaku';

  Sankaku();

  @override
  String get name => name_;

  @override
  String get domain => 'capi-v2.sankakucomplex.com';

  @override
  String get home => 'chan.sankakucomplex.com';

  @override
  bool get isSafe => true;

}

class IdolComplex extends ISankaku {
  static const String name_ = 'IdolComplex';

  @override
  int get limitedPosts => 25;

  IdolComplex() : super(options: [BooruOptions.expireLinks]);

  @override
  String get name => name_;

  @override
  String get domain => 'iapi.sankakucomplex.com';

  @override
  String get home => 'idol.sankakucomplex.com';

  @override
  Uri get imageUrl => newUri('posts.json');

  @override
  Uri get tagUrl => newUri('tags.json');


  @override
  Post getPost(Map json) {
    String? temp = json['file_type'];
    String ext = '';
    if (temp != null) {
      ext = temp.split('/')[1];
    } else {
      String link = json['sample_url'] ?? json['file_url'] ?? '';
      link = link.split('?')[0];
      var sp = link.split('.');
      if (sp.isNotEmpty) {
        ext = sp.last;
      }
    }

    json['file_url'] = 'https:${json['file_url']}';
    json['sample_url'] = 'https:${json['sample_url']}';
    json['preview_url'] = 'https:${json['preview_url']}';

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

// @override
  // int get limitedPosts => 20;

  /*@override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {

    Map<String, dynamic> params = getPostsParams(query);
    query.page++;

    var uri = createUrl(imageUrl, params: params, rating: query.rating);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    if (response.isEmpty) return [];

    return getPosts(_getLastPosts(query, response));
  }

  @override
  Future<Post?> findCustomPost(String url) async {
    final res = await getJson(Uri.parse(url));

    final imgSample = getElementById(res, 'lowres');
    final imgOriginal = getElementById(res, 'highres');

    String? sample;
    String? original;

    if (imgSample != null) {
      sample = imgSample.attributes['href'];
    }
    if (imgOriginal != null) {
      original = imgOriginal.attributes['href'];
    }

    return Post.fromJson({
      'file_url': 'https:$original',
      'sample_url': 'https:$sample',
    });
  }



  List<Map> _getLastPosts(AlbumQuery query, String content) {
    final divs = getElementByName(content, 'post-preview post-preview-150 post-preview-fit-compact');

    List<Map> items = [];

    for (var element in divs) {
      final durationSpan = element.getElementsByClassName('duration');
      final imgs = element.getElementsByClassName('post-preview-image');

      bool video = false;
      if (durationSpan.isNotEmpty) {
        video = true;
      }

      final img = imgs.first;

      int charToInt(String char) {
        switch(char) {
          case 'a': return 0;
          case 'b': return 1;
          case 'c': return 2;
          case 'd': return 3;
          case 'e': return 4;
          case 'f': return 5;
          case 'g': return 6;
          case 'h': return 7;
          case 'j': return 8;
          case 'k': return 9;
          case 'l': return 10;
          case 'n': return 11;
          case 'o': return 12;
          case 'p': return 13;
          case 'q': return 14;
          case 'r': return 15;
          case 'u': return 16;
          case 'v': return 17;
          case 'w': return 18;
          case 'x': return 19;
          case 'y': return 20;
          case 'z': return 21;
          case 'A': return 22;
          case 'B': return 23;
          case 'C': return 24;
          case 'D': return 25;
          case 'E': return 26;
          case 'F': return 27;
          case 'G': return 28;
          case 'H': return 29;
          case 'I': return 30;
          case 'J': return 31;
          case 'K': return 32;
          case 'L': return 33;
          case 'M': return 34;
          case 'N': return 35;
          case 'O': return 36;
          case 'P': return 37;
          case 'Q': return 38;
          case 'R': return 39;
          case 'S': return 40;
          case 'T': return 41;
          case 'U': return 42;
          case 'V': return 43;
          case 'W': return 44;
          case 'X': return 45;
          case 'Y': return 46;
          case 'Z': return 47;
          default: return 0;
        }
      }

      String idTemp = element.attributes['data-id']*//*?.replaceAll('p', '')*//* ?? '';
      String id = '';
      for (int i = 0; i < idTemp.length; i++) {
        if (id.length > 6) break;
        id += '${charToInt(idTemp[i])}';
      }

      //Rating:R15+ Score:5.0 Size:1382x720 ID:8JaGkVA4aLj User:msgundam2"
      final item = {
        'id': int.parse(id),
        'preview_url': 'https:${img.attributes['src'] ?? ''}',
        'tags': '',
        // 'idIdol': idTemp,
        'preview_width': int.tryParse(img.attributes['width'] ?? '0'),
        'preview_height': int.tryParse(img.attributes['height'] ?? '0'),
        'file_ext': video ? 'mp4': 'jpg',
        'custom_url': 'https://idol.sankakucomplex.com/posts/$idTemp',
      };

      final tags = img.attributes['data-auto_page'] ?? '';
      tags.split(' ').forEach((tag) {
        if (tag.contains(':')) {
          final values = tag.toLowerCase().split(':');
          String key = values[0];
          if (key.toLowerCase() != 'id') {
            item[key] = values[1];
          }
          if (key.toLowerCase() == 'size') {
            final size = values[1].split('x');
            item['width'] = int.parse(size[0]);
            item['height'] = int.parse(size[1]);
          }
          if (key.toLowerCase() == 'user') {
            item['tags'] = '${item['tags']} ${values[1]}';
          }
        } else {
          item['tags'] = '${item['tags']} $tag';
        }
      });

      items.add(item);
    }

    return items;
  }

  Future<Post?> getPostByStringId(String? id) async {
    Uri uri = imageUrl.replace(path: 'posts/$id');

    log.d(name, 'getPostById', 'uri', uri);
    String response = await getJson(uri);

    return getPost(await _getPostById(response));
  }

  Future<Map> _getPostById(String content) async {
    final a = getElementById(content, 'highres');
    final image = getElementById(content, 'image');

    Map item = {};

    if (a == null) return item;

    final text = a.text.trim(); // 869x1080 (196.4 KB)

    final textTemp = text.split(' '); // [869x1080, (196.4 KB)]
    final link = a.attributes['href'] ?? '';

    var textSize = textTemp[1];

    var linkA = link.split('?'); // [link, token]
    linkA = linkA[0].split('.');

    String ext = linkA[linkA.length-1];

    textSize = textSize.replaceAll('(', '').replaceAll(' KB)', '');

    item = {
      'file_url': 'https:$link',
      'size': double.tryParse(textSize)?.toInt(),
      'sample_url': 'https:${image?.attributes['src'] ?? ''}',
      'width': int.tryParse(image?.attributes['width'] ?? '0'),
      'height': int.tryParse(image?.attributes['height'] ?? '0'),
      'file_ext': ext,
    };

    return item;
  }*/

}
