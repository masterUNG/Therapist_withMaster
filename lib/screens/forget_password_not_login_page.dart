import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'otp_verification_in_forget_password_not_login_page.dart';
import 'package:therapist_buddy/widgets/progress_indicator_no_dialog.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'no_internet_connection_page.dart';

class ForgetPasswordNotLoginPageWidget extends StatefulWidget {
  ForgetPasswordNotLoginPageWidget({Key key}) : super(key: key);

  @override
  _ForgetPasswordNotLoginPageWidgetState createState() =>
      _ForgetPasswordNotLoginPageWidgetState();
}

class _ForgetPasswordNotLoginPageWidgetState
    extends State<ForgetPasswordNotLoginPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController phoneNumberTextFieldController;
  String callingCodeValue;
  bool formOnSubmitted;
  bool emptyPhoneNumber;
  bool invalidPhoneNumber;

  @override
  void initState() {
    super.initState();
    phoneNumberTextFieldController = TextEditingController();
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

  final emptyTextFieldSnackBar = SnackBar(
    content: Text(
      'กรุณากรอกหมายเลขโทรศัพท์',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final invalidPhoneNumberSnackBar = SnackBar(
    content: Text(
      'ไม่พบหมายเลขโทรศัพท์นี้',
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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Column(
              children: [
                phoneNumberFieldTitle(),
                phoneNumberField(),
                nextButton(context),
              ],
            ),
          ),
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
          'ลืมรหัสผ่าน',
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
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget phoneNumberFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
      child: Align(
        alignment: Alignment(-1, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ใส่หมายเลขโทรศัพท์',
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
                    ? emptyPhoneNumber == true
                        ? '(โปรดระบุหมายเลขโทรศัพท์)'
                        : invalidPhoneNumber == true
                            ? '(ไม่พบหมายเลขโทรศัพท์นี้)'
                            : ''
                    : '',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: formOnSubmitted == true
                      ? emptyPhoneNumber == true || invalidPhoneNumber == true
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

  Widget phoneNumberField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
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
                onChanged: (value) {
                  if (formOnSubmitted == true) {
                    if (value.isNotEmpty) {
                      setState(() {
                        emptyPhoneNumber = false;
                        invalidPhoneNumber = false;
                      });
                    } else {
                      setState(() {
                        emptyPhoneNumber = true;
                      });
                    }
                  }
                },
                controller: phoneNumberTextFieldController,
                decoration: InputDecoration(
                  hintText: 'เช่น 812345689',
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: Color(0xFFA7A8AF),
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formOnSubmitted == true
                          ? emptyPhoneNumber == true ||
                                  invalidPhoneNumber == true
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
          borderRadius: 32,
        ),
      ),
    );
  }

  Future<Null> validateForm() async {
    setState(() {
      formOnSubmitted = true;
    });

    if (phoneNumberTextFieldController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(emptyTextFieldSnackBar);
      setState(() {
        emptyPhoneNumber = true;
      });
    } else {
      checkPhoneNumber();
    }
  }

  Future<Null> checkPhoneNumber() async {
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
          .then((value) {
        if (value.docs.length == 0) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(invalidPhoneNumberSnackBar);
          setState(() {
            invalidPhoneNumber = true;
          });
        } else {
          for (var item in value.docs) {
            String userDocumentID = item.id;
            print('documentID = $userDocumentID');

            FirebaseFirestore.instance
                .collection('therapists')
                .doc(userDocumentID)
                .get()
                .then((value) async {
              TherapistsModel therapistsModel =
                  TherapistsModel.fromMap(value.data());

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OTPVerificationInForgetPasswordNotLoginPageWidget(
                    userDocumentID: userDocumentID,
                    callingCode: therapistsModel.callingCode,
                    phoneNumber: phoneNumberTextFieldController.text,
                  ),
                ),
              );

              Navigator.of(context, rootNavigator: true).pop();
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
