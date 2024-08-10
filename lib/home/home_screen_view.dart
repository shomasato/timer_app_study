import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commons/view_model.dart';
import '../set_timer/set_timer_screen_view.dart';
import '../settings/settings_screen_view.dart';
import 'timer_list_view.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({Key? key}) : super(key: key);
  static String id = 'home_screen_view';

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView>
    with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;

  get uid => user!.uid.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.read<ViewModel>();
    viewModel.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final viewModel = context.read<ViewModel>();
    if (state == AppLifecycleState.paused) {
      viewModel.paused();
    } else if (state == AppLifecycleState.resumed) {
      viewModel.resumed();
    } else if (state == AppLifecycleState.detached) {
      viewModel.detached();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewModel>(builder: (context, model, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(uid),
          centerTitle: false,
          elevation: 0.0,
          actions: [
            IconButton(
                onPressed: () {
                  model.test();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsScreenView()));
                },
                icon: const Icon(Icons.menu)),
          ],
        ),
        body: TimerListView(uid: uid),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SetTimerScreenView(uid: uid)));
              model.clearTimerTitleController();
            }),
        resizeToAvoidBottomInset: false,
      );
    });
  }
}
