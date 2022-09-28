import 'package:csv_upload/view/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  debugPrint(message.data.toString());
  debugPrint(message.notification!.title.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyCT-tPPJ34EBnfdByhnmpPybRiWFt9qICc",
    authDomain: "csv-web-notification.firebaseapp.com",
    projectId: "csv-web-notification",
    storageBucket: "csv-web-notification.appspot.com",
    messagingSenderId: "59094487007",
    appId: "1:59094487007:web:611e252785dd9be5243e6a",
    // measurementId: "G-W07G372FDS"
  ));
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
  FirebaseMessaging.instance.getToken().then((value) {
    debugPrint(value);
  });
  await FirebaseInstallations.instance.getId().then((value) => debugPrint('id= $value'));
}

var navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseInAppMessaging inAppMessage = FirebaseInAppMessaging.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
