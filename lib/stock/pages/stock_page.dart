import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_login_signup/login/components/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login_signup/vars.dart' as globals;
import 'package:flutter_login_signup/dashboard/components/dealer_model.dart';
import 'package:flutter_login_signup/dashboard/components/dealer_stats_model.dart';
import 'package:flutter_login_signup/dashboard/components/pie_chart.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_login_signup/stock/components/CarDetail.dart';
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart';
import 'package:flutter_login_signup/stock/pages/bubble_indicator_painter.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<CarDetail> cars = new List();

  DealerModel dealer_model = new DealerModel();

  List<DealerStatsModel> stats_list = new List();
  List<StockData> stockData = new List();

  Color left = Colors.black;
  Color right = Colors.white;
  //PageController _pageController;

  @override
  void initState() {
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
    //Controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("CSP Mobile", style: TextStyle(fontSize: 27.0),), backgroundColor: Colors.white,),
      resizeToAvoidBottomInset: false,
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
                            padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 0.0),
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
                  ))
          )
      ),
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
          height: MediaQuery.of(context).size.height >= 775.0 ? MediaQuery.of(context).size.height : 589.0,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.transparent, Colors.transparent],//[Color(0xffffd500), Color(0xffff9900)],
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
      child: _listBuilder(context, stockData[0].data.stocks),
    );
  }

  Widget _buildPublishedPage(BuildContext context) {
    return Container(
      child: _listBuilder(context, stockData[1].data.stocks),
    );
  }

  Widget _listBuilder(BuildContext context, List<Stocks> data) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: new ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              elevation: 3.0,
              child: Text(data[index].id.toString()),
            );
          }
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
                  _onSignInButtonPress(_pageController);
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
                onPressed:() {
                  _onSignUpButtonPress(_pageController);
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

  void _onSignInButtonPress(PageController _pageController) {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress(PageController _pageController) {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }
}

