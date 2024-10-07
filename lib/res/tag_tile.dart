import 'package:flutter/material.dart';
import 'package:moeboo/provider/import.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../oki/import.dart';

class TagTile extends StatelessWidget {
  final Tag tag;
  /// Usado em pesquisa
  final String query;
  final Color? textColor;
  final bool showProvider;
  final Function(Tag)? onTap;
  final Function(Tag)? onLongPress;
  final Function(Tag)? onAddClick;
  final Function(Tag)? onRemoveClick;
  const TagTile({
    required this.tag,
    this.textColor,
    this.showProvider = false,
    this.query = '',
    this.onTap,
    this.onLongPress,
    this.onAddClick,
    this.onRemoveClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
      color: textColor ?? Colors.black,
    );

    final spans = <TextSpan>[];
    final tagParts = tag.name.split(query);
    for (var part in tagParts) {
      spans.add(TextSpan(text: part, style: style,));
      spans.add(TextSpan(text: query, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)));
    }

    if (spans.isNotEmpty) {
      spans.removeLast();
    }

    return ListTile(
      title: RichText(
        text: TextSpan(
          children: spans,
          style: style,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OkiShadowText(tag.type.name,
            style: TextStyle(color: getColor(tag.type)),
          ),
          if (showProvider && tag.provider.isNotEmpty)
            Text(tag.provider),
        ],
      ),
      onTap: () => onTap?.call(tag),
      onLongPress: () => onLongPress?.call(tag),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.count.toString()),

          if (onAddClick != null)
            IconButton(
              tooltip: idiomaWatch(context).incluir,
              color: textColor,
              icon: const Icon(Icons.add),
              onPressed: () => onAddClick?.call(tag),
            ),
          if (onRemoveClick != null)
            IconButton(
              tooltip: idiomaWatch(context).bloquear,
              color: textColor,
              icon: const Icon(Icons.remove),
              onPressed: () => onRemoveClick?.call(tag),
            ),
        ],
      ),
    );
  }

  Color? getColor(TagType? type) {
    switch(type?.value) {
      case TagType.triviaValue:
        return textColor;
      case TagType.artistValue:
        return Colors.yellow;
      case TagType.copyrightValue:
        return Colors.purple;
      case TagType.characterValue:
        return Colors.green;
      case TagType.metadataValue:
        return Colors.blueAccent;
      default:
        return textColor;
    }
  }
}