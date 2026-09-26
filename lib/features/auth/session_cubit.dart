import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/madad_brand.dart';
import '../../core/storage/local_store.dart';
import '../../data/models/account_role.dart';
import '../../data/models/business_profile.dart';
import '../../data/remote/madad_store.dart';
import '../../data/repositories/commerce_repository.dart';

export '../../data/models/account_role.dart';

enum AuthStatus { idle, loading, success, failure, confirmEmail }

class SessionState {
  const SessionState({
    this.onboardingDone = false,
    this.isLoggedIn = false,
    this.role = AccountRole.shop,
    this.supplierId,
    this.profile,
    this.status = AuthStatus.idle,
    this.message,
  });

  final bool onboardingDone;
  final bool isLoggedIn;
  final AccountRole role;
  final String? supplierId;
  final BusinessProfile? profile;
  final AuthStatus status;
  final String? message;
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({LocalStore? store, CommerceRepository? commerce})
    : _store = store,
      _commerce = commerce != null && commerce.usesRemoteAuth ? commerce : null,
      super(const SessionState()) {
    if (_commerce != null) {
      if (store?.onboardingDone ?? false) {
        emit(const SessionState(onboardingDone: true));
      }
      _subscription = _commerce.watchAuth().listen(_onAuth);
      return;
    }
    final saved = store?.readSession();
    if (saved == null) {
      if (store?.onboardingDone ?? false) {
        emit(const SessionState(onboardingDone: true));
      }
      return;
    }
    final roleName = saved['role'] as String? ?? AccountRole.shop.name;
    final role = AccountRole.values.asNameMap()[roleName] ?? AccountRole.shop;
    final profileJson = saved['profile'];
    emit(
      SessionState(
        onboardingDone:
            saved['onboardingDone'] as bool? ?? store!.onboardingDone,
        isLoggedIn: saved['isLoggedIn'] as bool? ?? false,
        role: role,
        supplierId: saved['supplierId'] as String?,
        profile: profileJson is Map
            ? BusinessProfile.fromJson(Map<String, dynamic>.from(profileJson))
            : null,
      ),
    );
  }

  final LocalStore? _store;
  final CommerceRepository? _commerce;
  StreamSubscription<SignedAccount?>? _subscription;

  bool get onboardingDone => state.onboardingDone;
  bool get isLoggedIn => state.isLoggedIn;
  AccountRole get role => state.role;
  String? get supplierId => state.supplierId;
  BusinessProfile? get profile => state.profile;
  bool get isSupplier => state.role == AccountRole.supplier;
  bool get usesRemoteAuth => _commerce != null;

  void completeOnboarding() {
    emit(
      SessionState(
        onboardingDone: true,
        isLoggedIn: state.isLoggedIn,
        role: state.role,
        supplierId: state.supplierId,
        profile: state.profile,
        status: state.status,
        message: state.message,
      ),
    );
    _store?.setOnboardingDone();
    if (_commerce == null) _persist();
  }

  Future<void> login(
    String phone, {
    AccountRole role = AccountRole.shop,
  }) async {
    if (_commerce != null) {
      emit(
        SessionState(
          onboardingDone: state.onboardingDone,
          status: AuthStatus.failure,
          message: 'استخدم البريد وكلمة المرور. رقم الجوال ليس بريدًا.',
        ),
      );
      return;
    }
    final SessionState next;
    if (role == AccountRole.supplier) {
      next = SessionState(
        onboardingDone: true,
        isLoggedIn: true,
        role: AccountRole.supplier,
        supplierId: MadadBrand.demoSupplierId,
        status: AuthStatus.success,
        profile: BusinessProfile(
          businessName: 'واحة الغذاء للجملة',
          ownerName: 'مسؤول التوريد',
          phone: phone,
          city: 'الرياض',
          addresses: const ['المستودع، حي السلي، الرياض'],
        ),
      );
    } else {
      next = SessionState(
        onboardingDone: true,
        isLoggedIn: true,
        status: AuthStatus.success,
        profile: BusinessProfile(
          businessName: 'بقالة النور',
          ownerName: 'خالد العمري',
          phone: phone,
          city: 'الرياض',
          addresses: const ['حي النسيم، شارع الأمير بندر، الرياض'],
        ),
      );
    }
    emit(next);
    _store?.setOnboardingDone();
    _persist();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final commerce = _commerce;
    if (commerce == null) return false;
    _emitStatus(AuthStatus.loading);
    try {
      final account = await commerce.signIn(email: email, password: password);
      _show(account, AuthStatus.success);
      return true;
    } on MadadAuthException catch (error) {
      _fail(error.message);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required AccountRole role,
    required String businessName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
  }) async {
    final commerce = _commerce;
    if (commerce == null) return false;
    _emitStatus(AuthStatus.loading);
    try {
      final account = await commerce.register(
        email: email,
        password: password,
        role: role,
        businessName: businessName,
        ownerName: ownerName,
        phone: phone,
        city: city,
        address: address,
      );
      _show(account, AuthStatus.success);
      return true;
    } on MadadAuthException catch (error) {
      if (error.emailConfirmation) {
        emit(
          SessionState(
            onboardingDone: state.onboardingDone,
            status: AuthStatus.confirmEmail,
            message: error.message,
          ),
        );
        return false;
      }
      _fail(error.message);
      return false;
    }
  }

  Future<bool> restore() async {
    final commerce = _commerce;
    if (commerce == null) return state.isLoggedIn;
    try {
      final account = await commerce.restoreAccount();
      if (account == null) {
        emit(SessionState(onboardingDone: state.onboardingDone));
        return false;
      }
      _show(account, AuthStatus.success);
      return true;
    } on MadadAuthException catch (error) {
      _fail(error.message);
      return false;
    }
  }

  Future<void> logout() async {
    await _commerce?.signOut();
    emit(SessionState(onboardingDone: state.onboardingDone));
    await _store?.clearSession();
    if (state.onboardingDone) {
      await _store?.setOnboardingDone();
    }
  }

  void _onAuth(SignedAccount? account) {
    if (isClosed || state.status == AuthStatus.loading) return;
    if (account == null) {
      if (!state.isLoggedIn) return;
      emit(SessionState(onboardingDone: state.onboardingDone));
      return;
    }
    _show(account, AuthStatus.success);
  }

  void _show(SignedAccount account, AuthStatus status) {
    emit(
      SessionState(
        onboardingDone: true,
        isLoggedIn: true,
        role: account.role,
        supplierId: account.supplierId,
        profile: account.profile,
        status: status,
      ),
    );
    _store?.setOnboardingDone();
  }

  void _fail(String message) {
    emit(
      SessionState(
        onboardingDone: state.onboardingDone,
        status: AuthStatus.failure,
        message: message,
      ),
    );
  }

  void _emitStatus(AuthStatus status) {
    emit(
      SessionState(
        onboardingDone: state.onboardingDone,
        isLoggedIn: false,
        status: status,
      ),
    );
  }

  void _persist() {
    final profile = state.profile;
    _store?.saveSession({
      'onboardingDone': state.onboardingDone,
      'isLoggedIn': state.isLoggedIn,
      'role': state.role.name,
      'supplierId': state.supplierId,
      'profile': profile?.toJson(),
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
