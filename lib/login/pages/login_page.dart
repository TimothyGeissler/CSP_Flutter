import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_login_signup/dashboard/components/dealer_model.dart';
import 'package:flutter_login_signup/login/components/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login_signup/vars.dart' as globals;
import 'package:flutter_login_signup/dashboard/pages/dashboard.dart';
import 'package:flutter_login_signup/dashboard/components/dealer_stats_model.dart';
import 'package:flutter_login_signup/login/components/Color.dart' as colourMap;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final login_failed_snackbar = SnackBar(
    content: Text("Incorrect login details"),
    backgroundColor: Colors.white,
  );

  //Login logic
  Future<bool> loginUser(String username, String password) async {
    //print('Name: ${username}, Password: ${password}');
    String email = "tim.d.geissler@gmail.com", password = "carsalesportal15";
    var response = await http.post(
        globals.login,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        })
    );
    print(response.body + " : " + response.statusCode.toString());
    final jsonResponse = json.decode(response.body);
    try {
      Login login_model = new Login.fromJson(jsonResponse);
      print(login_model.error.toString() + ", " + login_model.user.email);
      globals.token = login_model.user.api_token;
      print('Token: ' + globals.token);
      return login_model.error;
    } catch (e) {
      return true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Center(
          child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xffffd500), Color(0xffff9900)])),
        child: Column(
          children: <Widget>[
            loginLogo(),
            loginForm(),
          ],
        ),
      )),
    );
  }

  Widget loginLogo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40.0),
          child: Icon(
            Icons.directions_car,
            color: Colors.white,
            size: 120,),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 40.0),
          child: Text(
            "CSP Mobile",
            style: TextStyle(
                fontSize: 50, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget loginForm() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0), color: Colors.white),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(
                    top: 20.0, bottom: 10.0, left: 20.0, right: 20.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffebebeb),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Theme(
                      child: TextField(
                        controller: emailController,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(
                            Icons.account_circle,
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
                      data:
                          Theme.of(context).copyWith(primaryColor: Colors.grey),
                    ))),
            Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffebebeb),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Theme(
                      child: TextField(
                        controller: passwordController,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(
                            Icons.lock,
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
                      data:
                          Theme.of(context).copyWith(primaryColor: Colors.grey),
                    ))),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xffffbb00), Color(0xffff9900)]),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        )
                      ]),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 45.0, right: 45.0),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                onTap: () async {
                  _scaffoldKey.currentState.showSnackBar(
                    new SnackBar(
                      //duration: new Duration(seconds: 5),
                      content: new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("  Signing In")
                        ],
                      ),
                    )
                  );
                  handleLogin();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleLogin() async {
    print("tapped");
    bool login_bool = await loginUser(emailController.text, passwordController.text);
    if (login_bool == false) {
      //can login
      print("login OK");
      //pre init data
      await getDealers();
      await getDealerStats();
      await getColourData();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      //login failed
      print("login failed");
    }
  }

  void getColourData() async {
    var token = "Bearer " + globals.token;
    var response = await http.get(
      globals.colourMap,
      headers: <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
    );
    print(response.body + " : " + response.statusCode.toString());
    final jsonResponse = json.decode(response.body);
    try {
      colourMap.ColourData colourData = new colourMap.ColourData.fromJson(jsonResponse);
      print("ColourData error? " + colourData.colourList.error.toString());
      globals.colourData = colourData;

    } catch (e) {
      print("Failed getting colour data");
    }
  }

  void getDealers() async {
    var token = "Bearer " + globals.token;
    var response = await http.get(
      globals.getDealers,
      headers: <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
    );
    print(response.body + " : " + response.statusCode.toString());
    final jsonResponse = json.decode(response.body);
    try {
      DealerData dealers = new DealerData.fromJson(jsonResponse);
      print(dealers.data.error.toString());
      globals.dealer_model = dealers.data;

      // Get data for each dealership
      //getDealerData();
    } catch (e) {
      print("Failed getting dealers");
    }
  }

  void getDealerStats() async {
    var token = "Bearer " + globals.token;

    for (int i = 0; i < globals.dealer_model.dealers.length; i++) {
      var response = await http.get(
        globals.getDealerData + globals.dealer_model.dealers[i].id.toString(),
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
      );
      print(response.body + " : " + response.statusCode.toString());
      final jsonResponse = json.decode(response.body);
      try{
        DealerStatsData dealerStatsData = new DealerStatsData.fromJson(jsonResponse);
        print(dealerStatsData.data.error.toString() + ", " + dealerStatsData.data.stats[0].total.toString());
        //dealer_stats_data_list[i] = dealerStatsData;
        globals.stats_list.add(dealerStatsData.data);
      } catch (e) {
        print("Failed getting dealer stats");
      }
    }
  }

}
