import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'otp_verification_in_forget_password_with_login_page.dart';
import 'no_internet_connection_page.dart';

class ForgetPasswordWithLoginPageWidget extends StatefulWidget {
  final String userDocumentID;
  final String userCallingCode;
  final String userPhoneNumber;

  ForgetPasswordWithLoginPageWidget(
      {Key key,
      @required this.userDocumentID,
      @required this.userCallingCode,
      @required this.userPhoneNumber})
      : super(key: key);

  @override
  _ForgetPasswordWithLoginPageWidgetState createState() =>
      _ForgetPasswordWithLoginPageWidgetState();
}

class _ForgetPasswordWithLoginPageWidgetState
    extends State<ForgetPasswordWithLoginPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController phoneNumberTextFieldController;
  String userDocumentID;
  String userCallingCode;
  String userPhoneNumber;

  @override
  void initState() {
    super.initState();
    phoneNumberTextFieldController = TextEditingController();
    userDocumentID = widget.userDocumentID;
    userCallingCode = widget.userCallingCode;
    userPhoneNumber = widget.userPhoneNumber;
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
        child: Text(
          'หมายเลขโทรศัพท์ของท่าน',
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
                controller: phoneNumberTextFieldController,
                decoration: InputDecoration(
                  hintText: userPhoneNumber,
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: secondaryColor,
                    fontWeight: FontWeight.w300,
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
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OTPVerificationInForgetPasswordWithLoginPageWidget(
                  userDocumentID: userDocumentID,
                  userCallingCode: userCallingCode,
                  userPhoneNumber: userPhoneNumber,
                ),
              ),
            );
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

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
