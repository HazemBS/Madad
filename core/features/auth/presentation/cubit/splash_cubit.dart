import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SplashDestination { login, customerHome, wholesalerDashboard }

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashSuccess extends SplashState {
  const SplashSuccess(this.destination);

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}

final class SplashFailure extends SplashState {
  const SplashFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required SupabaseClient supabase})
    : _supabase = supabase,
      super(const SplashInitial());

  final SupabaseClient _supabase;

  Future<void> checkSession() async {
    emit(const SplashLoading());

    try {
      // مدة قصيرة لإظهار شعار التطبيق بسلاسة.
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      final session = _supabase.auth.currentSession;

      if (session == null) {
        emit(const SplashSuccess(SplashDestination.login));
        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .maybeSingle();

      final role = profile?['role'] as String?;

      switch (role) {
        case 'customer':
          emit(const SplashSuccess(SplashDestination.customerHome));

        case 'wholesaler':
          emit(const SplashSuccess(SplashDestination.wholesalerDashboard));

        default:
          emit(const SplashSuccess(SplashDestination.login));
      }
    } on PostgrestException catch (error) {
      emit(SplashFailure(error.message));
    } on AuthException catch (error) {
      emit(SplashFailure(error.message));
    } catch (_) {
      emit(const SplashFailure('حدث خطأ غير متوقع أثناء تشغيل التطبيق.'));
    }
  }
}
