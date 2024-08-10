import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';

class SetSectionView extends StatelessWidget {
  final String uid;
  final String tid;
  final DocumentSnapshot? editSection;

  const SetSectionView(
      {Key? key, required this.uid, required this.tid, this.editSection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isEdit() => editSection != null;
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 80.0),
              Center(child: Text(_isEdit() ? 'EDIT SECTION' : 'NEW SECTION')),
              const SizedBox(height: 40.0),
              _buildTimePickers(context),
              const SizedBox(height: 80.0),
              _buildSetButton(context, _isEdit()),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickers(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberPicker(
          value: viewModel.hourValue,
          minValue: 0,
          maxValue: 23,
          step: 1,
          onChanged: (value) => viewModel.changeHourValue(value),
        ),
        const Text(':'),
        NumberPicker(
          value: viewModel.minutesValue,
          minValue: 0,
          maxValue: 59,
          step: 1,
          onChanged: (value) => viewModel.changeMinuteVal(value),
        ),
        const Text(':'),
        NumberPicker(
          value: viewModel.secondsValue,
          minValue: 0,
          maxValue: 59,
          step: 1,
          onChanged: (value) => viewModel.changeSecondVal(value),
        ),
      ],
    );
  }

  Widget _buildSetButton(BuildContext context, bool isEdit) {
    final viewModel = Provider.of<ViewModel>(context);
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: viewModel.isCanSetSection
                ? () {
              isEdit
                  ? viewModel.updateSection(uid, tid, editSection!.id)
                  : viewModel.addSection(uid, tid);
              Navigator.of(context).pop();
            }
                : null,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(isEdit ? 'Edit Section' : 'Add Section'))));
  }
}
