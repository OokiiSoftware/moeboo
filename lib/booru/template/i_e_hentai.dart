import 'dart:convert';
import '../../model/import.dart';
import '../../oki/import.dart';
import '../import.dart';

abstract class IEHentai extends ABooru {

  static const int _limitedTagsEHentaiSearchCount = 10;

  IEHentai({List<BooruOptions>? options}) :
        super(BooruType.ehentai, options: options?..add(BooruOptions.expireLinks));


  @override
  Uri get countUrl => baseUrl;

  @override
  Uri get imageUrl => baseUrl;

  @override
  Uri get tagUrl => baseUrl;


  @override
  Map<String, dynamic> getPostsParams(AlbumQuery query) {
    Map<String, dynamic> params = {};

    params['page'] = '${query.eQueryPage}';
    params['limit'] = '${query.postsLimit}';

    if (query.tags.isNotEmpty) {
      params['f_search'] = query.tags.join('_');
      params['f_stags'] = 'on';
      params['advsearch'] = '1';
    }

    return params;
  }

  @override
  Map<String, String> getTagsParams(String tagName) {
    return {
      'f_search': tagName.replaceAll('_', '+'),
      'advsearch': '1',
      'f_stags': 'on',
    };
  }


  @override
  Post getPost(Map json) {
    bool isSafe = json['tags']?.contains('non-nude') ?? false;
    json['rating'] = Rating.fromBool(!isSafe).valueTag;

    json['file_ext'] = 'jpg';
    json['booruName'] = name;

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
      id: int.tryParse(json['id']) ?? 0,
      name: json['name'] ?? '',
      // count: json['count'],
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
      query: 'f_search=${tags.join('+')}',
    );
  }

  @override
  Uri postUri(dynamic hashId) {
    return Uri.parse(hashId);
  }


  @override
  Future<List<Post?>> findPosts({required AlbumQuery query}) async {
    List<String> rating = [...query.rating ?? []];

    Map<String, dynamic> params = getPostsParams(query);

    if (rating.length == 1) {
      if (rating.contains(Rating.safeValue)) {
        rating.remove(Rating.safeValue);
        rating.add('non-nude');
      }
    }

    var uri = createUrl(imageUrl, params: params, rating: rating);

    log.d(name, type.value, 'getLastPosts', 'uri', uri);

    String response = await getJson(uri);

    if (response.isEmpty) return [];

    return getPosts(await _findPostsEHentai(query, response));
  }

  @override
  Future<List<Tag>> findTags(String? tagName) async {
    if (tagName == null || tagName.isEmpty) return [];

    String? path;
    Map<String, String> params = {};

    params['f_search'] = tagName.replaceAll('_', '+');
    params['advsearch'] = '1';
    params['f_stags'] = 'on';

    var url = createUrl(tagUrl, path: path, params: params);
    log.d('EHentaiProvider: getTagsAsync', url);

    late String response;
    if (useTagsXml) {
      response = await getXml(url);
    } else {
      response = await getJson(url);
    }

    return getTags(await _findTagsEHentai(response, tagName));
  }

  @override
  Future<Post?> findPostById(int id) async {
    Uri uri = imageUrl;

    log.d(name, 'getPostById', 'uri', uri);
    String? temp = await getJson(uri);
    var obj = jsonDecode(temp);

    var obj2 = obj;
    if (obj is Map) {
      if (obj.containsKey('post')) {
        obj2 = obj['post'];
      } else if (obj.containsKey('results')) {
        obj2 = obj['results'];
      } else if (obj.containsKey('data')) {
        obj2 = obj['data'];
      }
    }

    if (obj2 == null) return null;
    if (obj2 is Map) return getPost(obj);

    return getPosts(obj2)[0];
  }

  @override
  Future<Post?> findCustomPost(String url) async {
    log.d(name, 'findCustomPost', 'url', url);
    final res = await getJson(Uri.parse(url));
    final divImg = getElementById(res, 'img');
    final divSize = getElementById(res, 'i4');

    final Map map = {};

    var text = divSize?.children.first.text ?? '';
    if (text.isNotEmpty) {
      text = text.replaceAll(' ', '');
      int i1 = text.indexOf('::');
      int i2 = text.indexOf('::', i1+1);

      final dimText = text.substring(i1+'::'.length, i2);
      final size = text.substring(i2+'::'.length, text.indexOf('K'));

      final dimension = dimText.split('x');

      map['width'] = int.tryParse(dimension[0]);
      map['height'] = int.tryParse(dimension[1]);
      map['file_size'] = int.tryParse(size);
    }

    map['file_url'] = divImg?.attributes['src'];
    
    return getPost(map);
  }

  //region eHentai

  Future<List<Map>> _findTagsEHentai(String content, String? tagQuery) async {
    if (tagQuery == null || tagQuery.isEmpty) return [];
    tagQuery = tagQuery.replaceAll('_', '+');
    int pagesCount = 100;// _getTagsPagesCountEHentai(content);
// print(pagesCount);
    if (pagesCount == 0) return [];
    // print(pagesCount);

    if (pagesCount > _limitedTagsEHentaiSearchCount) pagesCount = _limitedTagsEHentaiSearchCount;

    List<String> tagsTemp = [];
    List<Map> tags = [];
    bool showLog = true;

    for(int i = 0; i < pagesCount; i++) {
      final url = createUrl(baseUrl, params: {
        'page': '$i',
        'f_search': tagQuery,
        'f_stags': 'on',
        'advsearch': '1',
      });
      // newUri('', query: 'page=$i&f_search=$tagQuery&f_stags=on&advsearch=1');
      log.d('findTagsEHentai', url);

      final response = await getJson(url);

      final tagsDiv = getElementByName(response, 'gt');
      if (tagsDiv.isEmpty) continue;

      for (var element in tagsDiv) {
        String text = element.attributes['title'] ?? '';

        if (text.contains(tagQuery.replaceAll('+', ' ')) && !tagsTemp.contains(text)) {
          tagsTemp.add(element.attributes['title']!);
        }
      }

      if (showLog) {
        showLog = false;
        // print(response);
      }
    }

    for (var tag in tagsTemp) {
      var t = tag.split(':');
      var tipo = t[0];
      var nome = t[1];
      tags.add({
        'id': '${tags.length +1}',
        'name': nome.replaceAll(' ', '_'),
        'type': tipo.replaceAll('parody', 'copyright'),
      });
    }

    return tags;
  }

  Future<List<Map>> _findPostsEHentai(AlbumQuery query, String content) async {
    List<String> links = _getGaleryLinksEHentai(query, content);
    int pagesCount = links.length;
    if (pagesCount == 0) return [];

    if (pagesCount > _limitedTagsEHentaiSearchCount) {
      pagesCount = _limitedTagsEHentaiSearchCount;
    }

    List<String> galeryPages = await _getPostsGalerysEHentai(links);

    return _getPostsEHentai(query, galeryPages);
  }

  List<String> _getGaleryLinksEHentai(AlbumQuery query, String content) {
    List<String> urls = [];
    Map<List<String>, int> linksData = {};
    int queryIndex = query.eQueryIndex;

    //region find links
    final tabDiv = getElementByName(content, 'gl3c glname');
    final pagesDiv = getElementByName(content, 'gl4c glhide');
    if (tabDiv.isEmpty) return [];
    if (queryIndex >= tabDiv.length) return [];

    int postsCount = 0;

    List<String> getLink(int qIndex, [int gPage = 0]) {
      String postLink = tabDiv[qIndex].children.first.attributes['href']!;
      final pagsDiv = pagesDiv[qIndex].getElementsByTagName('div');

      pagsDiv.removeWhere((element) => !element.text.toLowerCase().contains('pages'));

      if (pagsDiv.isNotEmpty) {
        int count = removeText(pagsDiv.first.text);
        // postsCount += count;
        int pagesCount = count ~/ 40;

        // if (pagesCount <= gPage) {
        //   query.eQueryIndex++;
        //   query.eGaleryPage = 0;
        //   query.eGaleryIndex = 0;
        // } else {
        //   query.eGaleryPage++;
        // }print(query.eGaleryPage);
        // if (postsCount < query.postsLimit && pagesCount > gPage) {
        //   return ['$postLink?p=$qIndex'] + getLink(qIndex, gPage +1);
        // }

        final list = List<String>.generate(pagesCount +1, (i) => '$postLink?p=$i');
        linksData[list] = count;
        return list;
      }

      return ['$postLink?p=$gPage'];
    }

    for(int i = queryIndex; i < tabDiv.length; i++) {
      getLink(i, query.eGaleryPage);
      postsCount = linksData.values.reduce((value, element) => value + element);
    }

    postsCount = 0;

    for(int i = 0; i < linksData.length; i++) {
      final list = linksData.keys.toList();
      final links = list[i];
      final galeryCount = linksData[links]!;
      Map<String, int> linksEndCount = {};
      bool canBreak = false;
      // final pagesCount = galeryCount ~/ 40;

      int lastPagesCount = galeryCount;

      for(int i = 40; i <= galeryCount; i+=40) {
        lastPagesCount -= 40;
      }

      for (var link in links) {
        int count = link == links.last ? lastPagesCount : 40;
        linksEndCount[link] = count;
      }

      bool eGaleryPageReseted = false;

      for(int i = query.eGaleryPage; i < linksEndCount.length; i++) {
        final list = linksEndCount.keys.toList();
        String link = list[i];
        int count = linksEndCount[link]!;
        postsCount += count;

        urls.add('$link&inline_set=ts_l');

        if (link == list.last) {
          query.eGaleryPage = 0;
          eGaleryPageReseted = true;
        } else {
          query.eGaleryPage++;
        }
        if (postsCount > query.postsLimit) {
          canBreak = true;
          break;
        }
      }

      if (links == list.last) {
        query.resetEHent();
        query.eQueryPage++;
      }else if (eGaleryPageReseted) {
        query.eQueryIndex++;
      }

      if (canBreak) break;
    }

    //endregion

    return urls;
  }

  Future<List<String>> _getPostsGalerysEHentai(List<String> links) async {
    List<String> contents = [];
    // bool printf = true;

    for (var link in links) {
      final url = Uri.parse(link);
      final response = await getJson(url);
      contents.add(response);
      // if (printf) {
      //   print(response);
      //   printf = false;
      // }
    }

    return contents;
  }

  List<Map> _getPostsEHentai(AlbumQuery query, List<String> contents) {
    Map<String, List<Map>> items = {};
    int postsCount = 0;

    for (var content in contents) {
      final tabDiv = getElementByName(content, 'gdtm');
      final tagsDiv = getElementById(content, 'taglist');

      final divs = tagsDiv?.getElementsByTagName('a');

      List<String> tags = [];
      divs?.forEach((element) {
        if (element.text.isNotEmpty && !tags.contains(element.text)) {
          tags.add(element.text.replaceAll(' ', '_'));
        }
      });

      for (int i = 0; i < tabDiv.length; i++) {
        final a = tabDiv[i].getElementsByTagName('a');
        if (a.isEmpty) continue;

        //region variaveis
        String style = tabDiv[i].children.first.attributes['style']!;

        int i1 = style.indexOf('width:');
        int i2 = style.indexOf('px;', i1);

        int width = int.parse(style.substring(i1 + 'width:'.length, i2));

        i1 = style.indexOf('height:');
        i2 = style.indexOf('px;', i1);

        int height = int.parse(style.substring(i1 + 'height:'.length, i2));

        i1 = style.indexOf('url(');
        i2 = style.indexOf(')', i1);
        int ipx = style.indexOf('px', i2);

        String preview = style.substring(i1+ 'url('.length, i2);
        String px = style.substring(i2+ ')'.length, ipx);

        String link = a.first.attributes['href']!;
        //endregion

        if (!items.containsKey(preview)) {
          items[preview] = [];
        }

        final item = <String, dynamic>{
          'id': removeText(link),
          'source': link,
          'preview_url': preview,
          'preview_width': width,
          'preview_height': height,
          'tags': tags.join(' '),
          'preview_index': removeText(px),
        };

        items[preview]!.add(item);
      }

      if (postsCount > query.postsLimit) break;
    }

    List<Map> items2 = [];
    for (var link in items.keys) {
      int maiorHeight = 0;
      for (var post in items[link]!) {
        if (post['preview_height'] > maiorHeight) {
          maiorHeight = post['preview_height'];
        }
      }

      for (Map post in items[link]!) {
        post['preview_length'] = items[link]!.length;
        post['maior_height'] = maiorHeight;

        items2.add(post);
      }
    }

    return items2;
  }

  // ignore: unused_element
  int _getTagsPagesCountEHentai(String content) {
    final countClass = getElementByName(content, 'ip');
    // countClass.removeWhere((element) => !element.text.contains('Showing'));

    if (countClass.isEmpty) return 0;

    int count = removeText(countClass.first.text);

    return count > 25 ? (count ~/ 25) : count == 0 ? 0:1;// cada pagina contem 25 itens
  }

  //endregion

}

class EHentaiResponse {
  late int gid;
  late String token;
  late String archiverKey;
  late String title;
  late String titleJpn;
  late String category;
  late String thumb;
  late String uploader;
  late int posted;
  late int filecount;
  late int filesize;
  late bool expunged;
  final List<String> tags = [];

  EHentaiResponse.fromJson(Map? map) {
    if (map == null) return;

    gid = map['gid'];
    token = map['token'];
    archiverKey = map['archiver_key'];
    title = map['title'];
    titleJpn = map['title_jpn'];
    category = map['category'];
    thumb = map['thumb'];
    uploader = map['uploader'];
    expunged = map['expunged'];

    for (var tag in (map['tags'] as List)) {
      tags.add(tag.toString());
    }

    posted = int.parse(map['posted']);
    filecount = int.parse(map['filecount']);
    filesize = map['filesize'];
  }

  static List<EHentaiResponse> fromJsonList(List? map) {
    if (map == null) return [];
    List<EHentaiResponse> items = [];

    for (var value in map) {
      items.add(EHentaiResponse.fromJson(value));
    }

    return items;
  }
}