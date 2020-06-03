
class DealerStatsData{
  final DealerStatsModel data;

  DealerStatsData({this.data});

  factory DealerStatsData.fromJson(Map<String, dynamic> parsedJson) {
    return DealerStatsData(
        data: DealerStatsModel.fromJson(parsedJson['data'])
    );
  }
}

class DealerStatsModel{
  final bool error;
  final List<Stats> stats;

  DealerStatsModel({this.error, this.stats});


  factory DealerStatsModel.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['stats'] as List;
    //print("List runtimetype: " + list.runtimeType.toString()); //Returns List<dynamic>
    List<Stats> statsList = list.map((e) => Stats.fromJson(e)).toList();


    return DealerStatsModel(
        error: parsedJson['error'],
        stats: statsList
    );
  }
}

class Stats{
  int state_id, type;
  String total;
  int count;


  Stats({this.state_id, this.type, this.count, this.total});

  factory Stats.fromJson(Map<String, dynamic> parsedJson) {
    return Stats(
      state_id: parsedJson['state_id'],
      type: parsedJson['type'],
      count: parsedJson['count'],
      total: parsedJson['total']
    );
  }
}
