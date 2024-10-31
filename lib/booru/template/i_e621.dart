import '../../model/import.dart';
import '../import.dart';

abstract class IE621 extends IDanbooru {

  IE621({super.options});

  @override
  Post getPost(Map json) {
    json['booruName'] = name;

    Map? preview = json['preview'];
    Map? sample = json['sample'];
    Map? file = json['file'];
    Map? tags = json['tags'];
    List source = json['sources'] ?? [];

    json['preview_url'] = preview?['url'];
    json['sample_url'] = sample?['url'];
    json['file_url'] = file?['url'];
    json['md5'] = file?['md5'];
    json['file_size'] = file?['size'];
    json['file_ext'] = file?['ext'];

    if (source.isNotEmpty) {
      json['source'] = source.first;
    }

    json['height'] = file?['height'] ?? sample?['height'];
    json['width'] = file?['width'] ?? sample?['width'];
    json['preview_width'] = preview?['width'];
    json['preview_height'] = preview?['width'];
    json['score'] = json['score']?['total'];

    String tagsList = '';
    tags?.values.forEach((value) {
      tagsList += value.join(', ');
    });
    json['tags'] = tagsList;

    return Post.fromJson(json);
  }

}