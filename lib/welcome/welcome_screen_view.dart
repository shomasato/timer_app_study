import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';

class WelcomeScreenView extends StatelessWidget {
  const WelcomeScreenView({Key? key}) : super(key: key);
  static String id = 'welcome_screen_view';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: const Text('Welcome')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return Center(
        child: ElevatedButton(
            onPressed: () {
              viewModel.onGetstarted(context);
            },
            child: const Padding(
                padding: EdgeInsets.all(20.0), child: Text('Go Stated'))));
  }
}
