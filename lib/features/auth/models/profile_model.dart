class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.displayName,
    required this.isGuest,
    this.avatarUrl,
    this.gamesPlayed = 0,
    this.wins = 0,
  });

  final String id;
  final String displayName;
  final bool isGuest;
  final String? avatarUrl;
  final int gamesPlayed;
  final int wins;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      isGuest: json['is_guest'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      gamesPlayed: (json['games_played'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
    );
  }
}
