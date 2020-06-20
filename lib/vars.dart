library csp.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dashboard/components/dealer_model.dart';
import 'dashboard/components/dealer_stats_model.dart';
import 'stock/components/dealerstock_model.dart' as stock;
import 'package:flutter_login_signup/login/components/Color.dart' as colorMap;

final String login = "https://truth.carsalesportal.co.za/api/login";
final String getDealers = "https://truth.carsalesportal.co.za/api/dealers";
final String getDealerData = "https://truth.carsalesportal.co.za/api/dealerstats/";
final String getDealerStock = "https://truth.carsalesportal.co.za/api/dealerstock/"; // <dealer_id>/<state_id>
final String base_img_url = "https://truth.carsalesportal.co.za/cdn";// <directory> + (thumb-) + <photo>
final String colourMap = "https://truth.carsalesportal.co.za/api/colours";
final String upload_img = "https://truth.carsalesportal.co.za/api/photo/upload/"; //<stock_id>
final String delete_img = "https://truth.carsalesportal.co.za/api/photo/remove/"; // <photo_id>
final String update_stock_details = "https://truth.carsalesportal.co.za/api/stock/update/"; // <stock_id>

String token;
DealerModel dealer_model = new DealerModel();
List<Dealer> dealers_list = new List();
List<DealerStatsModel> stats_list = new List();
List<stock.StockData> stock_data = new List();
List<stock.Photo> photos = new List();
List<ImageProvider> img_provider_photos = new List();


colorMap.ColourData colourData;
String dealer_name;
int dealer_stock_no;
stock.Stocks stock_details; //parsed to Details
String image_captured;

List<int> stock_data_indices = new List();