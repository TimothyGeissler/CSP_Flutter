
class DealerData{
  final DealerModel data;

  DealerData({this.data});

  factory DealerData.fromJson(Map<String, dynamic> parsedJson) {
    return DealerData(
      data: DealerModel.fromJson(parsedJson['data'])
    );
  }
}

class DealerModel{
  final bool error;
  final List<Dealer> dealers;

  DealerModel({this.error, this.dealers});


  factory DealerModel.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['dealers'] as List;
    //print("List runtimetype: " + list.runtimeType.toString()); //Returns List<dynamic>
    List<Dealer> dealersList = list.map((e) => Dealer.fromJson(e)).toList();


    return DealerModel(
        error: parsedJson['error'],
        dealers: dealersList
    );
  }
}

class Dealer{
  final int id;
  final String name;

  Dealer({this.id, this.name});

  factory Dealer.fromJson(Map<String, dynamic> parsedJson) {
    return Dealer(
        id: parsedJson['id'],
        name: parsedJson['name']
    );
  }
}
