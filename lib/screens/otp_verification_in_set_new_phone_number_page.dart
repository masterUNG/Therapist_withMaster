import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/otp_sent_model.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'package:therapist_buddy/models/check_otp_model.dart';
import 'no_internet_connection_page.dart';
import 'edit_profile_page.dart';

class OTPVerificationInSetNewPhoneNumberPageWidget extends StatefulWidget {
  final String userDocumentID;
  final String callingCodeValue;
  final String phoneNumber;

  OTPVerificationInSetNewPhoneNumberPageWidget(
      {Key key,
      @required this.userDocumentID,
      @required this.callingCodeValue,
      @required this.phoneNumber})
      : super(key: key);

  @override
  _OTPVerificationInSetNewPhoneNumberPageWidgetState createState() =>
      _OTPVerificationInSetNewPhoneNumberPageWidgetState();
}

class _OTPVerificationInSetNewPhoneNumberPageWidgetState
    extends State<OTPVerificationInSetNewPhoneNumberPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController otpCodeTextFieldController;
  String userDocumentID;
  String callingCodeValue;
  String phoneNumber;
  Timer timer;
  int startTime = 60;
  bool resendOTPCodeIsAllowed;
  String otpToken;
  bool formOnSubmitted;
  bool emptyOTPCode;
  bool wrongOTPCode;

  @override
  void initState() {
    super.initState();
    otpCodeTextFieldController = TextEditingController();
    userDocumentID = widget.userDocumentID;
    callingCodeValue = widget.callingCodeValue;
    phoneNumber = widget.phoneNumber;
    resendOTPCodeIsAllowed = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    sendOTPCode();
    startTimeCountdown();
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

  // ????????????????????? OTP ???????????????????????????????????????????????????????????????????????????????????????
  Future<Null> sendOTPCode() async {
    String key = '1712112662489253';
    String secret = 'f4319a883d637c4c9250246da1f9783c';
    String msisdn = '$callingCodeValue$phoneNumber';
    String apiPath =
        'https://otp.thaibulksms.com/v1/otp/request?key=$key&secret=$secret&msisdn=$msisdn';

    await Dio().post(apiPath).then((value) {
      var result = Map<String, dynamic>.from(value.data);
      print('result = $result');
      var data = Map<String, dynamic>.from(result['data']);
      print('data = $data');
      OTPSentModel otpSentModel = OTPSentModel.fromMap(data);
      print('token = ${otpSentModel.token}');

      setState(() {
        otpToken = otpSentModel.token;
        print('otpToken = $otpToken');
      });
    });
  }

  // ??????????????????????????????????????????
  void startTimeCountdown() {
    const oneSecond = const Duration(seconds: 1);

    timer = new Timer.periodic(oneSecond, (Timer timer) {
      if (startTime == 1) {
        setState(() {
          timer.cancel();
          resendOTPCodeIsAllowed = true;
        });
      } else {
        setState(() {
          startTime--;
        });
      }
    });
  }

  final emptyTextfieldSnackBar = SnackBar(
    content: Text(
      '????????????????????????????????????????????????????????????????????????',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final wrongOTPCodeInputSnackBar = SnackBar(
    content: Text(
      '???????????????????????????????????????????????????????????????????????????',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final successfulUpdateSnackBar = SnackBar(
    content: Text(
      '??????????????????????????????????????????????????????????????????????????????????????????????????????',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: defaultGreen,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                firstLineText(),
                phoneNumberText(),
                otpCodeField(),
                confirmButton(context),
                lastLine()
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
            setState(() {
              timer.cancel();
            });
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
          '??????????????????????????????????????????????????????',
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
                        '???????????????????????????????????????????????????????????????????????????????????????',
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

  Widget firstLineText() {
    return Padding(
      padding: EdgeInsets.fromLTRB(50, 25, 50, 0),
      child: Text(
        '???????????????????????????????????????????????????????????????????????????????????? sms ?????????',
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget phoneNumberText() {
    return Text(
      '(+$callingCodeValue) $phoneNumber',
      textAlign: TextAlign.center,
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 17,
      ),
    );
  }

  Widget otpCodeField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyOTPCode = false;
                wrongOTPCode = false;
              });
            } else {
              setState(() {
                emptyOTPCode = true;
              });
            }
          }
        },
        controller: otpCodeTextFieldController,
        inputFormatters: [LengthLimitingTextInputFormatter(6)],
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: formOnSubmitted == true
                  ? emptyOTPCode == true || wrongOTPCode == true
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
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        ),
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontSize: 32,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget confirmButton(BuildContext context) {
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
        text: '??????????????????',
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
    setState(() {
      formOnSubmitted = true;
    });

    if (otpCodeTextFieldController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(emptyTextfieldSnackBar);
      setState(() {
        emptyOTPCode = true;
      });
    } else {
      await checkPhoneAuthentication();
    }
  }

  // ?????????????????????????????????????????? OTP ?????????????????????????????????????????????????????????????????????????????????
  Future<Null> checkPhoneAuthentication() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: '??????????????????????????????????????????????????????'),
    );

    String key = '1712112662489253';
    String secret = 'f4319a883d637c4c9250246da1f9783c';
    String token = otpToken;
    String pin = otpCodeTextFieldController.text;
    String apiPath =
        'https://otp.thaibulksms.com/v1/otp/verify?key=$key&secret=$secret&token=$token&pin=$pin';

    await Dio().post(apiPath).then((value) {
      // ??????????????????????????????????????????????????????????????? updatePhoneNumber
      var result = Map<String, dynamic>.from(value.data);
      print('result = $result');
      var data = Map<String, dynamic>.from(result['data']);
      print('data = $data');
      CheckOTPModel checkOTPModel = CheckOTPModel.fromMap(data);
      print('status = ${checkOTPModel.status}');

      setState(() {
        timer.cancel();
        resendOTPCodeIsAllowed = true;
      });

      Navigator.of(context, rootNavigator: true).pop();
      updatePhoneNumber();
    }).onError((error, stackTrace) {
      // ?????????????????????????????????????????????????????????????????? ProgressDialog ????????????????????? wrongOTPCodeInputSnackBar
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(wrongOTPCodeInputSnackBar);
      setState(() {
        wrongOTPCode = true;
      });
    });
  }

  Future<Null> updatePhoneNumber() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: '???????????????????????????????????????????????????'),
    );

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['phoneNumber'] = phoneNumber;

      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .update(data)
          .then((value) async {
        ScaffoldMessenger.of(context).showSnackBar(successfulUpdateSnackBar);
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePageWidget(),
          ),
          (r) => false,
        );
      });
    });
  }

  Widget lastLine() {
    return Padding(
      padding: EdgeInsets.only(top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          resendOTPCodeIsAllowed == false ? remainingTime() : resendOTPCode(),
        ],
      ),
    );
  }

  Widget remainingTime() {
    return Row(
      children: [
        Text(
          '?????????????????????',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 17,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(
            '$startTime',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.normal,
              fontSize: 17,
            ),
          ),
        ),
        Text(
          '?????????????????????????????????????????????????????????????????????',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 17,
          ),
        )
      ],
    );
  }

  Widget resendOTPCode() {
    return TextButton(
      onPressed: () {
        setState(() {
          resendOTPCodeIsAllowed = false;
          startTime = 60;
        });
        sendOTPCode();
        startTimeCountdown();
      },
      child: Text(
        '?????????????????????????????????????????????',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.normal,
          fontSize: 17,
          decoration: TextDecoration.underline,
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
