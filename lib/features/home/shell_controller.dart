import 'package:flutter/foundation.dart';

class ShellController extends ChangeNotifier {
  int index = 0;

  void goTo(int value) {
    index = value;
    notifyListeners();
  }
}
