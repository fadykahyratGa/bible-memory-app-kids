import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_client_provider.dart';
import '../models/room.dart';
import '../models/room_membership_result.dart';
import '../models/room_player.dart';
import '../models/room_settings.dart';
import 'room_error_mapper.dart';

class RoomRepository {
  final SupabaseClient _client = SupabaseClientProvider.client;

  Future<RoomMembershipResult> createRoom() async {
    try {
      final response = await _client.rpc('create_room');
      return RoomMembershipResult.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (error) {
      throw mapRoomError(error);
    }
  }

  Future<RoomMembershipResult> joinRoom(String code) async {
    try {
      final response = await _client.rpc('join_room', params: {'p_code': code});
      return RoomMembershipResult.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (error) {
      throw mapRoomError(error);
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await _client.rpc('leave_room', params: {'p_room_id': roomId});
    } catch (error) {
      throw mapRoomError(error);
    }
  }

  Future<Room> updateRoomSettings(String roomId, RoomSettings settings) async {
    try {
      final response = await _client.rpc('update_room_settings', params: settings.toRpcParams(roomId));
      return Room.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (error) {
      throw mapRoomError(error);
    }
  }

  Future<Room> getRoom(String roomId) async {
    final response = await _client.from('rooms').select().eq('id', roomId).single();
    return Room.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<RoomPlayer>> getPlayers(String roomId) async {
    final response = await _client
        .from('room_players')
        .select()
        .eq('room_id', roomId)
        .order('player_order');
    return (response as List)
        .map((item) => RoomPlayer.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Stream<Room> watchRoom(String roomId) {
    return _client
        .from('rooms')
        .stream(primaryKey: ['id'])
        .eq('id', roomId)
        .map((rows) => Room.fromJson(Map<String, dynamic>.from(rows.first)));
  }

  Stream<List<RoomPlayer>> watchPlayers(String roomId) {
    return _client
        .from('room_players')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('player_order')
        .map(
          (rows) => rows
              .map((item) => RoomPlayer.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
        );
  }

  RealtimeChannel createPresenceChannel({
    required String roomId,
    required String userId,
    required String displayName,
  }) {
    final channel = _client.channel('presence:room:$roomId');
    channel
      ..onPresenceSync((_) {})
      ..subscribe((status, [error]) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await channel.track({
            'user_id': userId,
            'room_id': roomId,
            'display_name': displayName,
            'online_at': DateTime.now().toIso8601String(),
          });
        }
      });
    return channel;
  }
}
