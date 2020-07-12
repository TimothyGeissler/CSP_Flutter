class StockData {
  final StockList data;

  StockData({this.data});

  factory StockData.fromJson(Map<String, dynamic> parsedJson) {
    //print("StockData factory...");
    return new StockData(
        data: StockList.fromJson(parsedJson['data'])
    );
  }
}

class StockList {
  final bool error;
  final List<Stocks> stocks;

  StockList({this.error, this.stocks});

  factory StockList.fromJson(Map<String, dynamic> parsedJson) {
    //print("StockList factory...");
    var list = parsedJson['stocks'] as List;
    List<Stocks> stocksList = list.map((e) => Stocks.fromJson(e)).toList();

    return StockList(
      error: parsedJson['error'],
      stocks: stocksList,
    );
  }
}

class Stocks {
  final bool error;
  final int id, mileage, year, price, cost_price, state, colour;
  final String trim, regNo, slug, make, stock_num, vin;
  final MotorGroup motorgroup;
  final Dealer dealer;
  final List<Photo> photos;

  Stocks({
    this.error,
    this.id,
    this.stock_num,
    this.mileage,
    this.year,
    this.price,
    this.cost_price,
    this.state,
    this.colour,
    this.vin,
    this.trim,
    this.regNo,
    this.slug,
    this.make,
    this.motorgroup,
    this.dealer,
    this.photos});

  factory Stocks.fromJson(Map<String, dynamic> parsedJson) {

    var list = parsedJson['photos'] as List;
    //print("Stocks factory...");
    List<Photo> photoList = list.map((e) => Photo.fromJson(e)).toList();
    //print("Photos List --len--: " + photoList.length.toString());

    return Stocks(
      error: parsedJson['error'],
      id: parsedJson['id'],
      stock_num: parsedJson['stock_num'],
      trim: parsedJson['trim'],
      mileage: parsedJson['mileage'],
      year: parsedJson['year'],
      price: parsedJson['price'],
      cost_price: parsedJson['cost_price'],
      state: parsedJson['state'],
      colour: parsedJson['colour'],
      regNo: parsedJson['regNo'],
      slug: parsedJson['slug'],
      vin: parsedJson['vin'],
      motorgroup: MotorGroup.fromJson(parsedJson['motorgroup']),
      dealer: Dealer.fromJson(parsedJson['dealer']),
      make: parsedJson['make'],
      photos: photoList,
    );
  }
}

class MotorGroup {
  final int id;
  final String name, slug;

  MotorGroup({this.id, this.name, this.slug});

  factory MotorGroup.fromJson(Map<String, dynamic> parsedJson) {
    //print("MotorGroup factory...");
    return MotorGroup(
        id: parsedJson['id'],
        name: parsedJson['name'],
        slug: parsedJson['slug']
    );
  }
}

class Dealer {
  final int id;
  final String name;

  Dealer({this.id, this.name});

  factory Dealer.fromJson(Map<String, dynamic> parsedJson) {
    //print("Dealer factory...");
    return Dealer(
        id: parsedJson['id'],
        name: parsedJson['name']
    );
  }
}

class Photo {
  final String directory, photo;
  final int id;

  Photo({this.directory, this.photo, this.id});

  factory Photo.fromJson(Map<String, dynamic> parsedJson) {
    //print("Photo factory... ID: " + parsedJson['id'].toString());
    return Photo(
        id: parsedJson['id'],
        directory: parsedJson['directory'],
        photo: parsedJson['photo']
    );
  }

}