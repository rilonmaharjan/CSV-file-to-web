import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv_upload/view/toast_Style.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>> data = [];
  String? filePath;

  @override
  void initState() {
    messageListener(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   FirebaseInAppMessaging inAppMessage = FirebaseInAppMessaging.instance;
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
                height: 30,
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
                height: 30,
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
            ElevatedButton(
              onPressed: () async {
                await inAppMessage.triggerEvent('awesome_event');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Triggering event: awesome_event'),
                  ),
                );
              },
              child: Text(
                'Notification'.toUpperCase(),
                style: const TextStyle(color: Colors.white),
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
        showDialog(
          context: context,
          builder: ((BuildContext context) {
            return SimpleDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title ${message.notification!.title}'),
                  Text('Title ${message.notification!.body}'),
                ],
              ),
            );
          }),
        );
      }
    });
  }
}
