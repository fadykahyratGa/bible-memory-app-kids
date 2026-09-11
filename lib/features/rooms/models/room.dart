import 'room_enums.dart';
import 'room_settings.dart';

class Room {
  const Room({
    required this.id,
    required this.code,
    required this.hostUserId,
    required this.mode,
    required this.status,
    required this.timerSeconds,
    required this.skipPenaltySeconds,
    required this.roundsToWin,
    required this.difficulty,
    required this.testament,
    required this.showQuestionToOpponents,
    required this.maxPlayers,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  final String id;
  final String code;
  final String hostUserId;
  final RoomMode mode;
  final RoomStatus status;
  final int timerSeconds;
  final int skipPenaltySeconds;
  final int roundsToWin;
  final DifficultyLevel difficulty;
  final TestamentScope testament;
  final bool showQuestionToOpponents;
  final int maxPlayers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  RoomSettings get settings => RoomSettings(
        mode: mode,
        timerSeconds: timerSeconds,
        skipPenaltySeconds: skipPenaltySeconds,
        roundsToWin: roundsToWin,
        difficulty: difficulty,
        testament: testament,
        showQuestionToOpponents: showQuestionToOpponents,
        maxPlayers: maxPlayers,
      );

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      hostUserId: json['host_user_id'] as String,
      mode: roomModeFromString(json['mode'] as String? ?? 'individual'),
      status: roomStatusFromString(json['status'] as String? ?? 'lobby'),
      timerSeconds: (json['timer_seconds'] as num?)?.toInt() ?? 45,
      skipPenaltySeconds: (json['skip_penalty_seconds'] as num?)?.toInt() ?? 3,
      roundsToWin: (json['rounds_to_win'] as num?)?.toInt() ?? 3,
      difficulty: difficultyLevelFromString(json['difficulty'] as String? ?? 'mixed'),
      testament: testamentScopeFromString(json['testament'] as String? ?? 'both'),
      showQuestionToOpponents: json['show_question_to_opponents'] as bool? ?? true,
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 20,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      closedAt: json['closed_at'] == null ? null : DateTime.parse(json['closed_at'] as String),
    );
  }
}
