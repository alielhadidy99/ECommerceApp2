import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Counters/itemQuantity.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/authenication.dart';

import 'Counters/cartitemcounter.dart';
import 'Counters/changeAddresss.dart';
import 'Counters/totalMoney.dart';
import 'Store/storehome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EcommerceApp.auth = FirebaseAuth.instance;
  EcommerceApp.sharedPreferences = await SharedPreferences.getInstance();
  EcommerceApp.firestore = Firestore.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => CartItemCounter(),
        ),
        ChangeNotifierProvider(
          create: (c) => ItemQuantity(),
        ),
        ChangeNotifierProvider(
          create: (c) => AddressChanger(),
        ),
        ChangeNotifierProvider(
          create: (c) => TotalAmount(),
        ),
      ],
      child: MaterialApp(

        title: 'E-Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    displaySplash();
    super.initState();
  }

  displaySplash() {
    Timer(Duration(seconds: 2), () async {
      if (await EcommerceApp.auth.currentUser() != null) {
        Route route = MaterialPageRoute(builder: (context) => StoreHome());
        Navigator.pushReplacement(context, route);
      } else {
        Route route =
            MaterialPageRoute(builder: (context) => AuthenticScreen());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.grey,
            ],
            begin: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/welcome.png"),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "World's Largest & Number One Online",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
