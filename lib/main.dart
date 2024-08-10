import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ios_build_test/timer/timer_screen_view.dart';
import 'package:provider/provider.dart';
import 'commons/firebase_options.dart';
import 'commons/view_model.dart';
import 'home/home_screen_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome/welcome_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ViewModel>(create: (context) => ViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomeScreenView();
              } else {
                return const WelcomeScreenView();
              }
            }),
        routes: {
          HomeScreenView.id: (_) => const HomeScreenView(),
          WelcomeScreenView.id: (_) => const WelcomeScreenView(),
          TimerScreenView.id: (_) => const TimerScreenView(),
        },
      ),
    );
  }
}
