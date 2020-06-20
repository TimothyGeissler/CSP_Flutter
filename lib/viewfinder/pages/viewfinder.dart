import 'dart:async';
import 'dart:io';
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_signup/login/components/Color.dart' as colorMap;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dio/dio.dart' as dio;

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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

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
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: Container(
          child: FloatingActionButton(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
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
                  '${DateTime.now()}.jpg',
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Stocks data;

  @override
  void initState() {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _cropImage();

    data = globals.stock_details;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Upload Picture'),
          backgroundColor: Colors.white,
        ),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image. Image.file(File(imagePath))
        body: Center(
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xffffbb00), Color(0xffff9900)]),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: null,
                    ),
                    Container(
                      //padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height / 2) - 200),
                      child: Image.file(image),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 15.0, bottom: 20.0),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 12.0,
                                      bottom: 12.0,
                                      left: 70.0,
                                      right: 70.0),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.green[400],
                                    size: 35,
                                  )),
                            ),
                            onTap: () async {
                              _scaffoldKey.currentState
                                  .showSnackBar(new SnackBar(
                                //duration: new Duration(seconds: 5),
                                content: new Row(
                                  children: <Widget>[
                                    new CircularProgressIndicator(),
                                    new Text("  Saving")
                                  ],
                                ),
                              ));
                              uploadImage(image);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15.0, bottom: 20.0),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 12.0,
                                      bottom: 12.0,
                                      left: 70.0,
                                      right: 70.0),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red[400],
                                    size: 35,
                                  )),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ))));
  }

  uploadImage(File image) async {
    print("Uploading: " + image.path);

    compressAndGetFile(image).then((value) async {
      image = value;
      print("File to upload: " +
          image.path +
          ", size: " +
          image.lengthSync().toString() +
          "bytes");

      var token = "Bearer " + globals.token;
      var stream =
          new http.ByteStream(DelegatingStream.typed(image.openRead()));
      // get file length
      var length = await image.length(); //imageFile is your image file
      Map<String, String> headers = {
        "Authorization": token,
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(globals.upload_img + data.id.toString());
      print("URL: " + uri.toString());
      // create multipart request
      var request = new http.MultipartRequest("POST", uri);

      // multipart that takes file
      var multipartFileSign = new http.MultipartFile(
          'image', stream, length,
          filename: basename(image.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();

      print(response.statusCode);

      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
  }

  Future<File> compressAndGetFile(File file) async {
    //rename image
    String dir = path.dirname(file.path);
    var now = new DateTime.now();
    String formattedDate = DateFormat('yyyMMdd_HHmmss').format(now);
    String newPath = path.join(dir, 'IMG_' + formattedDate + "\.jpg");
    String targetPath = newPath;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 60,
      //rotate: 180,
    );

    print("full quality img: " + file.lengthSync().toString() + "bytes");
    print("compressed: " + result.lengthSync().toString() + "bytes");

    result = result.renameSync(newPath);
    print("Renamed: " + result.path);

    return result;
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
