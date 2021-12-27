import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'forget_password_with_login_page.dart';
import 'package:therapist_buddy/screens/edit_profile_page.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'no_internet_connection_page.dart';

class ChangePasswordPageWidget extends StatefulWidget {
  final String userDocumentID;
  final String userPassword;
  final String userCallingCode;
  final String userPhoneNumber;

  ChangePasswordPageWidget(
      {Key key,
      @required this.userDocumentID,
      @required this.userPassword,
      @required this.userCallingCode,
      @required this.userPhoneNumber})
      : super(key: key);

  @override
  _ChangePasswordPageWidgetState createState() =>
      _ChangePasswordPageWidgetState();
}

class _ChangePasswordPageWidgetState extends State<ChangePasswordPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController newPasswordTextFieldController;
  TextEditingController oldPasswordTextFieldController;
  TextEditingController repeatNewPasswordTextFieldController;
  bool newPasswordTextFieldVisibility;
  bool oldPasswordTextFieldVisibility;
  bool repeatNewPasswordTextFieldVisibility;
  String userDocumentID;
  String userPassword;
  String userCallingCode;
  String userPhoneNumber;
  bool formOnSubmitted;
  bool emptyOldPassword;
  bool correctOldPassword;
  bool emptyNewPassword;
  bool newPasswordEightDigits;
  bool emptyRepeatNewPassword;
  bool matchedPasswords;
  bool validForm;

  @override
  void initState() {
    super.initState();
    validForm = false;
    newPasswordTextFieldController = TextEditingController();
    oldPasswordTextFieldController = TextEditingController();
    repeatNewPasswordTextFieldController = TextEditingController();
    newPasswordTextFieldVisibility = false;
    oldPasswordTextFieldVisibility = false;
    repeatNewPasswordTextFieldVisibility = false;
    userDocumentID = widget.userDocumentID;
    userPassword = widget.userPassword;
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
      'เปลี่ยนรหัสผ่านเสร็จสมบูรณ์',
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
    bool keyboardIsOff = MediaQuery.of(context).viewInsets.bottom == 0;

    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      floatingActionButton:
          keyboardIsOff ? forgetPasswordButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Column(
              children: [
                oldPasswordFieldTitle(),
                oldPasswordField(),
                newPasswordFieldTitle(),
                newPasswordField(),
                repeatNewPasswordFieldTitle(),
                repeatNewPasswordField(),
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
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget oldPasswordFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 25, 30, 0),
      child: Row(
        children: [
          Align(
            alignment: Alignment(-1, 0),
            child: Text(
              'ใส่รหัสผ่านปัจจุบัน',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment(-1, 0),
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                formOnSubmitted == true
                    ? emptyOldPassword == true
                        ? '(โปรดระบุรหัสผ่านปัจจุบัน)'
                        : correctOldPassword == false
                            ? '(รหัสผ่านไม่ตรงกัน)'
                            : ''
                    : '',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: emptyOldPassword == true || correctOldPassword == false
                      ? snackBarRed
                      : Colors.transparent,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget oldPasswordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyOldPassword = false;
                correctOldPassword = true;
              });
            } else {
              setState(() {
                emptyOldPassword = true;
              });
            }
          }
        },
        controller: oldPasswordTextFieldController,
        obscureText: !oldPasswordTextFieldVisibility,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: emptyOldPassword == true || correctOldPassword == false
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
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          suffixIcon: InkWell(
            onTap: () => setState(
              () => oldPasswordTextFieldVisibility =
                  !oldPasswordTextFieldVisibility,
            ),
            child: Icon(
              oldPasswordTextFieldVisibility
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

  Widget newPasswordFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        children: [
          Align(
            alignment: Alignment(-1, 0),
            child: Text(
              'ใส่รหัสผ่านใหม่',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment(-1, 0),
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                formOnSubmitted == true
                    ? emptyNewPassword == true
                        ? '(โปรดระบุรหัสผ่านใหม่)'
                        : newPasswordEightDigits == false
                            ? '(ใส่รหัสผ่านอย่างน้อย 8 ตัว)'
                            : '(ใส่รหัสผ่านอย่างน้อย 8 ตัว)'
                    : '(ใส่รหัสผ่านอย่างน้อย 8 ตัว)',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: emptyNewPassword == true ||
                          newPasswordEightDigits == false
                      ? snackBarRed
                      : Color(0xFFB1B2B8),
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget newPasswordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyNewPassword = false;
              });
              if (value.length < 8) {
                setState(() {
                  newPasswordEightDigits = false;
                });
              } else {
                setState(() {
                  newPasswordEightDigits = true;
                });
              }
              if (repeatNewPasswordTextFieldController.text.isNotEmpty) {
                if (value == repeatNewPasswordTextFieldController.text) {
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
                emptyNewPassword = true;
              });
            }
          }
        },
        controller: newPasswordTextFieldController,
        obscureText: !newPasswordTextFieldVisibility,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: emptyNewPassword == true || newPasswordEightDigits == false
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
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          suffixIcon: InkWell(
            onTap: () => setState(
              () => newPasswordTextFieldVisibility =
                  !newPasswordTextFieldVisibility,
            ),
            child: Icon(
              newPasswordTextFieldVisibility
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

  Widget repeatNewPasswordFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        children: [
          Align(
            alignment: Alignment(-1, 0),
            child: Text(
              'ใส่รหัสผ่านใหม่อีกครั้ง',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment(-1, 0),
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                formOnSubmitted == true
                    ? emptyRepeatNewPassword == true
                        ? '(โปรดระบุรหัสผ่านใหม่อีกครั้ง)'
                        : matchedPasswords == false
                            ? '(รหัสผ่านไม่ตรงกัน)'
                            : ''
                    : '',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: emptyRepeatNewPassword == true ||
                          matchedPasswords == false
                      ? snackBarRed
                      : Colors.transparent,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget repeatNewPasswordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyRepeatNewPassword = false;
              });
              if (value != newPasswordTextFieldController.text) {
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
                emptyRepeatNewPassword = true;
              });
            }
          }
        },
        controller: repeatNewPasswordTextFieldController,
        obscureText: !repeatNewPasswordTextFieldVisibility,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: emptyRepeatNewPassword == true || matchedPasswords == false
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
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          suffixIcon: InkWell(
            onTap: () => setState(
              () => repeatNewPasswordTextFieldVisibility =
                  !repeatNewPasswordTextFieldVisibility,
            ),
            child: Icon(
              repeatNewPasswordTextFieldVisibility
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
          borderRadius: 32,
        ),
      ),
    );
  }

  Future<Null> validateForm() async {
    String oldPassword = oldPasswordTextFieldController.text;
    String newPassword = newPasswordTextFieldController.text;
    String repeatNewPassword = repeatNewPasswordTextFieldController.text;

    setState(() {
      formOnSubmitted = true;
    });

    if (oldPassword.isEmpty) {
      setState(() {
        emptyOldPassword = true;
      });
    } else {
      if (oldPassword != userPassword) {
        setState(() {
          correctOldPassword = false;
        });
      }
    }

    if (newPassword.isEmpty) {
      setState(() {
        emptyNewPassword = true;
      });
    } else {
      if (newPassword.length < 8) {
        setState(() {
          newPasswordEightDigits = false;
        });
      }
    }

    if (repeatNewPassword.isEmpty) {
      setState(() {
        emptyRepeatNewPassword = true;
      });
    } else {
      if (repeatNewPassword != newPassword) {
        setState(() {
          matchedPasswords = false;
        });
      }
    }

    if (emptyOldPassword == true ||
        correctOldPassword == false ||
        emptyNewPassword == true ||
        newPasswordEightDigits == false ||
        emptyRepeatNewPassword == true ||
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
      await updatePassword();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
  }

  Future<Null> updatePassword() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังอัปเดตข้อมูล'),
    );

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['password'] = newPasswordTextFieldController.text;

      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .update(data)
          .then((value) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(successfulUpdateSnackBar);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePageWidget(),
          ),
          (r) => false,
        );
      });
    });
  }

  Widget forgetPasswordButton(BuildContext context) {
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
              builder: (context) => ForgetPasswordWithLoginPageWidget(
                userDocumentID: userDocumentID,
                userCallingCode: userCallingCode,
                userPhoneNumber: userPhoneNumber,
              ),
            ),
          );
        }
      },
      backgroundColor: Colors.white,
      elevation: 0,
      label: Text(
        'ลืมรหัสผ่านใช่หรือไม่',
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

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
