import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wallet_entity.dart';
import 'dart:math';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Root `wallets` collection
  CollectionReference get _wallets => _firestore.collection('wallets');

  // Generate a random 6-character alphanumeric invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      6,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  // Ensure a unique code
  Future<String> _getUniqueInviteCode() async {
    while (true) {
      final code = _generateInviteCode();
      final duplicateQuery = await _wallets.where('inviteCode', isEqualTo: code).get();
      if (duplicateQuery.docs.isEmpty) {
        return code;
      }
    }
  }

  /// Create a new shared wallet
  Future<String> createWallet({
    required String name,
    required String creatorUid,
  }) async {
    final inviteCode = await _getUniqueInviteCode();
    final docRef = _wallets.doc();
    
    final wallet = WalletEntity(
      id: docRef.id,
      name: name,
      createdBy: creatorUid,
      members: [creatorUid],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
      isPersonal: false,
    );

    await docRef.set(wallet.toMap());
    return docRef.id;
  }

  /// Join an existing shared wallet using an invite code
  Future<WalletEntity?> joinWallet({
    required String inviteCode,
    required String userId,
  }) async {
    final codeString = inviteCode.trim().toUpperCase();
    final query = await _wallets.where('inviteCode', isEqualTo: codeString).limit(1).get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid or expired invite code.');
    }

    final docSnap = query.docs.first;
    final wallet = WalletEntity.fromMap(docSnap.data() as Map<String, dynamic>, docSnap.id);

    // Check if already a member
    if (wallet.members.contains(userId)) {
      throw Exception('You are already a member of this wallet.');
    }

    // Add member
    await _wallets.doc(wallet.id).update({
      'members': FieldValue.arrayUnion([userId])
    });

    // Return the updated wallet
    final updatedMembers = List<String>.from(wallet.members)..add(userId);
    return WalletEntity(
      id: wallet.id,
      name: wallet.name,
      createdBy: wallet.createdBy,
      members: updatedMembers,
      inviteCode: wallet.inviteCode,
      createdAt: wallet.createdAt,
      isPersonal: wallet.isPersonal,
    );
  }

  /// Stream wallets where the user is a member
  Stream<List<WalletEntity>> getUserWalletsStream(String userId) {
    return _wallets
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WalletEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream single wallet updates
  Stream<WalletEntity> getWalletStream(String walletId) {
    return _wallets.doc(walletId).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Wallet deleted");
      return WalletEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}
