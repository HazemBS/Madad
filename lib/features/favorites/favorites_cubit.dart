import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_store.dart';
import '../../data/remote/madad_store.dart';
import '../../data/repositories/commerce_repository.dart';

class FavoritesCubit extends Cubit<List<String>> {
  FavoritesCubit({LocalStore? store, CommerceRepository? remote})
    : _store = store,
      _remote = remote != null && remote.usesRemoteAuth ? remote : null,
      super(const []) {
    final saved = store?.readFavorites() ?? const <String>[];
    if (saved.isEmpty) return;
    _ids.addAll(saved);
    emit(List.unmodifiable(List<String>.of(_ids)));
  }

  final LocalStore? _store;
  final CommerceRepository? _remote;
  final List<String> _ids = [];

  List<String> get ids => state;

  bool contains(String id) => _ids.contains(id);

  Future<void> refresh() async {
    final remote = _remote;
    if (remote == null) return;
    try {
      final ids = await remote.loadFavoriteIds();
      _ids
        ..clear()
        ..addAll(ids);
      _publish();
    } on MadadAuthException {
      rethrow;
    } catch (_) {
      throw MadadAuthException(
        'تعذر مزامنة المفضلة. تُعرض آخر نسخة محفوظة على الجهاز.',
      );
    }
  }

  Future<bool> toggle(String id) async {
    final added = !_ids.contains(id);
    if (added) {
      if (!_ids.contains(id)) _ids.add(id);
    } else {
      _ids.remove(id);
    }
    _publish();
    final remote = _remote;
    if (remote == null) return added;
    try {
      await remote.setFavorite(productId: id, saved: added);
    } catch (error) {
      if (added) {
        _ids.remove(id);
      } else if (!_ids.contains(id)) {
        _ids.add(id);
      }
      _publish();
      if (error is MadadAuthException) rethrow;
      throw MadadAuthException('تعذر تحديث المفضلة.');
    }
    return added;
  }

  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    _publish();
  }

  void _publish() {
    emit(List.unmodifiable(List<String>.of(_ids)));
    _store?.saveFavorites(_ids);
  }
}
