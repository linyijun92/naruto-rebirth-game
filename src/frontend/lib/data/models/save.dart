import 'package:json_annotation/json_annotation.dart';

part 'save.g.dart';

@JsonSerializable()
class Save {
  final String saveId;
  final String playerId;
  final String saveName;
  final String gameTime;
  final int playerLevel;
  final Map<String, dynamic> attributes;
  final String currentChapter;
  final List<dynamic> inventory;
  final List<dynamic> quests;
  final List<dynamic> achievements;
  final int playTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Save({
    required this.saveId,
    required this.playerId,
    required this.saveName,
    required this.gameTime,
    required this.playerLevel,
    required this.attributes,
    required this.currentChapter,
    required this.inventory,
    required this.quests,
    required this.achievements,
    required this.playTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Save.fromJson(Map<String, dynamic> json) => _$SaveFromJson(json);

  Map<String, dynamic> toJson() => _$SaveToJson(this);

  Save copyWith({
    String? saveId,
    String? playerId,
    String? saveName,
    String? gameTime,
    int? playerLevel,
    Map<String, dynamic>? attributes,
    String? currentChapter,
    List<dynamic>? inventory,
    List<dynamic>? quests,
    List<dynamic>? achievements,
    int? playTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Save(
      saveId: saveId ?? this.saveId,
      playerId: playerId ?? this.playerId,
      saveName: saveName ?? this.saveName,
      gameTime: gameTime ?? this.gameTime,
      playerLevel: playerLevel ?? this.playerLevel,
      attributes: attributes ?? this.attributes,
      currentChapter: currentChapter ?? this.currentChapter,
      inventory: inventory ?? this.inventory,
      quests: quests ?? this.quests,
      achievements: achievements ?? this.achievements,
      playTime: playTime ?? this.playTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
