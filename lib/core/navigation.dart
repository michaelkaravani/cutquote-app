import 'package:flutter/material.dart';

extension NavigationX on BuildContext {
  Future<T?> push<T>(Widget page) => Navigator.push<T>(
    this,
    MaterialPageRoute(builder: (_) => page),
  );
  void pop() => Navigator.pop(this);
}
