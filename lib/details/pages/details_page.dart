import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_signup/login/components/login_model.dart';
import 'package:flutter_login_signup/stock/components/get_stock_data.dart';
import 'package:flutter_login_signup/stock/components/get_stock_details.dart';
import 'package:flutter_login_signup/stock/pages/stock_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login_signup/vars.dart' as globals;
import 'package:flutter_login_signup/dashboard/components/dealer_model.dart'
    as dealer;
import 'package:flutter_login_signup/dashboard/components/dealer_stats_model.dart';
import 'package:flutter_login_signup/dashboard/components/pie_chart.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart';
import 'package:flutter_login_signup/stock/pages/bubble_indicator_painter.dart';

import 'package:flutter_login_signup/details/components/progress_button.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:flutter_login_signup/viewfinder/pages/viewfinder.dart';
import 'package:progress_state_button/progress_button.dart';

import 'package:flutter_login_signup/login/components/Color.dart' as colourMap;

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  bool published;
  bool saveFabVisibility = true;

  TextEditingController c1 = new TextEditingController();
  TextEditingController c2 = new TextEditingController();
  TextEditingController c3 = new TextEditingController();
  TextEditingController c4 = new TextEditingController();
  TextEditingController c5 = new TextEditingController();
  TextEditingController c6 = new TextEditingController();
  TextEditingController c7 = new TextEditingController();
  TextEditingController c8 = new TextEditingController();
  TextEditingController c9 = new TextEditingController();

  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0);

  List<String> fieldLabels = new List.unmodifiable([
    "Stock No.",
    "Price (R)",
    "Cost Price (R)",
    "Year",
    "Mileage (km)",
    "Published",
    "Colour",
    "VIN",
    "Reg. No."
  ]);
  List<IconData> icons = new List.unmodifiable([
    Icons.format_list_numbered,
    Icons.attach_money,
    Icons.monetization_on,
    Icons.calendar_today,
    Icons.timeline,
    Icons.book,
    Icons.color_lens,
    Icons.directions_car,
    Icons.info_outline
  ]);

  List<ImageProvider> photos = new List();

  Stocks data;

  List<String> hint_texts = new List();

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: const Color(0xFF2C365E),
      end: Colors.grey,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));

    setState(() {
      GetStockDataDetails details = new GetStockDataDetails();
      details.updateStockDetails();
      data = globals.stock_details;
      //init images
      // loadImages();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollHeader();
    });

    //init published var
    published = parsePublished(data.state);

    super.initState();
  }

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    c4.dispose();
    c5.dispose();
    c6.dispose();
    c7.dispose();
    c8.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();

    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  void loadImages() async {
    for (int i = 0; i < globals.photos.length; i++) {
      await photos.add(imgFetcher(globals.photos, i));
    }
  }

  ImageProvider imgFetcher(List<Photo> data, int index) {
    try {
      String directory = data[index].directory, filename = data[index].photo;

      var token = "Bearer " + globals.token;
      print("Getting photo: " + filename);
      String url = globals.base_img_url;
      String photo_request = url + directory + filename;
      NetworkImage photo = NetworkImage(
        photo_request,
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
      );
      return photo;
    } catch (e) {
      return AssetImage(
        'assets/images/car_icon.png',
      );
    }
  }

  void scrollHeader() {
    try {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 5000), curve: Curves.ease);
    } catch (e) {
      print("failed animating title: " + e.toString());
    }
    Timer(Duration(milliseconds: 7000), () {
      try {
        scrollController.animateTo(0.0,
            duration: Duration(milliseconds: 5000), curve: Curves.ease);
      } catch (e) {
        print("Failed animating title: " + e.toString());
      }
    });
  }

  String parseColor(int colourInt) {
    String result = "Colour not found";
    //print("Translating colour: " + colourInt.toString());
    colourMap.ColourData colourData = globals.colourData;
    int len = colourData.colourList.colours.length;
    for (int i = 0; i < len; i++) {
      if (colourData.colourList.colours[i].id == colourInt) {
        result = colourData.colourList.colours[i].colour;
      }
    }
    //print("Colour translated: " + result);
    return result;
  }

  int parseColourToString(String colour) {
    int result = data.colour; //failsafe

    colourMap.ColourData colourData = globals.colourData;
    int len = colourData.colourList.colours.length;
    for (int i = 0; i < len; i++) {
      if (colourData.colourList.colours[i].colour == colour) {
        result = colourData.colourList.colours[i].id;
      }
    }
    return result;
  }

  bool parsePublished(int publishedInt) {
    if (publishedInt == 1) {
      return false;
    } else {
      return true;
    }
  }

  int parsePublishedToInt(bool publishedBool) {
    if (publishedBool == false) {
      return 1;
    } else {
      return 0;
    }
  }

  String parseStrings(String input) {
    if (input == null) {
      return "";
    } else if (input == "null") {
      return "";
    } else {
      return input;
    }
  }

  int parseTxtFieldToInt(String data) {
    int response;
    try {
      response = int.parse(data);
    } catch (e) {
      response = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "CSP Mobile",
          style: TextStyle(fontSize: 27.0),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StockPage()),
            );
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
      ),
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        //physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height - 145
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Center(
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [Color(0xffffd500), Color(0xffff9900)])),
                        child: Wrap(
                          children: <Widget>[
                            SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 25.0, left: 20.0, bottom: 0.0),
                                    child: Text(
                                      data.trim.substring(data.trim.indexOf('-') + 2,
                                          data.trim.lastIndexOf("(")),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: doublePage(context),
                            ),
                          ],
                        ))),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: saveFabVisibility,
        child: FloatingActionButton(
          child: Icon(
            Icons.save,
            color: Colors.white,
          ),
          onPressed: () {
            print("Save fields...");
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Row(
                children: <Widget>[
                  new CircularProgressIndicator(),
                  new Text("  Saving")
                ],
              ),
            ));
            saveData();
          },
        ),
      ),
    );
  }

  saveData() async {
    //check data has been edited
    if (c1.text != parseStrings(data.stock_num) ||
        c2.text != parseStrings(data.price.toString()) ||
        c3.text != parseStrings(data.cost_price.toString()) ||
        c4.text != parseStrings(data.year.toString()) ||
        c5.text != parseStrings(data.mileage.toString()) ||
        c6.text != parseColor(data.colour) ||
        c7.text != parseStrings(data.vin) ||
        c8.text != parseStrings(data.regNo) ||
        published != parsePublished(data.state)) {
      //can save
      print("changes found...\nStock No. " + c1.text + "\nPrice " + c2.text + "\nCost price" + c3.text +
          "\nYear " + c4.text + "\nMileage " + c5.text + "\nColour " + parseColourToString(c6.text).toString() +
          "\nVin " + c7.text + "\nReg No. " + c8.text + "\nState " + parsePublishedToInt(published).toString());

      var url = globals.update_stock_details + data.id.toString();
      print("URL to post: " + url);

      var token = "Bearer " + globals.token;
      print("Auth token: " + token);
      var response = await http.post(
          globals.login,
          headers: <String, String>{
            'Authorization': token,
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'id': data.id,
            'mileage': c5.text,
            'stock_num': c1.text,
            'year': c4.text,
            'price': c2.text,
            'cost_price': c3.text,
            'vin': c7.text,
            'reg_num': c8.text,
            'state': parsePublishedToInt(published),
            'colour': parseColourToString(c6.text),
          })
      );
      print("Response: " + response.body + "\nPOST CODE: " + response.statusCode.toString());
    } else {
      print("no changes made");
    }
  }

  Widget doublePage(BuildContext context) {
    PageController _pageController = new PageController();
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
      },
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 140,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent
                ], //[Color(0xffffd500), Color(0xffff9900)],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: _buildMenuBar(context, _pageController),
              ),
              Expanded(
                flex: 2,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) {
                    if (i == 0) {
                      setState(() {
                        right = Colors.white;
                        left = Colors.black;
                        saveFabVisibility = true;
                      });
                    } else if (i == 1) {
                      setState(() {
                        right = Colors.black;
                        left = Colors.white;
                        saveFabVisibility = false;
                      });
                    }
                  },
                  children: <Widget>[
                    new ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: _buildDetailsPage(context),
                    ),
                    new ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: _buildPhotosPage(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPage(BuildContext context) {
    return Container(
        child: ListView(
      children: <Widget>[
        textfieldWidget(context, c1, parseStrings(data.stock_num), icons[0],
            fieldLabels[0]),
        textfieldWidget(context, c2, parseStrings(data.price.toString()),
            icons[1], fieldLabels[1]),
        textfieldWidget(context, c3, parseStrings(data.cost_price.toString()),
            icons[2], fieldLabels[2]),
        textfieldWidget(context, c4, parseStrings(data.year.toString()),
            icons[3], fieldLabels[3]),
        textfieldWidget(context, c5, parseStrings(data.mileage.toString()),
            icons[4], fieldLabels[4]),
        toggleWidget(context),
        textfieldWidget(
            context, c6, parseColor(data.colour), icons[6], fieldLabels[6]),
        textfieldWidget(
            context, c7, parseStrings(data.vin), icons[7], fieldLabels[7]),
        textfieldWidget(
            context, c8, parseStrings(data.regNo), icons[8], fieldLabels[8]),
      ],
    ));
  }

  Widget _buildPhotosPage(BuildContext context) {
    return Stack(
      children: <Widget>[
        Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: new ListView.builder(
                  shrinkWrap: true,
                  itemCount: globals.img_provider_photos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        elevation: 3.0,
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image(
                                image: globals.img_provider_photos[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                    padding:
                                        EdgeInsets.only(top: 5.0, right: 5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showDeleteAlertDialog(
                                              context,
                                              globals.stock_details
                                                  .photos[index].id,
                                              index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          ],
                        ));
                  }),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            takePhotoCard(context),
          ],
        )
      ],
    );
  }

  Widget takePhotoCard(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () async {
          print("show camera");

          // Ensure that plugin services are initialized so that `availableCameras()`
          // can be called before `runApp()`
          WidgetsFlutterBinding.ensureInitialized();

          // Obtain a list of the available cameras on the device.
          final cameras = await availableCameras();

          // Get a specific camera from the list of available cameras.
          final firstCamera = cameras.first;

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Viewfinder(
                      camera: firstCamera,
                    )),
          );
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  )
                ]),
            child: Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.add_circle),
                  ),
                  Text("Take a Picture"),
                ],
              ),
            )),
      ),
    );
  }

  showDeleteAlertDialog(BuildContext context, int photo_id, int index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          //color: Colors.black
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continue",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          //color: Colors.black
        ),
      ),
      onPressed: () {
        deleteImg(photo_id, index);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Delete"),
      content: Text("Are you sure you want to delete this image?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteImg(int photo_id, int index) {
    print("Deleting img: " + photo_id.toString());
    var token = "Bearer " + globals.token;
    var url = globals.delete_img + photo_id.toString();
    print("URL: " + url);
    http.get(
      url,
      headers: <String, String>{
        'Authorization': token,
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((http.Response response) {
      print(response.body + "\nCode: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        print("Deleting image from RAM...");
        setState(() {
          globals.img_provider_photos.removeAt(index);
          photos = globals.img_provider_photos;
          GetStockDataDetails details = new GetStockDataDetails();
          details.updateStockDetails();
        });
      }
    });
  }

  void galleryPageChanged() {
    print("page changed");
  }

  Widget saveFAB() {
    return Container(
      child: FloatingActionButton(
          heroTag: "saveFAB",
          child: Icon(
            Icons.save,
            color: Colors.amber,
            size: 27,
          ),
          backgroundColor: Colors.white,
          elevation: 7.0,
          onPressed: () async {
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              //duration: new Duration(seconds: 5),
              content: new Row(
                children: <Widget>[
                  new CircularProgressIndicator(),
                  new Text("  Saving")
                ],
              ),
            ));
            print("clicked");
          }),
    );
  }

  Widget cameraFAB() {
    return Container(
      child: FloatingActionButton(
        heroTag: "cameraFAB",
        elevation: 7.0,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.camera_alt,
          color: Colors.amber,
          size: 27,
        ),
        onPressed: () async {
          print("show camera");

          // Ensure that plugin services are initialized so that `availableCameras()`
          // can be called before `runApp()`
          WidgetsFlutterBinding.ensureInitialized();

          // Obtain a list of the available cameras on the device.
          final cameras = await availableCameras();

          // Get a specific camera from the list of available cameras.
          final firstCamera = cameras.first;

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Viewfinder(
                      camera: firstCamera,
                    )),
          );
        },
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context, PageController _pageController) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _onDetailsButtonPress(_pageController);
                },
                child: Text(
                  "Details",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _onPhotosButtonPress(_pageController);
                },
                child: Text(
                  "Photos",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetailsButtonPress(PageController _pageController) {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onPhotosButtonPress(PageController _pageController) {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Widget toggleWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 12.0, left: 20.0, right: 20.0),
        child: Container(
            decoration: BoxDecoration(
                color: Color(0xffebebeb),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  )
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 15, left: 15.0, right: 10.0, bottom: 15.0),
                      child: Icon(
                        Icons.book,
                        color: Colors.grey[600],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        "Published",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0),
                  child: CupertinoSwitch(
                    value: published,
                    onChanged: (bool value) {
                      setState(() {
                        published = value;
                      });
                      print("Toggle published changed: " + value.toString());
                    },
                  ),
                )
              ],
            )));
  }

  Widget textfieldWidget(BuildContext context, TextEditingController controller,
      String text, IconData icon, String title) {
    controller.text = text;
    return Padding(
        padding: EdgeInsets.only(top: 12.0, left: 20.0, right: 20.0),
        child: Container(
            decoration: BoxDecoration(
                color: Color(0xffebebeb),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  )
                ]),
            child: Theme(
              child: TextField(
                controller: controller,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  //hintText: text,
                  labelText: title,
                  prefixIcon: Icon(icon),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            )));
  }
}
