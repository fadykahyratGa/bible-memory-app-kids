enum RoomMode { individual, teams }

enum RoomStatus {
  lobby,
  teamSelection,
  wheel,
  playing,
  roundResult,
  finished,
  closed,
}

enum DifficultyLevel { easy, medium, hard, mixed }

enum TestamentScope { old, newTestament, both }

RoomMode roomModeFromString(String value) {
  switch (value) {
    case 'teams':
      return RoomMode.teams;
    case 'individual':
    default:
      return RoomMode.individual;
  }
}

RoomStatus roomStatusFromString(String value) {
  switch (value) {
    case 'team_selection':
      return RoomStatus.teamSelection;
    case 'wheel':
      return RoomStatus.wheel;
    case 'playing':
      return RoomStatus.playing;
    case 'round_result':
      return RoomStatus.roundResult;
    case 'finished':
      return RoomStatus.finished;
    case 'closed':
      return RoomStatus.closed;
    case 'lobby':
    default:
      return RoomStatus.lobby;
  }
}

DifficultyLevel difficultyLevelFromString(String value) {
  switch (value) {
    case 'easy':
      return DifficultyLevel.easy;
    case 'medium':
      return DifficultyLevel.medium;
    case 'hard':
      return DifficultyLevel.hard;
    case 'mixed':
    default:
      return DifficultyLevel.mixed;
  }
}

TestamentScope testamentScopeFromString(String value) {
  switch (value) {
    case 'old':
      return TestamentScope.old;
    case 'new':
      return TestamentScope.newTestament;
    case 'both':
    default:
      return TestamentScope.both;
  }
}

String roomModeToValue(RoomMode mode) {
  switch (mode) {
    case RoomMode.teams:
      return 'teams';
    case RoomMode.individual:
      return 'individual';
  }
}

String difficultyLevelToValue(DifficultyLevel level) {
  switch (level) {
    case DifficultyLevel.easy:
      return 'easy';
    case DifficultyLevel.medium:
      return 'medium';
    case DifficultyLevel.hard:
      return 'hard';
    case DifficultyLevel.mixed:
      return 'mixed';
  }
}

String testamentScopeToValue(TestamentScope scope) {
  switch (scope) {
    case TestamentScope.old:
      return 'old';
    case TestamentScope.newTestament:
      return 'new';
    case TestamentScope.both:
      return 'both';
  }
}
