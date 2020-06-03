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

    cleanData();

    super.initState();
  }

  cleanData() {
    for (int i = 0; i < dealer_model.dealers.length; i++) {
      try {
        print("Valid: " + stats_list[i].stats[1].total.toString());
      } catch (e) {
        print("Missing data: " + i.toString() + " -- Repairing...");
        stats_list[i].stats.add(new Stats(count: 0, total: "R0"));
      }
    }
  }

  String getDealerStat(int dealer_no, int stat_pos, String data) {
    //data = count or total
    try {
      if (data == 'count') {
        return stats_list[dealer_no].stats[stat_pos].count.toString();
      } else {
        return stats_list[dealer_no].stats[stat_pos].total.toString();
      }
    } catch (e) {
      if (data == 'count') {
        return "0";
      } else {
        return "R0";
      }
    }
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
            //Navigate to stock page
          }),
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
    final GlobalKey<AnimatedCircularChartState> _chartKey =
        new GlobalKey<AnimatedCircularChartState>();
    final GlobalKey<AnimatedCircularChartState> _chartKey2 =
        new GlobalKey<AnimatedCircularChartState>();
    return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Container(
          child: Column(
            children: <Widget>[
              /*Padding(
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
              ),*/
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
                                padding:
                                    EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Listed",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      getDealerStat(position, 1, 'count'),
                                      style: TextStyle(
                                          color: Colors.green[400],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    Text(
                                      getDealerStat(position, 1, 'total'),
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
                                        double.tryParse(getDealerStat(position, 0, 'count')),
                                          Colors.red[400],
                                          rankKey: 'Unpublished'),
                                      new CircularSegmentEntry(
                                        double.tryParse(getDealerStat(position, 1, 'count')),
                                          Colors.green[400],
                                          rankKey: 'Published'),
                                    ],
                                    rankKey: 'Published cars',
                                  ),
                                ],
                                chartType: CircularChartType.Pie,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Unlisted",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      getDealerStat(position, 0, 'count'),
                                      style: TextStyle(
                                          color: Colors.red[400],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    Text(
                                      getDealerStat(position, 0, 'total'),
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
                    )),
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
                                    getDealerStat(position, 3, 'count'),
                                    style: TextStyle(
                                        color: Colors.green[400],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24),
                                  ),
                                  Text(
                                    getDealerStat(position, 3, 'total'),
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
                                      double.tryParse(getDealerStat(position, 2, 'count')),
                                        Colors.red[400],
                                        rankKey: 'Unpublished'),
                                    new CircularSegmentEntry(
                                      double.tryParse(getDealerStat(position, 3, 'count')),
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
                                    getDealerStat(position, 2, 'count'),
                                    style: TextStyle(
                                        color: Colors.red[400],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24),
                                  ),
                                  Text(
                                    getDealerStat(position, 2, 'total'),
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
                  )),
            ],
          ),
        ));
  }
}
