class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.displayName,
    this.avatarId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? avatarId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PlayerProfile.fromMap(Map<String, dynamic> map) {
    return PlayerProfile(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? '',
      avatarId: map['avatar_id'] as String?,
      createdAt: map['created_at'] == null ? null : DateTime.tryParse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null ? null : DateTime.tryParse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'display_name': displayName,
      'avatar_id': avatarId,
    };
  }
}
