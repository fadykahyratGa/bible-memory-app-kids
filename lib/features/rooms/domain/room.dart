import 'package:bible_memory_app_kids/features/rooms/domain/room_enums.dart';

class Room {
  const Room({
    required this.id,
    required this.code,
    required this.hostUserId,
    required this.gameMode,
    required this.judgeMode,
    required this.status,
    required this.isPrivate,
    this.judgeUserId,
    this.teamCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String code;
  final String hostUserId;
  final String? judgeUserId;
  final RoomGameMode gameMode;
  final RoomJudgeMode judgeMode;
  final RoomStatus status;
  final bool isPrivate;
  final int? teamCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      code: map['code'] as String? ?? '',
      hostUserId: map['host_user_id'] as String? ?? '',
      judgeUserId: map['judge_user_id'] as String?,
      gameMode: RoomGameMode.fromValue(map['game_mode'] as String? ?? 'individual'),
      judgeMode: RoomJudgeMode.fromValue(map['judge_mode'] as String? ?? 'none'),
      status: RoomStatus.fromValue(map['status'] as String? ?? 'waiting'),
      isPrivate: map['is_private'] as bool? ?? true,
      teamCount: map['team_count'] as int?,
      createdAt: map['created_at'] == null ? null : DateTime.tryParse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null ? null : DateTime.tryParse(map['updated_at'] as String),
    );
  }
}
