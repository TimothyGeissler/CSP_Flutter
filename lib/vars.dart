library csp.globals;

import 'dashboard/components/dealer_model.dart';
import 'dashboard/components/dealer_stats_model.dart';

final String login = "https://truth.carsalesportal.co.za/api/login";
final String getDealers = "https://truth.carsalesportal.co.za/api/dealers";
final String getDealerData = "https://truth.carsalesportal.co.za/api/dealerstats/";


String token;
DealerModel dealer_model = new DealerModel();
List<Dealer> dealers_list = new List();
List<DealerStatsModel> stats_list = new List();
