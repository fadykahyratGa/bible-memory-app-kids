import 'room_enums.dart';

class RoomSettings {
  const RoomSettings({
    required this.mode,
    required this.timerSeconds,
    required this.skipPenaltySeconds,
    required this.roundsToWin,
    required this.difficulty,
    required this.testament,
    required this.showQuestionToOpponents,
    required this.maxPlayers,
  });

  final RoomMode mode;
  final int timerSeconds;
  final int skipPenaltySeconds;
  final int roundsToWin;
  final DifficultyLevel difficulty;
  final TestamentScope testament;
  final bool showQuestionToOpponents;
  final int maxPlayers;

  factory RoomSettings.fromJson(Map<String, dynamic> json) {
    return RoomSettings(
      mode: roomModeFromString(json['mode'] as String? ?? 'individual'),
      timerSeconds: (json['timer_seconds'] as num?)?.toInt() ?? 45,
      skipPenaltySeconds: (json['skip_penalty_seconds'] as num?)?.toInt() ?? 3,
      roundsToWin: (json['rounds_to_win'] as num?)?.toInt() ?? 3,
      difficulty: difficultyLevelFromString(json['difficulty'] as String? ?? 'mixed'),
      testament: testamentScopeFromString(json['testament'] as String? ?? 'both'),
      showQuestionToOpponents: json['show_question_to_opponents'] as bool? ?? true,
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toRpcParams(String roomId) {
    return {
      'p_room_id': roomId,
      'p_mode': roomModeToValue(mode),
      'p_timer_seconds': timerSeconds,
      'p_skip_penalty_seconds': skipPenaltySeconds,
      'p_rounds_to_win': roundsToWin,
      'p_difficulty': difficultyLevelToValue(difficulty),
      'p_testament': testamentScopeToValue(testament),
      'p_show_question_to_opponents': showQuestionToOpponents,
    };
  }

  RoomSettings copyWith({
    RoomMode? mode,
    int? timerSeconds,
    int? skipPenaltySeconds,
    int? roundsToWin,
    DifficultyLevel? difficulty,
    TestamentScope? testament,
    bool? showQuestionToOpponents,
    int? maxPlayers,
  }) {
    return RoomSettings(
      mode: mode ?? this.mode,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      skipPenaltySeconds: skipPenaltySeconds ?? this.skipPenaltySeconds,
      roundsToWin: roundsToWin ?? this.roundsToWin,
      difficulty: difficulty ?? this.difficulty,
      testament: testament ?? this.testament,
      showQuestionToOpponents: showQuestionToOpponents ?? this.showQuestionToOpponents,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }
}
