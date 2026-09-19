import 'package:bible_memory_app_kids/features/rooms/domain/room_player.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_team.dart';

class BalancedTeamAssignment {
  const BalancedTeamAssignment({required this.teamId, required this.userId});

  final String teamId;
  final String userId;
}

class TeamBalancer {
  TeamBalancer._();

  static List<BalancedTeamAssignment> assign({required List<RoomPlayer> players, required List<RoomTeam> teams}) {
    if (teams.isEmpty) {
      return const <BalancedTeamAssignment>[];
    }

    final sortedTeams = List<RoomTeam>.from(teams)..sort((a, b) => a.teamNumber.compareTo(b.teamNumber));
    final activePlayers = players.where((player) => player.isActive).toList()..sort((a, b) => a.joinedAt?.compareTo(b.joinedAt ?? DateTime(1970)) ?? 0);
    final teamLoads = <String, int>{
      for (final team in sortedTeams)
        team.id: activePlayers.where((player) => player.teamId == team.id).length,
    };

    final assignments = <BalancedTeamAssignment>[];
    for (final player in activePlayers.where((player) => player.teamId == null)) {
      final team = sortedTeams.reduce((best, current) {
        final bestLoad = teamLoads[best.id] ?? 0;
        final currentLoad = teamLoads[current.id] ?? 0;
        if (currentLoad != bestLoad) {
          return currentLoad < bestLoad ? current : best;
        }
        return current.teamNumber < best.teamNumber ? current : best;
      });
      assignments.add(BalancedTeamAssignment(teamId: team.id, userId: player.userId));
      teamLoads[team.id] = (teamLoads[team.id] ?? 0) + 1;
    }

    return assignments;
  }
}
