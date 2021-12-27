import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

import 'package:therapist_buddy/variables.dart';
import '../main.dart';
import 'signup_page.dart';
import 'forget_password_not_login_page.dart';
import '../models/therapists_model.dart';
import '../widgets/progress_indicator_no_dialog.dart';
import 'no_internet_connection_page.dart';

class LoginPageWidget extends StatefulWidget {
  LoginPageWidget({Key key}) : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController passwordTextFieldController;
  TextEditingController phoneNumberTextFieldController;
  bool passwordTextFieldVisibility;
  String callingCodeValue;

  @override
  void initState() {
    super.initState();
    passwordTextFieldController = TextEditingController();
    phoneNumberTextFieldController = TextEditingController();
    passwordTextFieldVisibility = false;
    callingCodeValue = '66';
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
  }

  Future<Null> checkInternetConnectionInitState() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        internetIsConnected = false;
      });
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            internetIsConnected = true;
          });
        }
      } on SocketException catch (_) {
        setState(() {
          internetIsConnected = false;
        });
      }
    }
  }

  Future<Null> checkInternetConnectionRealTime() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        setState(() {
          internetIsConnected = false;
        });
      } else {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            setState(() {
              internetIsConnected = true;
            });
          }
        } on SocketException catch (_) {
          setState(() {
            internetIsConnected = false;
          });
        }
      }
    });
  }

  final emptyTextfieldSnackBar = SnackBar(
    content: Text(
      'กรุณากรอกหมายเลขโทรศัพท์และรหัสผ่าน',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final wrongAuthenticationSnackBar = SnackBar(
    content: Text(
      'หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOff = MediaQuery.of(context).viewInsets.bottom == 0;

    return Scaffold(
      appBar: internetIsConnected == false ? appBar(context) : null,
      backgroundColor: Colors.white,
      floatingActionButton: keyboardIsOff ? buildSignupButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildLogoImage(context),
                  buildAppName(),
                  buildPhoneNumberRow(),
                  buildPasswordField(),
                  buildForgetPasswordRow(context),
                  buildLogInButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(20),
      child: AppBar(
        toolbarHeight: 20,
        backgroundColor: snackBarRed,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.white,
              size: 15,
            ),
            SizedBox(width: 8),
            Text(
              'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  Widget buildSignupButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (internetIsConnected == false) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoInternetConnectionPageWidget(),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupPageWidget(),
            ),
          );
        }
      },
      backgroundColor: Colors.white,
      elevation: 0,
      label: Text(
        'สร้างบัญชีใหม่',
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w300,
          fontSize: 18,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget buildAppName() {
    return Padding(
      padding: EdgeInsets.only(top: 18),
      child: Text(
        'TherapistBuddy',
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(
          'Raleway',
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 33,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget buildLogoImage(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: MediaQuery.of(context).size.width * 0.35,
      fit: BoxFit.fitWidth,
    );
  }

  Widget buildPhoneNumberRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(33, 25, 33, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 95,
            height: 49,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/thailandFlag_pic.jpg',
                  width: 28,
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    '+$callingCodeValue',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: TextFormField(
                controller: phoneNumberTextFieldController,
                inputFormatters: [LengthLimitingTextInputFormatter(9)],
                decoration: InputDecoration(
                  hintText: 'หมายเลขโทรศัพท์',
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: Color(0xFFA7A8AF),
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildPasswordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(33, 8, 33, 0),
      child: TextFormField(
        controller: passwordTextFieldController,
        obscureText: !passwordTextFieldVisibility,
        decoration: InputDecoration(
          hintText: 'รหัสผ่าน',
          hintStyle: GoogleFonts.getFont(
            'Kanit',
            color: Color(0xFFA7A8AF),
            fontWeight: FontWeight.w300,
            fontSize: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          suffixIcon: GestureDetector(
            onTap: () => setState(
              () => passwordTextFieldVisibility = !passwordTextFieldVisibility,
            ),
            child: Icon(
              passwordTextFieldVisibility
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Color(0xFFA7A8AF),
              size: 20,
            ),
          ),
        ),
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildLogInButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: FFButtonWidget(
        onPressed: () async {
          if (internetIsConnected == false) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoInternetConnectionPageWidget(),
              ),
            );
          } else {
            await validateForm();
          }
        },
        text: 'ล็อกอิน',
        options: FFButtonOptions(
          width: 190,
          height: 49,
          color: primaryColor,
          textStyle: GoogleFonts.getFont(
            'Kanit',
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
          borderRadius: 32,
        ),
      ),
    );
  }

  Future<Null> validateForm() async {
    String phoneNumber = phoneNumberTextFieldController.text;
    String password = passwordTextFieldController.text;

    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(emptyTextfieldSnackBar);
    } else {
      await checkAuthentication();
    }
  }

  // ตรวจสอบว่าหมายเลขโทรศัพท์นี้มีในฐานข้อมูลแล้วหรือไม่
  Future<Null> checkAuthentication() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressIndicatorNoDialog(),
    );

    await Firebase.initializeApp().then((value) {
      FirebaseFirestore.instance
          .collection('therapists')
          .where('callingCode', isEqualTo: callingCodeValue)
          .where('phoneNumber', isEqualTo: phoneNumberTextFieldController.text)
          .get()
          .then((value) async {
        // หากยังไม่มีหมายเลขโทรศัพท์นี้ในฐานข้อมูลให้ปิด ProgressIndicatorNoDialog และแสดง wrongAuthenticationSnackBar
        if (value.docs.length == 0) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(wrongAuthenticationSnackBar);
        } else {
          // หากมีหมายเลขโทรศัพท์นี้ในฐานข้อมูลแล้วให้ตรวจสอบว่ารหัสผ่านตรงกันหรือไม่
          for (var item in value.docs) {
            String userDocumentID = item.id;
            print('userDocumentID = $userDocumentID');

            await FirebaseFirestore.instance
                .collection('therapists')
                .doc(userDocumentID)
                .get()
                .then((value) async {
              print('event = ${value.data()}');

              TherapistsModel therapistsModel =
                  TherapistsModel.fromMap(value.data());

              // ถ้าตรงกันให้เก็บค่า userDocumentID ใน SharedPreferences และ navigate ไปยัง Home_page
              if (passwordTextFieldController.text ==
                  therapistsModel.password) {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences
                    .setString('userDocumentID', userDocumentID)
                    .then((value) async {
                  await goToHomePage();
                });
              } else {
                // ถ้าไม่ตรงกันให้ปิด ProgressIndicatorNoDialog และแสดง wrongAuthenticationSnackBar
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(wrongAuthenticationSnackBar);
              }
            });
          }
        }
      });
    });
  }

  Future<Null> goToHomePage() async {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => NavBarPage(initialPage: 'Home_page'),
      ),
      (r) => false,
    );
  }

  Widget buildForgetPasswordRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(33, 20, 33, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              if (internetIsConnected == false) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoInternetConnectionPageWidget(),
                  ),
                );
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgetPasswordNotLoginPageWidget(),
                  ),
                );
              }
            },
            child: Text(
              'ลืมรหัสผ่านใช่หรือไม่',
              style: GoogleFonts.getFont('Kanit',
                  color: Color(0xFF7A7A7A),
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  decoration: TextDecoration.underline),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
