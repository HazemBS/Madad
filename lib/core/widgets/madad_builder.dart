import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// يعيد بناء الواجهة عند تغيّر Cubit أو ChangeNotifier.
class MadadBuilder extends StatefulWidget {
  const MadadBuilder({
    super.key,
    this.cubits = const [],
    this.listenables = const [],
    required this.builder,
  });

  final List<Cubit<dynamic>> cubits;
  final List<Listenable> listenables;
  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  State<MadadBuilder> createState() => _MadadBuilderState();
}

class _MadadBuilderState extends State<MadadBuilder> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(MadadBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_same(oldWidget.cubits, widget.cubits) &&
        _same(oldWidget.listenables, widget.listenables)) {
      return;
    }
    _unsubscribe(oldWidget.listenables);
    _subscribe();
  }

  void _subscribe() {
    for (final cubit in widget.cubits) {
      _subscriptions.add(
        cubit.stream.listen((_) {
          if (mounted) setState(() {});
        }),
      );
    }
    for (final listenable in widget.listenables) {
      listenable.addListener(_onListenable);
    }
  }

  void _onListenable() {
    if (mounted) setState(() {});
  }

  void _unsubscribe(List<Listenable> listenables) {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    for (final listenable in listenables) {
      listenable.removeListener(_onListenable);
    }
  }

  bool _same(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _unsubscribe(widget.listenables);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, null);
}
