import 'package:flutter_test/flutter_test.dart';

import 'package:bible_memory_app_kids/features/rooms/domain/room_player.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_team.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/team_balancer.dart';

void main() {
  test('TeamBalancer assigns unassigned players to the least loaded teams', () {
    final teams = [
      const RoomTeam(id: 'team-1', roomId: 'room-1', teamNumber: 1, name: 'A', score: 0),
      const RoomTeam(id: 'team-2', roomId: 'room-1', teamNumber: 2, name: 'B', score: 0),
    ];
    final players = [
      RoomPlayer(id: '1', roomId: 'room-1', userId: 'u1', displayName: 'P1', score: 0, isHost: false, isJudge: false, isReady: false, joinedAt: DateTime(2024, 1, 1), teamId: 'team-1'),
      RoomPlayer(id: '2', roomId: 'room-1', userId: 'u2', displayName: 'P2', score: 0, isHost: false, isJudge: false, isReady: false, joinedAt: DateTime(2024, 1, 2)),
      RoomPlayer(id: '3', roomId: 'room-1', userId: 'u3', displayName: 'P3', score: 0, isHost: false, isJudge: false, isReady: false, joinedAt: DateTime(2024, 1, 3)),
    ];

    final assignments = TeamBalancer.assign(players: players, teams: teams);

    expect(assignments, hasLength(2));
    expect(assignments.first.teamId, 'team-2');
    expect(assignments.last.teamId, 'team-1');
  });
}
