import 'package:json_annotation/json_annotation.dart';

part 'story.g.dart';

@JsonSerializable()
class StoryNode {
  final String nodeId;
  final String chapterId;
  final String type;
  final String content;
  final String? speaker;
  final List<StoryChoice>? choices;
  final String? backgroundMusic;
  final String? soundEffect;

  StoryNode({
    required this.nodeId,
    required this.chapterId,
    required this.type,
    required this.content,
    this.speaker,
    this.choices,
    this.backgroundMusic,
    this.soundEffect,
  });

  factory StoryNode.fromJson(Map<String, dynamic> json) =>
      _$StoryNodeFromJson(json);

  Map<String, dynamic> toJson() => _$StoryNodeToJson(this);
}

@JsonSerializable()
class StoryChoice {
  final String id;
  final String text;
  final String nextNode;
  final Map<String, dynamic>? requirements;

  StoryChoice({
    required this.id,
    required this.text,
    required this.nextNode,
    this.requirements,
  });

  factory StoryChoice.fromJson(Map<String, dynamic> json) =>
      _$StoryChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$StoryChoiceToJson(this);
}

@JsonSerializable()
class Chapter {
  final String chapterId;
  final String title;
  final String description;
  final String startNodeId;
  final List<String> requiredChapters;
  final bool isUnlocked;

  Chapter({
    required this.chapterId,
    required this.title,
    required this.description,
    required this.startNodeId,
    required this.requiredChapters,
    this.isUnlocked = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterToJson(this);
}
