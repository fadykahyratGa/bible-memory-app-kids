class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    required this.isHost,
    this.teamId,
    this.playerOrder,
    required this.joinedAt,
    this.leftAt,
  });

  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final String? teamId;
  final bool isHost;
  final int? playerOrder;
  final DateTime joinedAt;
  final DateTime? leftAt;

  bool get isActive => leftAt == null;

  factory RoomPlayer.fromJson(Map<String, dynamic> json) {
    return RoomPlayer(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String? ?? '',
      teamId: json['team_id'] as String?,
      isHost: json['is_host'] as bool? ?? false,
      playerOrder: (json['player_order'] as num?)?.toInt(),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] == null ? null : DateTime.parse(json['left_at'] as String),
    );
  }
}
