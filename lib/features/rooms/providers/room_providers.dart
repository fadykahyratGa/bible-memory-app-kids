import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_player.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_team.dart';

final roomProvider = StreamProvider.family<Room, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).observeRoom(roomId);
});

final roomPlayersProvider = StreamProvider.family<List<RoomPlayer>, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).observePlayers(roomId);
});

final roomTeamsProvider = StreamProvider.family<List<RoomTeam>, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).observeTeams(roomId);
});
