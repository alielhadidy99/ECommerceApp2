import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Counters/cartitemcounter.dart';
import 'package:ecommerceapp/Store/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;
  MyAppBar({this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Colors.black,
              Colors.grey,
            ],
            begin: const FractionalOffset(1.0, 0.0),
            end: const FractionalOffset(0.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      title: Text(
        "E-Shop",
        style: TextStyle(
            fontSize: 50.0, color: Colors.white, fontFamily: 'Signatra'),
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              padding: EdgeInsets.only(top: 8),
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (c) => CartPage());
                Navigator.pushReplacement(context, route);
              },
            ),
            Positioned(
              child: Stack(
                children: [
                  Icon(
                    Icons.brightness_1,
                    size: 20.0,
                    color: Colors.grey,
                  ),
                  Positioned(
                    top: 4.0,
                    bottom: 4.0,
                    left: 6.5,
                    child: Consumer<CartItemCounter>(
                      builder: (context, counter, _) {
                        return Text(
                          (EcommerceApp.sharedPreferences
                                      .getStringList(EcommerceApp.userCartList)
                                      .length -
                                  1)
                              .toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ],
      bottom:bottom,
    );
  }

  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}
