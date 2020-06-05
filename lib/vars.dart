library csp.globals;

import 'dashboard/components/dealer_model.dart';
import 'dashboard/components/dealer_stats_model.dart';
import 'stock/components/dealerstock_model.dart' as stock;

final String login = "https://truth.carsalesportal.co.za/api/login";
final String getDealers = "https://truth.carsalesportal.co.za/api/dealers";
final String getDealerData = "https://truth.carsalesportal.co.za/api/dealerstats/";
final String getDealerStock = "https://truth.carsalesportal.co.za/api/dealerstock/"; // <dealer_id>/<state_id>

String token;
DealerModel dealer_model = new DealerModel();
List<Dealer> dealers_list = new List();
List<DealerStatsModel> stats_list = new List();
List<stock.StockData> stock_data = new List();

String dealer_name;
int dealer_stock_no;