import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

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
import 'package:flutter_login_signup/stock/components/get_stock_data.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  dealer.DealerModel dealer_model = new dealer.DealerModel();
  List<dealer.Dealer> dealers_list = new List();
  List<DealerStatsModel> stats_list = new List();

  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0);

  int pageNo = 0;
  PageController _pageController = new PageController();

  @override
  void initState() {
    // Display data

    setState(() {
      dealer_model = globals.dealer_model;
      dealers_list = globals.dealers_list;
      stats_list = globals.stats_list;
    });

    _pageController.addListener(() {
      pageNo = _pageController.page.toInt();
      //print("Current page: " + pageNo.toString());
    });

    super.initState();
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
    _pageController.dispose();
    super.dispose();
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
              child: PageView.builder(
                controller: _pageController,
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
          onPressed: () async {
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              //duration: new Duration(seconds: 5),
              content: new Row(
                children: <Widget>[
                  new CircularProgressIndicator(),
                  new Text("  Fetching Stock")
                ],
              ),
            ));
            globals.dealer_stock_no = pageNo;
            //get required stock data
            GetStockData gsd = new GetStockData();
            globals.stock_data = await gsd.getStockData();
            //Navigate to stock page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StockPage()),
            );
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 10.0),
                child: Text(
                  dealer_model.dealers[position].name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        dashboardItems(position),
      ],
    ));
  }

  void loadStock() async {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      //duration: new Duration(seconds: 5),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("  Fetching Stock")
        ],
      ),
    ));
    globals.dealer_stock_no = pageNo;
    //get required stock data
    GetStockData gsd = new GetStockData();
    globals.stock_data = await gsd.getStockData();
    //Navigate to stock page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockPage()),
    );
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
              Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      print('used cars tapped');
                      loadStock();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: dashboardCard(_chartKey, "Used Cars", 1, 0, position)
                    )
                  )),
              GestureDetector(
                onTap: () {
                  loadStock();
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  child: dashboardCard(_chartKey2, "Demo Cars", 3, 2, position)
                ),
              )
            ],
          ),
        ));
  }

  Widget dashboardCard(Key _chartKey, String title, int greenStatNo, int redStatNo, int position) {
    if (getDealerStat(position, greenStatNo, 'count') == "0" && getDealerStat(position, redStatNo, 'count') == "0") {
      //no info
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26)
        ),
        elevation: 10.0,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
                child: Text(
                  "No Cars Listed",
                  style: TextStyle(
                    fontSize: 18.0
                  ),
                ),
              )
            ],
          )
        ),
      );
    } else {
      return Card(
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
                    title,
                    style: TextStyle(
                        fontSize: 23.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Listed",
                            style: TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            getDealerStat(position, greenStatNo, 'count'),
                            style: TextStyle(
                                color: Colors.green[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 24),
                          ),
                          Text(
                            getDealerStat(position, greenStatNo, 'total'),
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
                                double.tryParse(getDealerStat(
                                    position, redStatNo, 'count')),
                                Colors.red[400],
                                rankKey: 'Unpublished'),
                            new CircularSegmentEntry(
                                double.tryParse(getDealerStat(
                                    position, greenStatNo, 'count')),
                                Colors.green[400],
                                rankKey: 'Published'),
                          ],
                          rankKey: 'Published cars',
                        ),
                      ],
                      chartType: CircularChartType.Pie,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Unlisted",
                            style: TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            getDealerStat(position, redStatNo, 'count'),
                            style: TextStyle(
                                color: Colors.red[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 24),
                          ),
                          Text(
                            getDealerStat(position, redStatNo, 'total'),
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
          ));
    }
  }
}
