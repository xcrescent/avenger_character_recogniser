import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File>? imageFile;
  File? _image;
  String result = '';
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadDataModelFiles();
  }

  loadDataModelFiles() async {
    String? output = await Tflite.loadModel(
      model: 'assets/models/model.tflite',
      labels: 'assets/models/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    print(output);
  }

  doImageClassification() async {
    var recognitions = await Tflite.runModelOnImage(
      path: _image!.path,
      numResults: 2,
      threshold: 0.1,
      imageMean: 0.0,
      imageStd: 255.0,
      asynch: true,
    );

    // setState(() {
    result = '';
    // });
    print(recognitions![0]['label']);
    for (var response in recognitions) {
      result += response['label'];
    }
    setState(() {
      result;
    });
  }

  selectPhoto() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  capturePhoto() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              // image: DecorationImage(
              //   // image: AssetImage('images/background.jpg'),
              //   fit: BoxFit.cover,
              // ),
              ),
          child: Column(
            children: [
              SizedBox(width: 100),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: ElevatedButton(
                        onPressed: selectPhoto,
                        onLongPress: capturePhoto,
                        child: Container(
                          margin: EdgeInsets.only(top: 30, right: 35, left: 18),
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  height: 160,
                                  width: 400,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 140,
                                  height: 190,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 160),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Text(
                  'Image $result',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Brand Bold',
                      fontSize: 40,
                      color: Colors.pinkAccent,
                      backgroundColor: Colors.white60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
