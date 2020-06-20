import 'dart:convert';

import 'package:flutter_login_signup/vars.dart' as globals;
import 'package:http/http.dart' as http;

import 'dealerstock_model.dart';

class GetStockData {

  Future<List<StockData>> getStockData() async {
    List<StockData> result = new List();
    for (int i = 1; i <= 2; i++) {
      await loadDetails(globals.dealer_model.dealers[globals.dealer_stock_no].id, i)
          .then((value) {
        result.add(value);
      });
    }
    return result;
  }

  Future<StockData> loadDetails(int dealer_id, int state_id) async {
    //state_id 1 = unpublished, 2 = published
    var token = "Bearer " + globals.token;
    var url = globals.getDealerStock +
        dealer_id.toString() +
        "/" +
        state_id.toString();
    print("Getting stock details @ " + url);
    var response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
    );
    print(response.body);
    print(response.statusCode.toString());
    final jsonResponse = json.decode(response.body);
    try {
      StockData stockData = new StockData.fromJson(jsonResponse);
      print(stockData.data.error.toString());
      return stockData;
    } catch (e) {
      print("Failed getting dealerstock");
      return null;
    }
  }

}