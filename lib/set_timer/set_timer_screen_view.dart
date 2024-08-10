import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';

class SetTimerScreenView extends StatelessWidget {
  static String id = 'set_timer_screen_view';
  final String uid;
  final DocumentSnapshot? editTimer;

  const SetTimerScreenView({Key? key, this.uid = '', this.editTimer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isEdit() => editTimer != null;
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0, title: Text(_isEdit() ? 'EDIT TIMER' : 'NEW TIMER')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    bool _isEdit() => editTimer != null;
    final viewModel = Provider.of<ViewModel>(context);
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: TextField(
          autofocus: true,
          controller: viewModel.timerTitleController,
          decoration: const InputDecoration(hintText: 'Timer Title'),
          onSubmitted: (value) {
            _isEdit()
                ? viewModel.updateTimer(uid, editTimer!.id)
                : viewModel.addTimer(uid);
            Navigator.of(context).pop();
          }),
    );
  }
}
