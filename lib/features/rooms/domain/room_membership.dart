import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_enums.dart';

class RoomMembership {
  const RoomMembership({
    required this.roomId,
    required this.roomStatus,
    this.gameState,
  });

  final String roomId;
  final RoomStatus roomStatus;
  final MultiplayerGameState? gameState;

  String get restoreLocation {
    if (roomStatus == RoomStatus.finished) {
      return '/room/$roomId/results';
    }

    if (gameState == null) {
      return '/room/$roomId/lobby';
    }

    if (gameState == MultiplayerGameState.gameResults || gameState == MultiplayerGameState.finished) {
      return '/room/$roomId/results';
    }

    return '/room/$roomId/game';
  }
}
