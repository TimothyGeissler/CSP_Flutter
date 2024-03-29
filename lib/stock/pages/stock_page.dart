import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_signup/login/components/login_model.dart';
import 'package:flutter_login_signup/stock/components/get_stock_details.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login_signup/vars.dart' as globals;
import 'package:flutter_login_signup/dashboard/components/dealer_model.dart';
import 'package:flutter_login_signup/dashboard/components/dealer_stats_model.dart';
import 'package:flutter_login_signup/dashboard/components/pie_chart.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart';
import 'package:flutter_login_signup/stock/pages/bubble_indicator_painter.dart';
import 'package:flutter_login_signup/details/pages/details_page.dart';
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart' as stock;
import 'package:flutter_login_signup/dashboard/pages/dashboard.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  DealerModel dealer_model = new DealerModel();

  List<DealerStatsModel> stats_list = new List();
  List<StockData> stockData = new List();
  List<ImageProvider> photos = new List();

  ScrollController scrollController = ScrollController(initialScrollOffset: 0.0);

  Color left = Colors.black;
  Color right = Colors.white;
  //PageController _pageController;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    //_pageController = PageController();
    // Display data

    setState(() {
      dealer_model = globals.dealer_model;
      stockData = globals.stock_data;
      //get stats
      //stockData = getStockData();
    });


    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
          child: Icon(
            Icons.arrow_back,  // add custom icons also
          ),
        ),
      ),
      body: Center(
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xffffd500), Color(0xffff9900)])),
              child: Container(
                  child: Column(
                //crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 20.0, bottom: 0.0),
                        child: Text(
                          dealer_model.dealers[globals.dealer_stock_no].name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: doublePage(context),
                  ),
                ],
              )))),
    );
  }

  Widget _buildPage(int dealerNo) {
    return Container(
        child: Column(
      //crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0, left: 20.0, bottom: 10.0),
              child: Text(
                dealer_model.dealers[dealerNo].name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        Container(
          child: doublePage(context),
        ),
      ],
    ));
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
          height: MediaQuery.of(context).size.height - 157,
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
                padding: EdgeInsets.only(top: 20.0),
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
                      });
                    } else if (i == 1) {
                      setState(() {
                        right = Colors.black;
                        left = Colors.white;
                      });
                    }
                  },
                  children: <Widget>[
                    new ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: _buildUnpublishedPage(context),
                    ),
                    new ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: _buildPublishedPage(context),
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

  Widget _buildUnpublishedPage(BuildContext context) {
    return Container(
      child: _listBuilder(context, stockData[0].data.stocks, 0),
    );
  }

  Widget _buildPublishedPage(BuildContext context) {
    return Container(
      child: _listBuilder(context, stockData[1].data.stocks, 1),
    );
  }

  String parseTrim(String trim) {
    String result =
        trim.substring(trim.indexOf('-') + 2, trim.lastIndexOf("("));
    return result;
  }

  String parsePrice(int price) {
    if (price == null) {
      return "N/A";
    } else {
      String text = price.toString();
      String result = "";
      int len = text.length;
      for (int i = 1; i <= len; i++) {
        result = text[len - i] + result;
        if (i % 3 == 0) {
          result = "," + result;
        }
      }
      if (result[0] == ",") {
        result = result.substring(1, result.length);
      }
      return "R" + result;
    }
  }

  Image thumbnailFetcher(List<Stocks> data, int index) {
    try {
      String directory = data[index].photos[0].directory,
          filename = data[index].photos[0].photo;

      var token = "Bearer " + globals.token;
      print("Getting thumbnail: " + filename);
      String url = globals.base_img_url;
      String thumbnail_request = url + directory + "thumb-" + filename;
      Image thumbnail = Image.network(
        thumbnail_request,
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        height: 120,
        width: 120,
        fit: BoxFit.cover,
      );
      return thumbnail;
    } catch (e) {
      return Image(
        image: AssetImage(
          'assets/images/car_icon.png',
        ),
        height: 120,
        width: 120,
      );
    }
  }

  Widget _listBuilder(BuildContext context, List<Stocks> data, int dataIndex1) {
    if (data.length == 0) {
      return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
                color: Colors.white,
                /*boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  )
                ]*/
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 15.0, right: 15.0),
              child: Text(
                "No cars found",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20.0
                ),
              ),
            )
          )
        ),
      );
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Scrollbar(
            child: new ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new GestureDetector(
                    onTap: () {
                      print("Card: " + index.toString() + " clicked\nOpening details window...");
                      globals.stock_data_indices.clear();
                      globals.stock_data_indices.add(dataIndex1);
                      globals.stock_data_indices.add(index);
                      globals.stock_details = data[index];
                      //globals.photos = data[index].photos;
                      GetStockDataDetails details = new GetStockDataDetails();
                      globals.img_provider_photos = details.loadImages(data[index].photos);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Detail()),
                      );
                    },
                    child: Card(
                      elevation: 3.0,
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: thumbnailFetcher(data, index),
                          ),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                                      child: Text(
                                        parseTrim(data[index].trim),
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 0.0),
                                      child:
                                      Text("Stock No: " + data[index].stock_num),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Text(
                                              "Year: " + data[index].year.toString()),
                                        ),
                                        Text("Mileage: " +
                                            data[index].mileage.toString() +
                                            "km"),
                                      ],
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 10.0, right: 20.0, top: 5.0),
                                        child: Text(
                                          "Price: " + parsePrice(data[index].price),
                                          style: TextStyle(
                                              color: Colors.green[400],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18),
                                        ))
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ));
    }
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
                  _onUnpublishedButtonPress(_pageController);
                },
                child: Text(
                  "Unpublished",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _onPublishedButtonPress(_pageController);
                },
                child: Text(
                  "Published",
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

  void _onUnpublishedButtonPress(PageController _pageController) {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onPublishedButtonPress(PageController _pageController) {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }
}
