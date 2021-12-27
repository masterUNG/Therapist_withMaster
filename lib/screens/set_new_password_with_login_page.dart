import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'edit_profile_page.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'no_internet_connection_page.dart';

class SetNewPasswordWithLoginPageWidget extends StatefulWidget {
  final String userDocumentId;

  SetNewPasswordWithLoginPageWidget({Key key, @required this.userDocumentId})
      : super(key: key);

  @override
  _SetNewPasswordWithLoginPageWidgetState createState() =>
      _SetNewPasswordWithLoginPageWidgetState();
}

class _SetNewPasswordWithLoginPageWidgetState
    extends State<SetNewPasswordWithLoginPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController passwordTextFieldController;
  TextEditingController repeatPasswordTextFieldController;
  bool passwordTextFieldVisibility;
  bool repeatPasswordTextFieldVisibility;
  String userDocumentID;
  bool formOnSubmitted;
  bool emptyPassword;
  bool passwordEightDigits;
  bool emptyRepeatPassword;
  bool matchedPasswords;
  bool validForm;

  @override
  void initState() {
    super.initState();
    userDocumentID = widget.userDocumentId;
    passwordTextFieldController = TextEditingController();
    repeatPasswordTextFieldController = TextEditingController();
    passwordTextFieldVisibility = false;
    repeatPasswordTextFieldVisibility = false;
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

  final errorSnackBar = SnackBar(
    content: Text(
      'กรุณาตรวจสอบข้อมูลอีกครั้ง',
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
      'เปลี่ยนรหัสผ่านสำเร็จ',
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
              children: [
                title(),
                passwordFieldTitle(),
                passwordField(),
                repeatPasswordFieldTitle(),
                repeatPasswordField(),
                confirmButton(context)
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
          'เปลี่ยนรหัสผ่าน',
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

  Widget title() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
      child: Text(
        'ตั้งรหัสผ่านใหม่',
        style: GoogleFonts.getFont(
          'Kanit',
          fontSize: 20,
        ),
      ),
    );
  }

  Widget passwordFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
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
                      : passwordEightDigits == false
                          ? '(ใส่รหัสผ่านอย่างน้อย 8 ตัว)'
                          : '(ใส่รหัสผ่านอย่างน้อย 8 ตัว)'
                  : '(ใส่รหัสผ่านอย่างน้อย 8 ตัว)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: emptyPassword == true || passwordEightDigits == false
                    ? snackBarRed
                    : Color(0xFFB1B2B8),
                fontSize: 14,
              ),
            ),
          ),
        ],
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
              });
              if (value.length < 8) {
                setState(() {
                  passwordEightDigits = false;
                });
              } else {
                setState(() {
                  passwordEightDigits = true;
                });
              }
              if (repeatPasswordTextFieldController.text != '') {
                if (value == repeatPasswordTextFieldController.text) {
                  setState(() {
                    matchedPasswords = true;
                  });
                } else {
                  setState(() {
                    matchedPasswords = false;
                  });
                }
              }
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
              color: emptyPassword == true || passwordEightDigits == false
                  ? snackBarRed
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

  Widget repeatPasswordFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ใส่รหัสผ่านอีกครั้ง',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              emptyRepeatPassword == true
                  ? '(โปรดระบุรหัสผ่านอีกครั้ง)'
                  : matchedPasswords == false
                      ? '(รหัสผ่านไม่ตรงกัน)'
                      : '',
              style: GoogleFonts.getFont(
                'Kanit',
                color: emptyRepeatPassword == true || matchedPasswords == false
                    ? snackBarRed
                    : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget repeatPasswordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyRepeatPassword = false;
              });
              if (value != passwordTextFieldController.text) {
                setState(() {
                  matchedPasswords = false;
                });
              } else {
                setState(() {
                  matchedPasswords = true;
                });
              }
            } else {
              setState(() {
                emptyRepeatPassword = true;
              });
            }
          }
        },
        controller: repeatPasswordTextFieldController,
        obscureText: !repeatPasswordTextFieldVisibility,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: emptyRepeatPassword == true || matchedPasswords == false
                  ? snackBarRed
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
          suffixIcon: GestureDetector(
            onTap: () => setState(
              () => repeatPasswordTextFieldVisibility =
                  !repeatPasswordTextFieldVisibility,
            ),
            child: Icon(
              repeatPasswordTextFieldVisibility
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
        text: 'ยืนยัน',
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

  // ตรวจสอบว่าข้อมูลที่ผู้ใช้กรอกครบถ้วนและถูกต้องหรือไม่
  Future<Null> validateForm() async {
    // ถ้าข้อมูลที่ผู้ใช้กรอกครบถ้วนและถูกต้องให้ไปที่ updatingPasswordProcess
    String password = passwordTextFieldController.text;
    String repeatPassword = repeatPasswordTextFieldController.text;

    setState(() {
      formOnSubmitted = true;
    });

    if (password.isEmpty) {
      setState(() {
        emptyPassword = true;
      });
    } else {
      if (password.length < 8) {
        setState(() {
          passwordEightDigits = false;
        });
      }
    }

    if (repeatPassword.isEmpty) {
      setState(() {
        emptyRepeatPassword = true;
      });
    } else {
      if (password != repeatPassword) {
        setState(() {
          matchedPasswords = false;
        });
      }
    }

    if (emptyPassword == true ||
        passwordEightDigits == false ||
        emptyRepeatPassword == true ||
        matchedPasswords == false) {
      setState(() {
        validForm = false;
      });
    } else {
      setState(() {
        validForm = true;
      });
    }

    if (validForm == true) {
      await updatingPasswordProcess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
  }

  // อัพเดตรหัสผ่านของผู้ใช้
  Future<Null> updatingPasswordProcess() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังเปลี่ยนรหัสผ่าน'),
    );

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['password'] = passwordTextFieldController.text;

      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .update(data)
          .then((value) async {
        // หลังจากอัพเดตรหัสผ่านของผู้ใช้เสร็จแล้วให้แสดง successfulUpdateSnackBar และ navigate ไปยัง LoginPageWidget
        print('Update password successfully');

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

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
