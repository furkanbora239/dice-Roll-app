// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import 'main.dart';

class pro with ChangeNotifier {
  final List<int> _diceList = [diceRoll()];

  List<int> get diceList => _diceList;

  final bool _pressChack = false;

  bool get pressChack => _pressChack;

  void diceAdd() {
    _diceList.add(diceRoll());
    diceSum();

    notifyListeners();
  }

  void reRollDices() {
    for (int i = 0; _diceList.length > i; i++) {
      _diceList[i] = diceRoll();
    }
    diceSum();

    notifyListeners();
  }

  void diceSum() {
    int sum = 0;
    for (var i in _diceList) {
      sum += i;
    }
    diceNumberSum = sum;
    notifyListeners();
    //return diceNumberSum;
  }

  void diceRemove() {
    if (_diceList.length > 1) {
      _diceList.removeLast();
      diceSum();
      notifyListeners();
    }
  }
}
