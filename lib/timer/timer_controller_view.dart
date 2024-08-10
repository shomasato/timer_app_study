import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ios_build_test/commons/timer_string_model.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';

class TimerControllerView extends StatelessWidget {
  final String uid;
  final String tid;
  final int timerIndex;

  const TimerControllerView(
      {Key? key,
      required this.uid,
      required this.tid,
      required this.timerIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    final int activeTimerIndex =
        viewModel.activeTimers.indexWhere((e) => e.tid == tid);
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          viewModel.isTimerDefault
              ? viewModel.startTimer(
                  tid, viewModel.timerDocs[timerIndex]['totalCount'])
              : (viewModel.activeTimers[activeTimerIndex].timer.isActive)
                  ? viewModel.stopTimer(tid)
                  : viewModel.startTimer(
                      tid, viewModel.timerDocs[timerIndex]['totalCount']);
        },
        child: Padding(
          padding: const EdgeInsets.all(80.0),
          child: viewModel.isTimerDefault
              ? _defaultTotalCount(context)
              : _activeTotalCount(context),
        ));
  }

  Widget _defaultTotalCount(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('timers')
            .doc(tid)
            .collection('sections')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> sectionDocs = snapshot.data!.docs;
            late int totalCount;
            if (sectionDocs.isNotEmpty) {
              totalCount = sectionDocs
                  .sublist(0)
                  .map((e) => e['sectionCount'])
                  .reduce((v, e) => v + e);
            } else {
              totalCount = 0;
            }
            return Text(timerString(totalCount),
                style: Theme.of(context).textTheme.headlineLarge?.merge(
                    const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()])));
          } else {
            return Text('',
                style: Theme.of(context).textTheme.headlineLarge?.merge(
                    const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()])));
          }
        });
  }

  Widget _activeTotalCount(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    final int activeTimerIndex =
        viewModel.activeTimers.indexWhere((e) => e.tid == tid);
    return Text(
        timerString(viewModel.activeTimers[activeTimerIndex].totalCount),
        style: Theme.of(context).textTheme.headlineLarge?.merge(
            const TextStyle(fontFeatures: [FontFeature.tabularFigures()])));
  }
}
