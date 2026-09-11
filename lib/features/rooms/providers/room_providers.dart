import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/room_repository.dart';
import '../models/room_membership_result.dart';
import '../models/room_settings.dart';
import '../models/room_view_state.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository();
});

class RoomController extends StateNotifier<RoomViewState> {
  RoomController(this.ref, this._repository) : super(const RoomViewState());

  final Ref ref;
  final RoomRepository _repository;
  StreamSubscription? _roomSubscription;
  StreamSubscription? _playersSubscription;
  RealtimeChannel? _presenceChannel;

  Future<RoomMembershipResult?> createRoom() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.createRoom();
      await _bindRoom(result);
      state = state.copyWith(isLoading: false, room: result.room, membership: result.membership);
      return result;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return null;
    }
  }

  Future<RoomMembershipResult?> joinRoom(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.joinRoom(code);
      await _bindRoom(result);
      state = state.copyWith(isLoading: false, room: result.room, membership: result.membership);
      return result;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return null;
    }
  }

  Future<void> loadRoom(String roomId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final room = await _repository.getRoom(roomId);
      final players = await _repository.getPlayers(roomId);
      final authState = ref.read(authControllerProvider);
      final membership = players.where((player) => player.userId == authState.user?.id).firstOrNull;
      state = state.copyWith(
        isLoading: false,
        room: room,
        players: players,
        membership: membership,
      );
      await _attachStreams(roomId);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> updateSettings(RoomSettings settings) async {
    final room = state.room;
    if (room == null) return;

    state = state.copyWith(isUpdatingSettings: true, clearError: true);
    try {
      final updatedRoom = await _repository.updateRoomSettings(room.id, settings);
      state = state.copyWith(room: updatedRoom, isUpdatingSettings: false);
    } catch (error) {
      state = state.copyWith(isUpdatingSettings: false, errorMessage: error.toString());
    }
  }

  Future<void> leaveRoom() async {
    final room = state.room;
    if (room == null) return;
    await _repository.leaveRoom(room.id);
    await disposeRoomResources();
    state = const RoomViewState();
  }

  Future<void> _bindRoom(RoomMembershipResult result) async {
    state = state.copyWith(room: result.room, membership: result.membership);
    await _attachStreams(result.room.id);
  }

  Future<void> _attachStreams(String roomId) async {
    await _roomSubscription?.cancel();
    await _playersSubscription?.cancel();

    _roomSubscription = _repository.watchRoom(roomId).listen((room) {
      state = state.copyWith(room: room);
    });

    _playersSubscription = _repository.watchPlayers(roomId).listen((players) {
      final membership = state.membership == null
          ? null
          : players.where((player) => player.id == state.membership!.id).firstOrNull;
      state = state.copyWith(players: players, membership: membership ?? state.membership);
    });

    await _attachPresence(roomId);
  }

  Future<void> _attachPresence(String roomId) async {
    await _presenceChannel?.unsubscribe();

    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    final profile = authState.profile;
    if (user == null || profile == null) return;

    final channel = _repository.createPresenceChannel(
      roomId: roomId,
      userId: user.id,
      displayName: profile.displayName,
    );

    channel.onPresenceSync((_) {
      final presenceState = channel.presenceState();
      final onlineIds = <String>{};
      for (final entry in presenceState.entries) {
        for (final meta in entry.value) {
          final userId = meta.payload['user_id'] as String?;
          if (userId != null) {
            onlineIds.add(userId);
          }
        }
      }
      state = state.copyWith(onlineUserIds: onlineIds, isReconnecting: false);
    });

    _presenceChannel = channel;
  }

  Future<void> disposeRoomResources() async {
    await _roomSubscription?.cancel();
    await _playersSubscription?.cancel();
    await _presenceChannel?.unsubscribe();
    _roomSubscription = null;
    _playersSubscription = null;
    _presenceChannel = null;
  }

  @override
  void dispose() {
    disposeRoomResources();
    super.dispose();
  }
}

final roomControllerProvider = StateNotifierProvider<RoomController, RoomViewState>((ref) {
  return RoomController(ref, ref.watch(roomRepositoryProvider));
});
