import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../domain/entities/wallet_entity.dart';
import '../../core/services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();
  
  List<WalletEntity> _wallets = [];
  WalletEntity? _selectedWallet; // Null means "Personal Wallet"
  bool _isLoading = true;
  StreamSubscription? _walletsSubscription;

  List<WalletEntity> get wallets => _wallets;
  WalletEntity? get selectedWallet => _selectedWallet;
  bool get isPersonalWallet => _selectedWallet == null;
  bool get isLoading => _isLoading;

  WalletProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToWallets(user.uid);
      } else {
        _walletsSubscription?.cancel();
        _wallets = [];
        _selectedWallet = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToWallets(String userId) {
    _isLoading = true;
    notifyListeners();

    _walletsSubscription?.cancel();
    _walletsSubscription = _walletService.getUserWalletsStream(userId).listen((wallets) {
      _wallets = wallets;
      
      // If the selected wallet was removed/deleted, revert to personal
      if (_selectedWallet != null && !_wallets.any((w) => w.id == _selectedWallet!.id)) {
        _selectedWallet = null;
      } else if (_selectedWallet != null) {
        // Update the selected wallet to reflect new members/name changes
        _selectedWallet = _wallets.firstWhere((w) => w.id == _selectedWallet!.id);
      }

      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Wallets Stream Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectWallet(WalletEntity? wallet) {
    _selectedWallet = wallet;
    notifyListeners();
  }

  Future<void> createWallet(String name, {required bool isOffline}) async {
    if (isOffline) {
      throw Exception("Internet required to create a shared wallet.");
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");
    
    await _walletService.createWallet(name: name, creatorUid: user.uid);
  }

  Future<void> joinWallet(String inviteCode, {required bool isOffline}) async {
    if (isOffline) {
      throw Exception("Internet required to join a shared wallet.");
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _walletService.joinWallet(inviteCode: inviteCode, userId: user.uid);
  }

  @override
  void dispose() {
    _walletsSubscription?.cancel();
    super.dispose();
  }
}
