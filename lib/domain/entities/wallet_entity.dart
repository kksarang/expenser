import 'package:cloud_firestore/cloud_firestore.dart';

class WalletEntity {
  final String id;
  final String name;
  final String createdBy; // UID of creator
  final List<String> members; // UIDs of all members
  final String inviteCode; // 6-digit join code
  final DateTime createdAt;
  final bool isPersonal;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.inviteCode,
    required this.createdAt,
    this.isPersonal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'members': members,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPersonal': isPersonal,
    };
  }

  factory WalletEntity.fromMap(Map<String, dynamic> map, String id) {
    return WalletEntity(
      id: id,
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      inviteCode: map['inviteCode'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPersonal: map['isPersonal'] ?? false,
    );
  }
}
