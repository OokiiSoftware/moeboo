import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as html;
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import '../../model/import.dart';
import '../import.dart';

abstract class IBooru {

  //region variaveis

  String get name;
  String get domain;
  String get home;
  String? deviantToken;

  bool get isSafe => false;
  int get limitedPosts => 100;
  int get firstPage => 1;
  Map<String, String>? get headers => null;

  final BooruType type;
  late BooruOpt options;
  late Uri baseUrl, countUrl, imageUrl, tagUrl;

  static Random random = Random();

  bool get isDanbooru => type.isDan;
  bool get isGelbooru => type.isGeo;
  bool get isMoebooru => type.isMoe;
  bool get isSankaku => type.isSan;
  bool get isArtStat => type.isArt;
  bool get isDeviant => type.isDev;
  bool get isEHentai => type.isHen;
  bool get isKemono => type.isKem;

  //endregion

  IBooru(this.type, {List<BooruOptions>? options}) {
    this.options = BooruOpt(options);

    if (this.options.contains(BooruOptions.http)) {
      baseUrl = Uri.http(domain, '');
    } else {
      baseUrl = Uri.https(domain, '');
    }

    countUrl = _createPathLink('counts/posts');
    imageUrl = _createPathLink('post');
    tagUrl = _createPathLink('tag');
  }

  //region get

  Uri pageUri(List<String> tags) => throw FeatureUnavailable();

  Uri postUri(dynamic hashId) => throw FeatureUnavailable();


  @protected
  Post? getPost(Map json) => throw FeatureUnavailable();

  @protected
  List<Post?> getPosts(List? json) => throw FeatureUnavailable();

  @protected
  Map<String, dynamic> getPostsParams(AlbumQuery query) => throw FeatureUnavailable();


  @protected
  Tag? getTag(Map json) => throw FeatureUnavailable();

  @protected
  List<Tag> getTags(List? json) => throw FeatureUnavailable();

  @protected
  Map<String, String> getTagsParams(String tagName) => throw FeatureUnavailable();

  //endregion

  //region has

  bool get useGeneralRating => !options.contains(BooruOptions.generalRating);
  bool get hasExpireLinks => options.contains(BooruOptions.expireLinks);
  bool get useTagsXml => options.contains(BooruOptions.tagApiXml);
  bool get useHttp => options.contains(BooruOptions.http);

  //endregion

  //region find

  Future<List<Post?>> findPosts({required AlbumQuery query}) async => throw FeatureUnavailable();

  Future<int> findPostsCount(List<String>? tagsArg) async => throw FeatureUnavailable();

  Future<List<Post?>> findParents(int id) async => throw FeatureUnavailable();

  Future<Post?> findPostByMd5(String md5) async => throw FeatureUnavailable();

  Future<Post?> findPostById(int id) async => throw FeatureUnavailable();


  Future<List<Tag>> findTags(String? tagName) async => throw FeatureUnavailable();

  Future<Tag?> findTagByName(String name) async => throw FeatureUnavailable();

  Future<Tag?> findTagById(int id) async => throw FeatureUnavailable();

  Future<Post?> findCustomPost(String url) async => throw FeatureUnavailable();

  //endregion

  //region Metodos

  @protected
  Future<String> getJson(Uri url, {Map<String, String>? headers}) async {
    headers??= {};

    /*final mapAuth = {
      "ArtStation": "",
      "DeviantArt": "",
      "EHentai": "",
      "Atfbooru": "",
      "Danbooru": "",
      "Hypnohub": "user_id=53353; pass_hash=4a77ba7754d4e94fbd5110f7269c7268c503ae2d",
      "Lolibooru": "user_id=26830; login=lisannas; pass_hash=4a77ba7754d4e94fbd5110f7269c7268c503ae2d",
      "Real": "user_id=10285; pass_hash=94c6b0668c58929a9dc83526b98c7b004229d71b",
      "Rule": "user_id=124813; pass_hash=94c6b0668c58929a9dc83526b98c7b004229d71b",
      "XBooru": "user_id=39634; pass_hash=94c6b0668c58929a9dc83526b98c7b004229d71b",
      "Gelbooru": "user_id=252137; pass_hash=94c6b0668c58929a9dc83526b98c7b004229d71b",
      "Safe": "user_id=13034; pass_hash=94c6b0668c58929a9dc83526b98c7b004229d71b",
      "Yandere": "user_id=246859; pass_hash=",
      "3D Booru": "login=lisannas; pass_hash=99f752b603c8adc49e64695c5131d8074ec89602",
      "Bleach": "login=lisannas; pass_hash=",
      "IdolComplex": "login=lisannas; pass_hash=",
      "Sakuga": "login=lisannas; pass_hash=c1502de3e12666379f2591d56cff1442b9ea227e",
      "Konachan": "login=lisannas; pass_hash=f9b3e13afd625e9c79bc2fc679abbc927b8514d6",
      "Sankaku": "login=lisannas; pass_hash=963e7b4c00f75a45cb35b4f4659c5ff5c5be42b1"
    };*/

    // headers['Cookie'] = mapAuth[currentBooru]!;

    // switch(type) {
    //   case BooruType.gelbooru:
    //     headers['Cookie'] = 'user_id=; passhash=';
    //     break;
    //   case BooruType.moeBooru:
    //   case BooruType.sankaku:
    //     headers['Cookie'] = 'login=lisannas; passhash=963e7b4c00f75a45cb35b4f4659c5ff5c5be42b1';
    //     break;
    // }

    final response = await http.get(Uri.parse(Uri.decodeComponent(url.toString())), headers: headers);

    if (response.statusCode != 200) {
      if (isDeviant && response.body.contains('Expired oAuth2') || response.body.contains('Must provide an access_token')) {
        await updateToken();
        return await getJson(url.replace(
          query: '${url.query}&access_token=$deviantToken',
        ));
      }

      throw ('Failed to load data on url: $url\n${response.body}');
    }

    return response.body;
  }

  Future<void> addFavorite(int postId) async {
    /// somente Gel
    final url = createUrl(baseUrl, path: 'public/addfav.php', params: {'id': '$postId'});

    final response = await getJson(url);

    if (response == '2') {
      throw('Erro de autenticação ao add favorito.');
    }
  }

  @protected
  Future<String> getXml(Uri url) async {
    final myTransformer = Xml2Json();
    var xmlString = await getJson(url);

    myTransformer.parse(xmlString);
    var json = myTransformer.toBadgerfish().replaceAll('@', '');

    if (json.contains('{"tags": {"type": "array", "tag": ')) {
      json = json.replaceAll('{"tags": {"type": "array", "tag": ', '').replaceAll(']}}', ']');
    } else {
      json = '[]';
    }

    return json;
  }

  Future<void> updateToken() async {
    if (!isDeviant) return;

    Map<String, dynamic> headers = {
      'grant_type': 'client_credentials',
      'client_id': '21647',
      'client_secret': '6fd28570749c1fd7baa0db22f3675a68',
    };

    String path = 'oauth2/token';
    var url = createUrl(tagUrl, params: headers, path: path);
    // Log.d('ABooruPost', 'getTagsAsync', url);
    String? json = await getJson(url);
    Map map = jsonDecode(json);
    // Log.d('ABooruPost', 'updateToken', map);
    deviantToken = map['access_token'];
  }


  @protected
  Uri _createPathLink(String query, [String squery = "index"]) {
    String queryString;

    switch (type) {
      case BooruType.moeBooru:
        queryString = "$query/$squery.json";
        break;
      case BooruType.gelbooru:
        queryString = "index.php";
        break;
      case BooruType.danbooru:
        queryString = query == "related_tag" ? "$query.json" : "${query}s.json";
        break;
      case BooruType.kemono:
        queryString = "api/v1/${query}s";
        break;
      case BooruType.sankaku:
        queryString = query == "wiki" ? query : "${query}s";
        break;
      case BooruType.artStation:
        queryString = 'projects.json';
        break;

      default:
        return baseUrl;
    }
    return newUri(queryString);
  }

  @protected
  Uri createUrl(Uri url, {String? path, List<String>? rating, Map<String, dynamic>? params}) {

    List<String> ratings = rating ?? <String>[];
    Map<String, dynamic> paramsT = {...params ?? {}};

    if (ratings.isNotEmpty) {
      String nRat = '';

      if (options.contains(BooruOptions.generalRating) && ratings.contains(Rating.safeValue)) {
        ratings.remove(Rating.safeValue);
        ratings.add(Rating.generalValue);
      }

      bool negativeRat = false;

      if (options.contains(BooruOptions.generalRating)) {
        if (ratings.contains(Rating.safeValue)) {
          ratings.remove(Rating.safeValue);
          ratings.add(Rating.generalValue);
        }
      }

      switch(ratings.length) {
        case 1:
          nRat = ratings[0];
          break;
        case 2:
          negativeRat = true;
          nRat = Rating.values.firstWhere((e) => !ratings.contains(e), orElse: () => '');
          // if (!ratings.contains(Rating.safeValue)) {
          //   if (options.contains(BooruOptions.generalRating)) {
          //     nRat = Rating.generalValue;
          //   } else {
          //     nRat = Rating.safeValue;
          //   }
          // } else if (!ratings.contains(Rating.questionableValue)) {
          //   nRat = Rating.questionableValue;
          // } else if (!ratings.contains(Rating.explicitValue)) {
          //   nRat = Rating.explicitValue;
          // }
          break;
      }

      if (nRat.isNotEmpty) {
        final tagsTemp = paramsT['tags'] ?? '';
        switch(type) {
          case BooruType.gelbooru:
            paramsT['tags'] += '${negativeRat ? '&-' : '+'}rating:$nRat';
            break;
          case BooruType.ehentai:
            // if (paramsT.containsKey('f_search')) {
            //   paramsT['f_search'] += ' $nRat';
            // } else {
            //   paramsT['f_search'] = nRat;
            // }
            break;
          default:
            if (tagsTemp.isNotEmpty) {
              paramsT['tags'] += '${negativeRat ? '&-' : '+'}rating:$nRat';
            } else {
              paramsT['tags'] = '${negativeRat ? '-' : ''}rating:$nRat';
            }
        }
      }
    }

    return newUri(path, params: paramsT, baseUrl: url);
  }

  Uri newUri(String? path, {Uri? baseUrl, String? host, Map<String, dynamic>? params}) {
    baseUrl??= this.baseUrl;
    return Uri(
      scheme: baseUrl.scheme,
      path: baseUrl.path + (path ?? ''),
      host: host ?? baseUrl.host,
      queryParameters: params,
    );
  }


  @protected
  List<html.Element> getElementByName(String content, String name) {
    final doc = html.Document.html(content);
    return doc.getElementsByClassName(name);
  }

  @protected
  List<html.Element> getElementTagName(String content, String name) {
    final doc = html.Document.html(content);
    return doc.getElementsByTagName(name);
  }

  @protected
  html.Element? getElementById(String content, String name) {
    final doc = html.Document.html(content);
    return doc.getElementById(name);
  }


  static bool removeWithRating(Post? post, List<String> rating) {
    if (post == null) return true;

    if (rating.isEmpty) return false;

    if (post.rating.isSafe) return !rating.contains(Rating.safeValue);

    return !rating.contains(post.rating.value);
  }

  static bool permitirWithRating(PostG? post, List<String> rating) {
    if (post == null) return false;

    post.removeWhere((item) => removeWithRating(item, rating));

    return post.isNotEmpty;
  }

  //endregion

}
