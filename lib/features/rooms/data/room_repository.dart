import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bible_memory_app_kids/core/errors/app_exception.dart';
import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';

import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_code.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_enums.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_membership.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_player.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_team.dart';

class CreateRoomRequest {
  const CreateRoomRequest({
    required this.gameMode,
    required this.judgeMode,
    this.teamCount,
    this.isPrivate = true,
  });

  final RoomGameMode gameMode;
  final RoomJudgeMode judgeMode;
  final int? teamCount;
  final bool isPrivate;
}

class CreatedRoom {
  const CreatedRoom({required this.roomId, required this.roomCode});

  final String roomId;
  final String roomCode;
}

class RoomRepository {
  RoomRepository(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _clientOrThrow => _client ?? (throw const AppException(code: 'missing_config', userMessage: AppErrorMapper.missingConfigMessage));

  Future<CreatedRoom> createRoom(CreateRoomRequest request) async {
    final result = await _clientOrThrow.rpc(
      'create_room',
      params: <String, dynamic>{
        'p_game_mode': request.gameMode.name,
        'p_judge_mode': request.judgeMode.name,
        'p_team_count': request.teamCount,
        'p_is_private': request.isPrivate,
      },
    );
    final data = Map<String, dynamic>.from((result as List<dynamic>).first as Map);
    return CreatedRoom(roomId: data['room_id'] as String, roomCode: data['room_code'] as String);
  }

  Future<CreatedRoom> joinRoom({required String roomCode, required String nickname}) async {
    final result = await _clientOrThrow.rpc(
      'join_room',
      params: <String, dynamic>{
        'p_room_code': roomCode.trim().toUpperCase(),
        'p_display_name': nickname.trim(),
      },
    );
    final data = Map<String, dynamic>.from((result as List<dynamic>).first as Map);
    return CreatedRoom(roomId: data['room_id'] as String, roomCode: data['room_code'] as String? ?? roomCode.trim().toUpperCase());
  }

  Future<void> leaveRoom(String roomId) async {
    await _clientOrThrow.rpc('leave_room', params: <String, dynamic>{'p_room_id': roomId});
  }

  Future<RoomMembership?> findActiveMembership() async {
    final currentUserId = _clientOrThrow.auth.currentUser?.id;
    if (currentUserId == null) {
      return null;
    }
    final membershipRows = await _clientOrThrow
        .from('room_players')
        .select('room_id, joined_at')
        .eq('user_id', currentUserId)
        .isFilter('left_at', null)
        .order('joined_at', ascending: false)
        .limit(1);
    final memberships = (membershipRows as List<dynamic>).cast<Map<String, dynamic>>();
    final membership = memberships.isEmpty ? <String, dynamic>{} : memberships.first;
    if (membership.isEmpty) {
      return null;
    }

    final roomId = membership['room_id'] as String;
    final room = await fetchRoom(roomId);
    final gameRows = await _clientOrThrow
        .from('games')
        .select()
        .eq('room_id', roomId)
        .order('started_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .limit(1);
    GameSession? game;
    if (gameRows is List && gameRows.isNotEmpty) {
      game = GameSession.fromMap(Map<String, dynamic>.from(gameRows.first as Map));
    }

    return RoomMembership(roomId: roomId, roomStatus: room.status, gameState: game?.state);
  }

  Future<Room> fetchRoom(String roomId) async {
    final result = await _clientOrThrow.from('rooms').select().eq('id', roomId).single();
    return Room.fromMap(result);
  }

  Stream<Room> observeRoom(String roomId) {
    return _clientOrThrow.from('rooms').stream(primaryKey: <String>['id']).eq('id', roomId).map((rows) {
      final row = rows.cast<Map<String, dynamic>?>().whereType<Map<String, dynamic>>().firstWhere(
            (item) => item['id'] == roomId,
            orElse: () => throw const AppException(code: 'room_not_found', userMessage: AppErrorMapper.roomNotFoundMessage),
          );
      return Room.fromMap(row);
    });
  }

  Stream<List<RoomPlayer>> observePlayers(String roomId) {
    return _clientOrThrow.from('room_players').stream(primaryKey: <String>['id']).eq('room_id', roomId).map((rows) {
      final players = rows
          .map((row) => RoomPlayer.fromMap(row))
          .where((player) => player.leftAt == null)
          .toList()
        ..sort((a, b) {
          if (a.isHost != b.isHost) {
            return a.isHost ? -1 : 1;
          }
          return a.displayName.compareTo(b.displayName);
        });
      return players;
    });
  }

  Stream<List<RoomTeam>> observeTeams(String roomId) {
    return _clientOrThrow.from('room_teams').stream(primaryKey: <String>['id']).eq('room_id', roomId).map((rows) {
      final teams = rows.map((row) => RoomTeam.fromMap(row)).toList()
        ..sort((a, b) => a.teamNumber.compareTo(b.teamNumber));
      return teams;
    });
  }

  String normalizeRoomCode(String value) {
    final normalized = value.trim().toUpperCase();
    if (!RoomCodeHelper.isValid(normalized)) {
      throw ArgumentError('invalid_room_code');
    }
    return normalized;
  }
}
