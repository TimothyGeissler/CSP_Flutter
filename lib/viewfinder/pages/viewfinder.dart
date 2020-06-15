import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_signup/login/components/Color.dart' as colorMap;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:flutter_login_signup/vars.dart' as globals;

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: Viewfinder(
        // Pass the appropriate camera to the Viewfinder widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class Viewfinder extends StatefulWidget {
  final CameraDescription camera;

  const Viewfinder({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  ViewfinderState createState() => ViewfinderState();
}

class ViewfinderState extends State<Viewfinder> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Take a picture',
      )),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview. CameraPreview(_controller);
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);
            globals.image_captured = path;
            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }

}

class DisplayPictureScreen extends StatefulWidget {
  @override
  _DisplayPictureState createState() => _DisplayPictureState();
}

// A widget that displays the picture taken by the user.
class _DisplayPictureState extends State<DisplayPictureScreen> {
  File image = File(globals.image_captured);

  //_DisplayPictureState({Key key, this.image});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(title: Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image. Image.file(File(imagePath))
        body: Center(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xffffd500), Color(0xffff9900)])),
                child: ListView(
                  children: <Widget>[
                    Image.file(image),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 12.0, bottom: 12.0, left: 42.0, right: 42.0),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.amber,
                                  size: 35,
                                )
                              ),
                            ),
                            onTap: () async {
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                    //duration: new Duration(seconds: 5),
                                    content: new Row(
                                      children: <Widget>[
                                        new CircularProgressIndicator(),
                                        new Text("  Saving")
                                      ],
                                    ),
                                  )
                              );
                              //handleLogin();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 12.0, bottom: 12.0, left: 42.0, right: 42.0),
                                  child: Icon(
                                      Icons.close,
                                    color: Colors.amber,
                                    size: 35,
                                  )
                              ),
                            ),
                            onTap: () async {
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                    //duration: new Duration(seconds: 5),
                                    content: new Row(
                                      children: <Widget>[
                                        new CircularProgressIndicator(),
                                        new Text("  Saving")
                                      ],
                                    ),
                                  )
                              );
                              _cropImage();
                            },
                          ),
                        )
                      ],
                    )
                  ],
                )
            )
        )
    );
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.white,
            activeControlsWidgetColor: Colors.amber,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      setState(() {
        image = croppedFile;
      });
    }
  }

}
