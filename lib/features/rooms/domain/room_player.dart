class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    required this.score,
    required this.isHost,
    required this.isJudge,
    required this.isReady,
    this.avatarId,
    this.teamId,
    this.joinedAt,
    this.leftAt,
  });

  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final String? avatarId;
  final String? teamId;
  final int score;
  final bool isHost;
  final bool isJudge;
  final bool isReady;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  bool get isActive => leftAt == null;

  factory RoomPlayer.fromMap(Map<String, dynamic> map) {
    return RoomPlayer(
      id: map['id'] as String,
      roomId: map['room_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      displayName: map['display_name'] as String? ?? '',
      avatarId: map['avatar_id'] as String?,
      teamId: map['team_id'] as String?,
      score: map['score'] as int? ?? 0,
      isHost: map['is_host'] as bool? ?? false,
      isJudge: map['is_judge'] as bool? ?? false,
      isReady: map['is_ready'] as bool? ?? false,
      joinedAt: map['joined_at'] == null ? null : DateTime.tryParse(map['joined_at'] as String),
      leftAt: map['left_at'] == null ? null : DateTime.tryParse(map['left_at'] as String),
    );
  }
}
