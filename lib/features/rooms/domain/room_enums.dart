enum RoomGameMode {
  individual,
  teams;

  static RoomGameMode fromValue(String value) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => RoomGameMode.individual,
    );
  }
}

enum RoomJudgeMode {
  none,
  host,
  dedicated;

  static RoomJudgeMode fromValue(String value) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => RoomJudgeMode.none,
    );
  }
}

enum RoomStatus {
  waiting,
  starting,
  playing,
  finished;

  static RoomStatus fromValue(String value) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => RoomStatus.waiting,
    );
  }
}
