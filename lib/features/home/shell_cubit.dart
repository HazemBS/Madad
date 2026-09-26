import 'package:flutter_bloc/flutter_bloc.dart';

class ShellCubit extends Cubit<int> {
  ShellCubit() : super(0);

  int get index => state;

  void goTo(int value) => emit(value);
}
