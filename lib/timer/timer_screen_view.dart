import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';
import 'section_list_view.dart';
import 'set_section_view.dart';
import 'timer_controller_view.dart';

class TimerScreenView extends StatelessWidget {
  static String id = 'timer_screen_view';
  final String uid;
  final String tid;
  final int timerIndex;

  const TimerScreenView(
      {Key? key, this.uid = '', this.tid = '', this.timerIndex = -1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: _buildTitle(context), actions: [
        IconButton(
            onPressed: () => viewModel.refreshTimer(tid),
            icon: const Icon(Icons.refresh))
      ]),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return Text(viewModel.timerDocs[timerIndex]['title']);
    //おそらくタイトル編集時にまた修正が必要
  }

  Widget _buildBody(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      TimerControllerView(uid: uid, tid: tid, timerIndex: timerIndex),
      SectionListView(uid: uid, tid: tid),
    ]);
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return SafeArea(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => SetSectionView(uid: uid, tid: tid));
              viewModel.clearSectionValues();
              viewModel.clearIsCanAddSection();
            },
            child: const Padding(
                padding: EdgeInsets.all(32.0), child: Icon(Icons.add))));
  }
}
