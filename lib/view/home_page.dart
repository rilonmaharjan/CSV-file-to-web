import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv_upload/view/toast_Style.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>> data = [];
  String? filePath;
  FirebaseInAppMessaging inAppMessage = FirebaseInAppMessaging.instance;

  @override
  void initState() {
    messageListener(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CSV To List"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.green,
                height: 40,
                child: TextButton(
                  child: const Text(
                    "CSV To List",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: uploadCSV,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.green,
                height: 40,
                child: TextButton(
                  child: const Text(
                    "Toast Styles",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const ToastStyle();
                      },
                    ));
                  },
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.green,
                height: 40,
                child: TextButton(
                  child: const Text(
                    "In App Notify",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: ()  {
                     inAppMessage.triggerEvent('awesome_event');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Triggering event: awesome_event'),
                      ),
                    );
                  },
                ),
              ),
            ),
            ListView.builder(
              itemCount: data.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(3),
                  color: index == 0 ? Colors.blue : Colors.white,
                  child: ListTile(
                    leading: Text(
                      data[index][0].toString(),
                      textAlign: TextAlign.center,
                    ),
                    title: Text(
                      data[index][3],
                      textAlign: TextAlign.center,
                    ),
                    trailing: Text(
                      data[index][1].toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void uploadCSV() async {
    //Pick file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
        allowMultiple: false);
    if (result != null) {
      if (kIsWeb) {
        //decode bytes back to utf8
        final bytes = utf8.decode(result.files.first.bytes!.toList());
        //from the csv plugin
        setState(() {
          data = const CsvToListConverter().convert(bytes);
        });
      } else {
        filePath = result.files.first.path!;
        final input = File(filePath!).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();
        setState(() {
          data = fields;
        });
      }
    }
  }

  void messageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
         MotionToast(
          icon: Icons.check_circle_outline,
          iconSize: 0.0,
          primaryColor: Colors.transparent,
          secondaryColor: Colors.transparent,
          animationCurve: Curves.bounceOut,
          backgroundType: BackgroundType.transparent,
          layoutOrientation: ToastOrientation.rtl,
          animationType: AnimationType.fromRight,
          position: MotionToastPosition.top,
          animationDuration: const Duration(milliseconds: 1000),
          borderRadius: 4.0,
          padding: const EdgeInsets.only(top : 8.0, left: 8.0, right: 8.0),
          height: MediaQuery.of(context).size.height * 0.095,
          width: MediaQuery.of(context).size.width - 40,
          title: Row(
            children: [
              const SizedBox(width: 20.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                    '${message.notification!.title}',
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${message.notification!.body}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ],
          ),
          description: const SizedBox(),
        ).show(context);
      }
    });
  }
}
