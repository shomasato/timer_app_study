import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commons/active_timer_model.dart';
import '../commons/timer_string_model.dart';
import '../commons/view_model.dart';
import '../timer/timer_screen_view.dart';

class TimerListView extends StatelessWidget {
  final String uid;

  const TimerListView({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('timers')
            .orderBy('index')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> timerDocs = snapshot.data!.docs;
            viewModel.timerDocs = timerDocs;
            return ReorderableListView.builder(
                itemCount: viewModel.timerDocs.length,
                itemBuilder: (context, index) => _buildItem(context, index),
                onReorder: (oldIndex, newIndex) =>
                    viewModel.onReorderTimer(oldIndex, newIndex, uid));
          } else {
            return const Center(child: Text('Now loading ...'));
          }
        });
  }

  Widget _buildItem(BuildContext context, int index) {
    final viewModel = Provider.of<ViewModel>(context);
    final String tid = viewModel.timerDocs[index].id;

    final bool isTimerActive =
        viewModel.activeTimers.any((ActiveTimer e) => e.tid == tid);
    final int activeTimerIndex =
        viewModel.activeTimers.indexWhere((e) => e.tid == tid);

    return Card(
        key: Key(tid),
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              viewModel.checkTimerDefault(tid);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      TimerScreenView(uid: uid, tid: tid, timerIndex: index)));
            },
            child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(viewModel.timerDocs[index]['title'],
                            overflow: TextOverflow.ellipsis, maxLines: 2),
                      ),
                      const SizedBox(width: 20.0),
                      Text(
                          timerString(isTimerActive
                              ? viewModel
                                  .activeTimers[activeTimerIndex].totalCount
                              : viewModel.timerDocs[index]['totalCount']),
                          style: const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()])),
                    ]))));
  }
}
