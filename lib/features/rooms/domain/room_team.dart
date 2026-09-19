class RoomTeam {
  const RoomTeam({
    required this.id,
    required this.roomId,
    required this.teamNumber,
    required this.name,
    required this.score,
    this.createdAt,
  });

  final String id;
  final String roomId;
  final int teamNumber;
  final String name;
  final int score;
  final DateTime? createdAt;

  factory RoomTeam.fromMap(Map<String, dynamic> map) {
    return RoomTeam(
      id: map['id'] as String,
      roomId: map['room_id'] as String? ?? '',
      teamNumber: map['team_number'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      createdAt: map['created_at'] == null ? null : DateTime.tryParse(map['created_at'] as String),
    );
  }
}
