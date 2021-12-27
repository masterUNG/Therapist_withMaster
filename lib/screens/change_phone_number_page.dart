import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'set_new_phone_number_page.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'no_internet_connection_page.dart';

class ChangePhoneNumberPageWidget extends StatefulWidget {
  ChangePhoneNumberPageWidget({Key key}) : super(key: key);

  @override
  _ChangePhoneNumberPageWidgetState createState() =>
      _ChangePhoneNumberPageWidgetState();
}

class _ChangePhoneNumberPageWidgetState
    extends State<ChangePhoneNumberPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController oldPhoneNumberTextFieldController;
  TextEditingController passwordTextFieldController;
  bool passwordTextFieldVisibility;
  String userDocumentID;
  String userCallingCode;
  String userPhoneNumber;
  String userPassword;
  bool readDataIsFinished;
  bool formOnSubmitted;
  bool emptyPassword;
  bool wrongPassword;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    oldPhoneNumberTextFieldController = TextEditingController();
    passwordTextFieldController = TextEditingController();
    passwordTextFieldVisibility = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    findUserDocumentID();
    findUserPhoneNumber();
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

  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
  }

  Future<Null> findUserPhoneNumber() async {
    await Firebase.initializeApp().then((value) {
      FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) async {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());

        userCallingCode = therapistsModel.callingCode;
        userPhoneNumber = therapistsModel.phoneNumber;
        userPassword = therapistsModel.password;
        print('callingCode = $userCallingCode');
        print('userPhoneNumber = $userPhoneNumber');
        print('userPassword = $userPassword');

        setState(() {
          readDataIsFinished = true;
        });
      });
    });
  }

  final emptyTextfieldSnackBar = SnackBar(
    content: Text(
      'กรุณากรอกรหัสผ่าน',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final wrongPasswordSnackBar = SnackBar(
    content: Text(
      'รหัสผ่านไม่ถูกต้อง',
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
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: readDataIsFinished == true
            ? GestureDetector(
                onTap: () =>
                    FocusScope.of(context).requestFocus(FocusScopeNode()),
                behavior: HitTestBehavior.opaque,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      title(),
                      phoneNumberFieldTitle(),
                      phoneNumberField(),
                      passwordFieldTitle(),
                      passwordField(),
                      nextButton(context)
                    ],
                  ),
                ),
              )
            : Center(
                child: SmallProgressIndicator(),
              ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    double noInternetContainerHeight = 30.0;

    return PreferredSize(
      preferredSize: internetIsConnected == false
          ? Size.fromHeight(appbarHeight + noInternetContainerHeight)
          : Size.fromHeight(appbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: primaryColor,
            size: 24,
          ),
          iconSize: 24,
        ),
        title: Text(
          'เปลี่ยนหมายเลขโทรศัพท์',
          style: GoogleFonts.getFont(
            'Kanit',
            color: primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 21,
          ),
        ),
        bottom: internetIsConnected == false
            ? PreferredSize(
                preferredSize: Size.fromHeight(noInternetContainerHeight),
                child: Container(
                  height: noInternetContainerHeight,
                  color: snackBarRed,
                  child: Row(
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
                ),
              )
            : null,
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Text(
        'ยืนยันตัวตน',
        style: GoogleFonts.getFont(
          'Kanit',
          fontSize: 20,
        ),
      ),
    );
  }

  Widget phoneNumberFieldTitle() {
    return Align(
      alignment: Alignment(-1, 0),
      child: Padding(
        padding: EdgeInsets.only(left: 30),
        child: Text(
          'หมายเลขโทรศัพท์',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget phoneNumberField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
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
                color: secondaryColor,
                width: 1,
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
                    '+$userCallingCode',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: secondaryColor,
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
                readOnly: true,
                controller: oldPhoneNumberTextFieldController,
                decoration: InputDecoration(
                  hintText: userPhoneNumber,
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: secondaryColor,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: secondaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: secondaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget passwordFieldTitle() {
    return Align(
      alignment: Alignment(-1, 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ใส่รหัสผ่าน',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                formOnSubmitted == true
                    ? emptyPassword == true
                        ? '(โปรดระบุรหัสผ่าน)'
                        : wrongPassword == true
                            ? '(รหัสผ่านไม่ถูกต้อง)'
                            : ''
                    : '',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: formOnSubmitted == true
                      ? emptyPassword == true || wrongPassword == true
                          ? snackBarRed
                          : Colors.transparent
                      : Colors.transparent,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyPassword = false;
                wrongPassword = false;
              });
            } else {
              setState(() {
                emptyPassword = true;
              });
            }
          }
        },
        controller: passwordTextFieldController,
        obscureText: !passwordTextFieldVisibility,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: formOnSubmitted == true
                  ? emptyPassword == true || wrongPassword == true
                      ? snackBarRed
                      : secondaryColor
                  : secondaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: primaryColor,
              width: 1,
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

  Widget nextButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 25),
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
        text: 'ถัดไป',
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
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
          borderRadius: 32,
        ),
      ),
    );
  }

  Future<Null> validateForm() async {
    String password = passwordTextFieldController.text;
    setState(() {
      formOnSubmitted = true;
    });

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(emptyTextfieldSnackBar);
      setState(() {
        emptyPassword = true;
      });
    } else {
      if (password == userPassword) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetNewPhoneNumberPageWidget(
              userDocumentID: userDocumentID,
              userPhoneNumber: userPhoneNumber,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(wrongPasswordSnackBar);
        setState(() {
          wrongPassword = true;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
