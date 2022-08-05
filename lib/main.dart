import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Upload Sample'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: ElevatedButton(
              child: const Text(
                  "Pick MP4 Video File\n(At least of size 20 MB and Max 50 MB)"),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['mp4']);
                if (result != null && result.files.isNotEmpty) {
                  var fileBytes = result.files.first.bytes;
                  String fileName = result.files.first.name;

                  debugPrint("file name is $fileName");

                  if (fileBytes != null) {
                    uploadFile(fileName, fileBytes);
                  }
                }
              },
            ),
          ),
          if (isUploading) ...[
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void uploadFile(String fileName, Uint8List bytes) async {
    debugPrint("Uploading file");
    setState(() {
      isUploading = true;
    });

    try {
      var uri = Uri.https('api.upload.io', 'v1/files/basic');
      debugPrint("calling POST API");

      // adding delay so that state can show the loader
      await Future.delayed(const Duration(seconds: 2));

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'video/mp4', // as we allow only mp4
          'Authorization': 'Bearer public_12a1xo16bikDEXNFaLJtVhgqs4Nm',
        },
        body: bytes,
      );

      debugPrint("status code >>>>>>>>> ${response.statusCode}");
      debugPrint("body >>>>>>>>> ${response.body}");
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      isUploading = false;
    });
  }
}
