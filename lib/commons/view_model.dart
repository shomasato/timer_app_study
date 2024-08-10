import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen_view.dart';
import 'active_timer_model.dart';

class ViewModel extends ChangeNotifier {
  //Timer
  List<DocumentSnapshot> timerDocs = [];
  List<ActiveTimer> activeTimers = [];
  TextEditingController timerTitleController = TextEditingController();
  bool isTimerDefault = true;

  Future<void> addTimer(String uid) async {
    final String timerTitle = timerTitleController.text;
    if (timerTitle.isNotEmpty) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection('users').doc(uid).collection('timers').doc().set({
        'index': (timerDocs.isEmpty) ? 1 : timerDocs.last['index'] + 1,
        'title': timerTitle,
        'totalCount': 0,
      });
    }
  }

  Future<void> updateTimer(String uid, String tid) async {}

  Future<void> setTotalCount(String uid, String tid) async {
    final int totalCount = sectionDocs
        .sublist(0)
        .map((e) => e['sectionCount'])
        .reduce((v, e) => v + e);
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection('users')
        .doc(uid)
        .collection('timers')
        .doc(tid)
        .set({'totalCount': totalCount}, SetOptions(merge: true));
  }

  void clearTimerTitleController() => timerTitleController.clear();

  void setTimerTitleController(DocumentSnapshot timer) {
    final String edittingTimerTitle = timer['title'];
    timerTitleController.text = edittingTimerTitle;
  }

  void checkTimerDefault(String tid) {
    final List<ActiveTimer> checkactiveTimers = activeTimers;
    final bool isActiveTimer =
        checkactiveTimers.any((ActiveTimer e) => e.tid == tid);
    if (activeTimers.isEmpty) {
      isTimerDefault = true;
    } else if (isActiveTimer) {
      isTimerDefault = false;
    } else {
      isTimerDefault = true;
    }
  }

  void startTimer(String tid, int totalCount) {
    if (sectionDocs.isEmpty) {
      return;
    }
    isTimerDefault = false;
    final List<ActiveTimer> checkTimers = activeTimers;
    final bool isTimerActive = checkTimers.any((ActiveTimer e) => e.tid == tid);
    if (isTimerActive) {
      final int timerIndex = activeTimers.indexWhere((e) => e.tid == tid);
      final ActiveTimer restartActiveTimer = activeTimers[timerIndex];
      activeTimers[timerIndex].timer = _timer(restartActiveTimer);
      activeTimers[timerIndex].isCounting = true;
    } else {
      final ActiveTimer newActiveTimer =
          ActiveTimer(tid: tid, totalCount: totalCount);
      newActiveTimer.timer = _timer(newActiveTimer);
      activeTimers.add(newActiveTimer);
    }
    notifyListeners();
  }

  Timer _timer(ActiveTimer activeTimer) {
    return Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (activeTimer.totalCount >= 1) {
        activeTimer.totalCount--;
      } else {
        refreshTimer(activeTimer.tid);
      }
      notifyListeners();
    });
  }

  void stopTimer(String tid) {
    final int timerIndex = activeTimers.indexWhere((e) => e.tid == tid);
    activeTimers[timerIndex].timer.cancel();
    activeTimers[timerIndex].isCounting = false;
    notifyListeners();
  }

  void refreshTimer(String tid) {
    if (isTimerDefault) {
      return;
    } else {
      final int timerIndex = activeTimers.indexWhere((e) => e.tid == tid);
      activeTimers[timerIndex].timer.cancel();
      activeTimers.removeAt(timerIndex);
      isTimerDefault = true;
      notifyListeners();
    }
  }

  void onReorderTimer(int oldIndex, int newIndex, String uid) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    DocumentSnapshot moveSnapshot = timerDocs.removeAt(oldIndex);
    timerDocs.insert(newIndex, moveSnapshot);
    saveAllTimerIndex(uid);
  }

  Future<void> saveAllTimerIndex(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final batch = db.batch();
    timerDocs.asMap().forEach((index, snapshot) {
      final timerRef =
          db.collection('users').doc(uid).collection('timers').doc(snapshot.id);
      final timerOpts = {'index': index};
      batch.set(timerRef, timerOpts, SetOptions(merge: true));
    });
    await batch.commit();
  }

  //Section
  int hourValue = 0;
  int minutesValue = 0;
  int secondsValue = 0;
  List<DocumentSnapshot> sectionDocs = [];
  bool isCanSetSection = false;

  Future<void> addSection(String uid, String tid) async {
    final int sectionCount =
        hourValue * 3600 + minutesValue * 60 + secondsValue;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection('users')
        .doc(uid)
        .collection('timers')
        .doc(tid)
        .collection('sections')
        .doc()
        .set({
      'index': (sectionDocs.isEmpty) ? 1 : sectionDocs.last['index'] + 1,
      'sectionCount': sectionCount,
    });
    setTotalCount(uid, tid);
    notifyListeners();
  }

  Future<void> updateSection(String uid, String tid, String sid) async {
    final int sectionCount =
        hourValue * 3600 + minutesValue * 60 + secondsValue;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection('users')
        .doc(uid)
        .collection('timers')
        .doc(tid)
        .collection('sections')
        .doc(sid)
        .set({'sectionCount': sectionCount}, SetOptions(merge: true));
    setTotalCount(uid, tid);
    notifyListeners();
  }

  void changeHourValue(int value) {
    hourValue = value;
    checkCanSetSection();
    notifyListeners();
  }

  void changeMinuteVal(int value) {
    minutesValue = value;
    checkCanSetSection();
    notifyListeners();
  }

  void changeSecondVal(int value) {
    secondsValue = value;
    checkCanSetSection();
    notifyListeners();
  }

  void checkCanSetSection() {
    final bool isHour = hourValue == 0;
    final bool isMin = minutesValue == 0;
    final bool isSec = secondsValue == 0;
    isCanSetSection = (isHour && isMin && isSec) ? false : true;
    notifyListeners();
  }

  void clearSectionValues() {
    hourValue = 0;
    minutesValue = 0;
    secondsValue = 0;
  }

  void clearIsCanAddSection() => isCanSetSection = false;

  void setTimeValues(DocumentSnapshot section) {
    final int sectionCount = section['sectionCount'];
    final int a = sectionCount ~/ 3600;
    final int t = sectionCount - (3600 * a);
    final int h = sectionCount ~/ 3600;
    final int m = t ~/ 60;
    final int s = t % 60;
    hourValue = h;
    minutesValue = m;
    secondsValue = s;
  }

  List<String> activeTimerIds = [];
  bool isPaused = false;
  late DateTime pausedAt;

  void paused() {
    print('Paused');
    final bool isNotActive = activeTimers.isEmpty;
    if (isNotActive) return;

    final List<ActiveTimer> checkActiveTimers = activeTimers;
    final bool isActiveTimer =
        checkActiveTimers.any((ActiveTimer e) => e.timer.isActive);
    if (!isActiveTimer) return;

    for (ActiveTimer e in checkActiveTimers) {
      final bool isTimerActive = e.timer.isActive;
      if (isTimerActive) {
        activeTimerIds.add(e.tid);
      }
    }
    isPaused = true;
    pausedAt = DateTime.now();
    //for (ActiveTimer e in activeTimers) {stopTimer(e.tid);}
  }

  void resumed() {
    if (!isPaused) return;

    isPaused = false;
    final int bgCount = DateTime.now().difference(pausedAt).inSeconds;
    for (String acviveTimerId in activeTimerIds) {
      final int timerIndex =
          activeTimers.indexWhere((e) => e.tid == acviveTimerId);
      final ActiveTimer timer = activeTimers[timerIndex];
      if (timer.totalCount < bgCount) {
        refreshTimer(timer.tid);
      } else {
        final count = timer.totalCount - bgCount;
        startTimer(acviveTimerId, count);
      }
    }
    activeTimerIds.clear();
    notifyListeners();
  }

  void test() {
    print(activeTimers.length.toString());
    for (ActiveTimer e in activeTimers) {
      print(e.tid);
      print(e.isCounting.toString());
      print(e.timer.isActive);
    }
  }

  Future<void> detached() async {
    print('Detached');

    final bool isNotActive = activeTimers.isEmpty;
    if (isNotActive) return;

    final List<ActiveTimer> checkActiveTimers = activeTimers;
    final bool isTimerActive =
        checkActiveTimers.any((ActiveTimer e) => e.isCounting);
    test();
    if (!isTimerActive) return;

    print('Good Job');
  }

  Future<void> didChangeDependencies() async {}

  // Account
  String infoText = '';

  Future<void> onGetstarted(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously().then((value) {
        if (value.user != null) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreenView()));
        }
      });
    } catch (e) {
      infoText = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
}
