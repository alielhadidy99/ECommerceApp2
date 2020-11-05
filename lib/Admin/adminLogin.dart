import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Admin/adminUploadItems.dart';
import 'package:ecommerceapp/Authentication/authenication.dart';
import 'package:ecommerceapp/DialogBox/errorDialog.dart';
import 'package:ecommerceapp/Widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'images/admin.png',
                height: 240,
                width: 240,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Admin',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold),
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
                    hintText: 'Id',
                    controller: _adminIdController,
                    data: Icons.person,
                    isObsecure: false,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    hintText: 'Password',
                    controller: _adminPasswordController,
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            RaisedButton(
              onPressed: () {
                _adminIdController.text.isNotEmpty &&
                        _adminPasswordController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message: 'Please write Id and password',
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
              height: 50.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.black26,
            ),
            SizedBox(
              height: 20.0,
            ),
            FlatButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthenticScreen(),
                ),
              ),
              icon: (Icon(
                Icons.nature_people,
                color: Colors.black,
              )),
              label: Text(
                "i'm Not Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }

  loginAdmin() {
    Firestore.instance.collection("admins").getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.data["id"] != _adminIdController.text.trim()) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("your id id not correct"),
            ),
          );
        } else if (element.data["password"] !=
            _adminPasswordController.text.trim()) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("your password id not correct"),
            ),
          );
        } else {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Weclome Dear Admin, " + element.data["name"]),
            ),
          );
          setState(() {
            _adminIdController.text = "";
            _adminPasswordController.text = "";
          });
          Route route = MaterialPageRoute(builder: (c) => UploadPage());
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }
}
