import '../models/room.dart';
import '../models/room_player.dart';

class RoomViewState {
  const RoomViewState({
    this.room,
    this.membership,
    this.players = const <RoomPlayer>[],
    this.onlineUserIds = const <String>{},
    this.isLoading = false,
    this.isUpdatingSettings = false,
    this.isReconnecting = false,
    this.errorMessage,
  });

  final Room? room;
  final RoomPlayer? membership;
  final List<RoomPlayer> players;
  final Set<String> onlineUserIds;
  final bool isLoading;
  final bool isUpdatingSettings;
  final bool isReconnecting;
  final String? errorMessage;

  bool get isHost => membership?.isHost ?? false;

  RoomViewState copyWith({
    Room? room,
    RoomPlayer? membership,
    List<RoomPlayer>? players,
    Set<String>? onlineUserIds,
    bool? isLoading,
    bool? isUpdatingSettings,
    bool? isReconnecting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoomViewState(
      room: room ?? this.room,
      membership: membership ?? this.membership,
      players: players ?? this.players,
      onlineUserIds: onlineUserIds ?? this.onlineUserIds,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingSettings: isUpdatingSettings ?? this.isUpdatingSettings,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
