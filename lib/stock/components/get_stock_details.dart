import 'package:flutter/cupertino.dart';
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart';
import 'package:flutter_login_signup/stock/components/get_stock_data.dart';
import 'package:flutter_login_signup/vars.dart' as globals;
import 'package:flutter_login_signup/stock/components/dealerstock_model.dart' as stock;

class GetStockDataDetails {

  updateStockDetails() {
    GetStockData getStockData = new GetStockData();

    getStockData.getStockData().then((value) {
      globals.stock_details = value[globals.stock_data_indices[0]].data.stocks[globals.stock_data_indices[1]];
      globals.img_provider_photos = loadImages(globals.stock_details.photos);
    });
  }

  List<ImageProvider> loadImages(List<stock.Photo> data) {
    List<ImageProvider> images = new List();
    for (int i = 0; i < data.length; i++) {
      //print("Getting img: " + data[i].id.toString());
      images.add(imgFetcher(data, i));
    }
    return images;
  }

  ImageProvider imgFetcher(List<Photo> data, int index) {
    try {
      String directory = data[index].directory,
          filename = data[index].photo;

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
}