import 'room.dart';
import 'room_player.dart';

class RoomMembershipResult {
  const RoomMembershipResult({
    required this.room,
    required this.membership,
  });

  final Room room;
  final RoomPlayer membership;

  factory RoomMembershipResult.fromJson(Map<String, dynamic> json) {
    return RoomMembershipResult(
      room: Room.fromJson(Map<String, dynamic>.from(json['room'] as Map)),
      membership: RoomPlayer.fromJson(Map<String, dynamic>.from(json['membership'] as Map)),
    );
  }
}
