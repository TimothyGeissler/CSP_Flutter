import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:async';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_login_signup/login/components/login_model.dart';
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

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
    "Stock No.", "Price (R)", "Cost Price (R)", "Year", "Mileage (km)", "Published",
    "Colour", "VIN", "Reg. No."]);
  List<IconData> icons = new List.unmodifiable([Icons.format_list_numbered,
    Icons.attach_money, Icons.monetization_on, Icons.calendar_today,
    Icons.timeline, Icons.book, Icons.color_lens, Icons.directions_car,
    Icons.info_outline]);

  Stocks data;

  List<String> hint_texts = new List();

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  void initState() {
    setState(() {
      data = globals.stock_details;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollHeader();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scrollHeader() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 5000), curve: Curves.ease);
    Timer(Duration(milliseconds: 7000), () {
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 5000), curve: Curves.ease);
    });
  }

  void fillLists() {
    hint_texts.add(data.stock_num);
    hint_texts.add(data.price.toString());
    hint_texts.add(data.cost_price.toString());
    hint_texts.add(data.year.toString());
    hint_texts.add(data.mileage.toString());
    hint_texts.add(data.state.toString());
    hint_texts.add(data.colour.toString());
    hint_texts.add(data.vin);
    hint_texts.add(data.regNo);
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
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xffffd500), Color(0xffff9900)])),
              child: Column(
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
                  )
                ],
              ))),
    );
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
          height: MediaQuery.of(context).size.height >= 775.0
              ? MediaQuery.of(context).size.height
              : 589.0,
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
        textfieldWidget(context, c1, data.stock_num, icons[0], fieldLabels[0]),
        textfieldWidget(context, c2, data.price.toString(), icons[1], fieldLabels[1]),
        textfieldWidget(context, c3, data.cost_price.toString(), icons[2], fieldLabels[2]),
        textfieldWidget(context, c4, data.year.toString(), icons[3], fieldLabels[3]),
        textfieldWidget(context, c5, data.mileage.toString(), icons[4], fieldLabels[4]),
        textfieldWidget(context, c6, data.state.toString(), icons[5], fieldLabels[5]),
        textfieldWidget(context, c7, data.colour.toString(), icons[6], fieldLabels[6]),
        textfieldWidget(context, c8, data.vin, icons[7], fieldLabels[7]),
        textfieldWidget(context, c9, data.regNo, icons[8], fieldLabels[8]),
      ],
    ));
  }

  Widget _buildPhotosPage(BuildContext context) {
    return Container(
      child: Text("Photos"),
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

  Widget textfieldWidget(BuildContext context, TextEditingController controller,
      String text, IconData icon, String title) {
    controller.text = text;
    return Padding(
        padding: EdgeInsets.only(
            top: 12.0, left: 20.0, right: 20.0),
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
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
              ),
              data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            )));
  }
}
