import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ios_build_test/timer/set_section_view.dart';
import 'package:provider/provider.dart';
import '../commons/timer_string_model.dart';
import '../commons/view_model.dart';

class SectionListView extends StatelessWidget {
  final String uid;
  final String tid;

  const SectionListView({Key? key, required this.uid, required this.tid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('timers')
            .doc(tid)
            .collection('sections')
            .orderBy('index')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> sectionDocs = snapshot.data!.docs;
            viewModel.sectionDocs = sectionDocs;
            return Expanded(
                child: ReorderableListView.builder(
                    itemCount: viewModel.sectionDocs.length,
                    itemBuilder: (context, index) => _buildItem(context, index),
                    onReorder: (oldIndex, newIndex) {}));
          } else {
            return const Expanded(
                child: Center(child: Text('Now loading ...')));
          }
        });
  }

  Widget _buildItem(BuildContext context, int index) {
    final viewModel = Provider.of<ViewModel>(context);
    final String sid = viewModel.sectionDocs[index].id;
    return Card(
        key: Key(sid),
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              viewModel.setTimeValues(viewModel.sectionDocs[index]);
              viewModel.clearIsCanAddSection();
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SetSectionView(
                      uid: uid,
                      tid: tid,
                      editSection: viewModel.sectionDocs[index]));
            },
            child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                    child: Text(timerString(
                        viewModel.sectionDocs[index]['sectionCount']))))));
  }
}
