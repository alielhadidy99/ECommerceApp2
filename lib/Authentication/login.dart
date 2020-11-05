import 'package:ecommerceapp/Admin/adminLogin.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/DialogBox/errorDialog.dart';
import 'package:ecommerceapp/DialogBox/loadingDialog.dart';
import 'package:ecommerceapp/Widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'images/login.png',
                height: 240,
                width: 240,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Login to your account',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    data: Icons.email,
                    isObsecure: false,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    hintText: 'Password',
                    controller: _passwordController,
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                _emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty
                    ? loginUser()
                    : showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message: 'Please write email and password',
                          );
                        });
              },
              color: Colors.black,
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.black26,
            ),
            SizedBox(
              height: 10.0,
            ),
            FlatButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminSignInPage(),
                ),
              ),
              icon: (Icon(
                Icons.nature_people,
                color: Colors.black,
              )),
              label: Text(
                "i'm Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loginUser() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
            message: "Authentication, Please wait...",
          );
        });
    FirebaseUser firebaseUser;
    await _auth
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .then((value) {
      firebaseUser = value.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });
    if (firebaseUser != null) {
      readData(firebaseUser).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future readData(FirebaseUser firebaseUser) async {
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .get()
        .then((value) async {
      await EcommerceApp.sharedPreferences
          .setString('uid', value.data[EcommerceApp.userUID]);
      await EcommerceApp.sharedPreferences.setString(
          EcommerceApp.userEmail, value.data[EcommerceApp.userEmail]);
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userName, value.data[EcommerceApp.userName]);
      await EcommerceApp.sharedPreferences.setString(
          EcommerceApp.userAvatarUrl, value.data[EcommerceApp.userAvatarUrl]);
      List<String> cartList =
          value.data[EcommerceApp.userCartList].cast<String>();
      await EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, cartList);
    });
  }
}
