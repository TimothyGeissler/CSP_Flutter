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

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DealerModel dealer_model = new DealerModel();
  List<Dealer> dealers_list = new List();
  List<DealerStatsModel> stats_list = new List();

  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    // Display data

    setState(() {
      dealer_model = globals.dealer_model;
      dealers_list = globals.dealers_list;
      stats_list = globals.stats_list;
    });
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  /*void dioGetDealers() async {
    var token = "Bearer " + globals.token;

    Dio dio = new Dio();
    dio.options.headers['Content-Type'] = 'application/json; charset=UTF-8';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Authorization'] = token;
    Response response = await dio.get("https://truth.carsalesportal.co.za/api/dealers");
    //print(response.statusCode.toString());
    final jsonResponse = json.decode(response.data);
    try {
      DealerData dealers = new DealerData.fromJson(jsonResponse);
      print(dealers.data.error.toString());
    } catch (e) {
      print("Failed getting dealers");
    }
  }*/
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
              child: PageView.builder(
                itemBuilder: (context, position) {
                  return _buildPage(position);
                },
                itemCount: dealer_model.dealers.length, // Can be null
              ))),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(
          Icons.search,
          color: Colors.amber,
          size: 30,
        ),
        label: Text("Stock"),
        backgroundColor: Colors.white,
        elevation: 20.0,
        onPressed: () {
          Navigator.pop(context);
        }
      ),
    );
  }


  Widget _buildPage(int position) {
    return Container(
        child: Column(
      //crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 10.0),
              child: Text(
                dealer_model.dealers[position].name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        dashboardItems(position),
      ],
    ));
  }

  Widget dashboardItems(int position) {
    final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
    final GlobalKey<AnimatedCircularChartState> _chartKey2 = new GlobalKey<AnimatedCircularChartState>();
    return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 20.0, left: 30.0, right: 30.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Theme(
                        child: Material(
                          elevation: 10.0,
                          shadowColor: Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(26),
                          child: TextField(
                            controller: searchController,
                            cursorColor: Colors.amber,
                            decoration: InputDecoration(
                              hintText: "Search stock",
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 10.0),
                            ),
                          ),
                        ),
                        data:
                        Theme.of(context).copyWith(primaryColor: Colors.grey),
                      )
                  )
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                    elevation: 10.0,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Text(
                              "Used Cars",
                              style: TextStyle(
                                  fontSize: 23.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Listed",
                                      style:
                                      TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      stats_list[position].stats[1].count.toString(),
                                      style: TextStyle(
                                          color: Colors.green[400],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    Text(
                                      stats_list[position].stats[1].total.toString(),
                                      style: TextStyle(
                                          color: Colors.green[400],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                              AnimatedCircularChart(
                                key: _chartKey,
                                size: const Size(100.0, 100.0),
                                initialChartData: <CircularStackEntry>[
                                  new CircularStackEntry(
                                    <CircularSegmentEntry>[
                                      new CircularSegmentEntry(
                                          stats_list[position].stats[0].count.toDouble(),
                                          Colors.red[400],
                                          rankKey: 'Unpublished'),
                                      new CircularSegmentEntry(
                                          stats_list[position].stats[1].count.toDouble(),
                                          Colors.green[400],
                                          rankKey: 'Published'),
                                    ],
                                    rankKey: 'Published cars',
                                  ),
                                ],
                                chartType: CircularChartType.Pie,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Unlisted",
                                      style:
                                      TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      stats_list[position]
                                          .stats[0]
                                          .count
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.red[400],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    Text(
                                      stats_list[position]
                                          .stats[0]
                                          .total
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.red[400],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                ),
              ),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 10.0,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Text(
                            "Demo Cars",
                            style: TextStyle(
                                fontSize: 23.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0, right: 15.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Listed",
                                    style:
                                    TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    stats_list[position].stats[3].count.toString(),
                                    style: TextStyle(
                                        color: Colors.green[400],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24),
                                  ),
                                  Text(
                                    stats_list[position]
                                        .stats[3]
                                        .total
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.green[400],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                            AnimatedCircularChart(
                              key: _chartKey2,
                              size: const Size(100.0, 100.0),
                              initialChartData: <CircularStackEntry>[
                                new CircularStackEntry(
                                  <CircularSegmentEntry>[
                                    new CircularSegmentEntry(
                                        stats_list[position].stats[2].count.toDouble(),
                                        Colors.red[400],
                                        rankKey: 'Unpublished'),
                                    new CircularSegmentEntry(
                                        stats_list[position].stats[3].count.toDouble(),
                                        Colors.green[400],
                                        rankKey: 'Published'),
                                  ],
                                  rankKey: 'Published cars',
                                ),
                              ],
                              chartType: CircularChartType.Pie,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0, right: 15.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Unlisted",
                                    style:
                                    TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    stats_list[position]
                                        .stats[2]
                                        .count
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.red[400],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24),
                                  ),
                                  Text(
                                    stats_list[position]
                                        .stats[2]
                                        .total
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.red[400],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
              ),
            ],
          ),
        ));
  }
}
