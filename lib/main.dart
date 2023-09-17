import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_demo/auth/signin.dart';
import 'package:sms_demo/globles.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:workmanager/workmanager.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(MyApp());
}

const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        // Code to run in background
        break;
    }
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _jailBroken = false;

  _checkJailBreaka() async {
    bool jailBroken = false;
    try {
      jailBroken = await FlutterJailbreakDetection.jailbroken;
    } on PlatformException {
      jailBroken = true;
    }

    if (jailBroken) {
      exit(0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkJailBreaka();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: snackbarKey,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SignIn());
  }
}
