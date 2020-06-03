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

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {

  List<CarDetail> cars = new List();

  @override
  void initState() {
    cars.add(new CarDetail());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CSP Mobile",
          style: TextStyle(
              fontSize: 27.0
          ),
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
              child: new ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Text("B");
                  }
              )
          )
      ),
    );
  }
}