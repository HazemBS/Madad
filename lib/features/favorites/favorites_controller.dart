import 'package:flutter/foundation.dart';

class FavoritesController extends ChangeNotifier {
  final List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  Future<void> refresh() async {}

  Future<bool> toggle(String id) async {
    final added = !_ids.contains(id);
    if (added) {
      _ids.add(id);
    } else {
      _ids.remove(id);
    }
    notifyListeners();
    return added;
  }

  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
  }
}
