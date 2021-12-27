import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'otp_verification_in_set_new_phone_number_page.dart';
import 'package:therapist_buddy/widgets/progress_indicator_no_dialog.dart';
import 'no_internet_connection_page.dart';

class SetNewPhoneNumberPageWidget extends StatefulWidget {
  final String userDocumentID;
  final String userPhoneNumber;

  SetNewPhoneNumberPageWidget(
      {Key key, @required this.userDocumentID, @required this.userPhoneNumber})
      : super(key: key);

  @override
  _SetNewPhoneNumberPageWidgetState createState() =>
      _SetNewPhoneNumberPageWidgetState();
}

class _SetNewPhoneNumberPageWidgetState
    extends State<SetNewPhoneNumberPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController newPhoneNumberTextFieldController;
  String userDocumentID;
  String userPhoneNumber;
  String callingCodeValue;
  bool formOnSubmitted;
  bool emptyPhoneNumber;
  bool phoneNumberNineDigits;
  bool samePhoneNumber;
  bool availablePhoneNumber;

  @override
  void initState() {
    super.initState();
    newPhoneNumberTextFieldController = TextEditingController();
    userDocumentID = widget.userDocumentID;
    userPhoneNumber = widget.userPhoneNumber;
    callingCodeValue = '66';
    formOnSubmitted = false;
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

  final wrongFormOfPhoneNumberSnackBar = SnackBar(
    content: Text(
      'หมายเลขโทรศัพท์ต้องประกอบด้วยตัวเลข 9 หลัก',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final samePhoneNumberSnackBar = SnackBar(
    content: Text(
      'นี้คือหมายเลขที่ท่านใช้งานอยู่ ณ ปัจจุบัน',
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
      'หมายเลขนี้ถูกใช้งานแล้ว',
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
                nextButton(context)
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
          'หมายเลขโทรศัพท์ใหม่',
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
    return Align(
      alignment: Alignment(-1, 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 25, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                        : phoneNumberNineDigits == false
                            ? '(ต้องประกอบด้วยตัวเลข 9 หลัก)'
                            : samePhoneNumber == true
                                ? '(นี้คือหมายเลขโทรศัพท์ปัจจุบัน)'
                                : '(หมายเลขนี้ถูกใช้งานแล้ว)'
                    : '',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: formOnSubmitted == true
                      ? emptyPhoneNumber == true ||
                              phoneNumberNineDigits == false ||
                              samePhoneNumber == true ||
                              availablePhoneNumber == false
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
                    setState(() {
                      availablePhoneNumber = true;
                    });

                    if (value.isNotEmpty) {
                      setState(() {
                        emptyPhoneNumber = false;
                      });
                      if (value.length != 9) {
                        setState(() {
                          phoneNumberNineDigits = false;
                        });
                      } else {
                        setState(() {
                          phoneNumberNineDigits = true;
                        });

                        if (value != userPhoneNumber) {
                          setState(() {
                            samePhoneNumber = false;
                          });
                        } else {
                          setState(() {
                            samePhoneNumber = true;
                          });
                        }
                      }
                    } else {
                      setState(() {
                        emptyPhoneNumber = true;
                      });
                    }
                  }
                },
                controller: newPhoneNumberTextFieldController,
                inputFormatters: [LengthLimitingTextInputFormatter(9)],
                decoration: InputDecoration(
                  hintText: 'เช่น 812345678',
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: Color(0xFFB1B2B8),
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formOnSubmitted == true
                          ? emptyPhoneNumber == true ||
                                  phoneNumberNineDigits == false ||
                                  samePhoneNumber == true ||
                                  availablePhoneNumber == false
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
                  contentPadding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                ),
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
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
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
          borderRadius: 32,
        ),
      ),
    );
  }

  Future<Null> validateForm() async {
    String newPhoneNumber = newPhoneNumberTextFieldController.text;

    setState(() {
      formOnSubmitted = true;
    });

    if (newPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(emptyTextfieldSnackBar);
      setState(() {
        emptyPhoneNumber = true;
      });
    } else {
      if (newPhoneNumber.length < 9) {
        ScaffoldMessenger.of(context)
            .showSnackBar(wrongFormOfPhoneNumberSnackBar);
        setState(() {
          phoneNumberNineDigits = false;
        });
      } else {
        if (newPhoneNumber == userPhoneNumber) {
          ScaffoldMessenger.of(context).showSnackBar(samePhoneNumberSnackBar);
          setState(() {
            samePhoneNumber = true;
          });
        } else {
          await checkPhoneNumber();
        }
      }
    }
  }

  Future<Null> checkPhoneNumber() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressIndicatorNoDialog(),
    );

    String newPhoneNumber = newPhoneNumberTextFieldController.text;

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .where('phoneNumber', isEqualTo: newPhoneNumber)
          .get()
          .then((value) async {
        if (value.docs.length == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OTPVerificationInSetNewPhoneNumberPageWidget(
                userDocumentID: userDocumentID,
                callingCodeValue: callingCodeValue,
                phoneNumber: newPhoneNumberTextFieldController.text,
              ),
            ),
          );

          Navigator.of(context, rootNavigator: true).pop();
        } else {
          setState(() {
            availablePhoneNumber = false;
          });

          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context)
              .showSnackBar(invalidPhoneNumberSnackBar);
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
