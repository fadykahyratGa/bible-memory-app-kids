import 'package:flutter_test/flutter_test.dart';

import 'package:bible_memory_app_kids/features/rooms/domain/room_player.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_team.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/team_balancer.dart';

void main() {
  group('TeamBalancer', () {
    test('assigns unassigned players to the least loaded teams', () {
      final teams = _teams(2);
      final players = [
        _player('u1', DateTime(2024, 1, 1), teamId: 'team-1'),
        _player('u2', DateTime(2024, 1, 2)),
        _player('u3', DateTime(2024, 1, 3)),
      ];

      final assignments = TeamBalancer.assign(players: players, teams: teams);

      expect(assignments, hasLength(2));
      expect(assignments.first.teamId, 'team-2');
      expect(assignments.last.teamId, 'team-1');
    });

    test('keeps 2 players / 2 teams balanced', () {
      expect(_maxTeamSizeDifference(players: [_player('u1', DateTime(2024, 1, 1)), _player('u2', DateTime(2024, 1, 2))], teams: _teams(2)), lessThanOrEqualTo(1));
    });

    test('keeps 3 players / 2 teams balanced', () {
      expect(_maxTeamSizeDifference(players: [_player('u1', DateTime(2024, 1, 1)), _player('u2', DateTime(2024, 1, 2)), _player('u3', DateTime(2024, 1, 3))], teams: _teams(2)), lessThanOrEqualTo(1));
    });

    test('keeps 5 players / 2 teams balanced', () {
      expect(_maxTeamSizeDifference(players: [for (var i = 0; i < 5; i++) _player('u$i', DateTime(2024, 1, i + 1))], teams: _teams(2)), lessThanOrEqualTo(1));
    });

    test('keeps 7 players / 3 teams balanced', () {
      expect(_maxTeamSizeDifference(players: [for (var i = 0; i < 7; i++) _player('u$i', DateTime(2024, 1, i + 1))], teams: _teams(3)), lessThanOrEqualTo(1));
    });
  });
}

List<RoomTeam> _teams(int count) {
  return [for (var i = 1; i <= count; i++) RoomTeam(id: 'team-$i', roomId: 'room-1', teamNumber: i, name: 'Team $i', score: 0)];
}

RoomPlayer _player(String userId, DateTime joinedAt, {String? teamId}) {
  return RoomPlayer(
    id: userId,
    roomId: 'room-1',
    userId: userId,
    displayName: userId,
    score: 0,
    isHost: false,
    isJudge: false,
    isReady: false,
    joinedAt: joinedAt,
    teamId: teamId,
  );
}

int _maxTeamSizeDifference({required List<RoomPlayer> players, required List<RoomTeam> teams}) {
  final assignments = TeamBalancer.assign(players: players, teams: teams);
  final counts = <String, int>{for (final team in teams) team.id: players.where((player) => player.teamId == team.id).length};
  for (final assignment in assignments) {
    counts[assignment.teamId] = (counts[assignment.teamId] ?? 0) + 1;
  }
  final values = counts.values.toList()..sort();
  return values.last - values.first;
}
