import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';
import '../welcome/welcome_screen_view.dart';

class SettingsScreenView extends StatelessWidget {
  const SettingsScreenView({Key? key}) : super(key: key);
  static String id = 'settings_screen_view';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0, title: const Text('Settings')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context);
    return Center(
        child: ElevatedButton(
            onPressed: () {
              viewModel.logout(context);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreenView()),
                  (_) => false);
            },
            child: const Padding(
                padding: EdgeInsets.all(20.0), child: Text('Logout'))));
  }
}
