import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'otp_verification_in_signup_page.dart';
import '../widgets/progress_indicator_no_dialog.dart';
import 'package:therapist_buddy/dropdown_lists.dart';
import 'no_internet_connection_page.dart';

class SignupPageWidget extends StatefulWidget {
  SignupPageWidget({Key key}) : super(key: key);

  @override
  _SignupPageWidgetState createState() => _SignupPageWidgetState();
}

class _SignupPageWidgetState extends State<SignupPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController firstNameTextFieldController;
  TextEditingController lastNameTextFieldController;
  TextEditingController phoneNumberTextFieldController;
  TextEditingController passwordTextFieldController;
  TextEditingController repeatPasswordTextFieldController;
  TextEditingController licenseNumberTextFieldController;
  bool passwordTextFieldVisibility;
  bool repeatPasswordTextFieldVisibility;
  File profileImagePath;
  String nameTitleValue;
  String callingCodeValue;
  String licenseTitleValue;
  String workplaceValue;
  String genderValue;
  DateTime chosenDate;
  String birthday;
  bool formOnSubmitted;
  bool emptyFirstName;
  bool emptyLastName;
  bool emptyPhoneNumber;
  bool phoneNumberNineDigits;
  bool availablePhoneNumber;
  bool emptyPassword;
  bool passwordEightDigits;
  bool emptyRepeatPassword;
  bool matchedPasswords;
  bool emptyLicenseNumber;
  bool emptyBirthday;
  bool validForm;

  @override
  void initState() {
    super.initState();
    validForm = false;
    initializeDateFormatting();
    firstNameTextFieldController = TextEditingController();
    lastNameTextFieldController = TextEditingController();
    phoneNumberTextFieldController = TextEditingController();
    passwordTextFieldController = TextEditingController();
    repeatPasswordTextFieldController = TextEditingController();
    licenseNumberTextFieldController = TextEditingController();
    passwordTextFieldVisibility = false;
    repeatPasswordTextFieldVisibility = false;
    nameTitleValue = "กภ.";
    callingCodeValue = '66';
    licenseTitleValue = "กภ.";
    workplaceValue = "โรงพยาบาลสงขลานครินทร์";
    genderValue = "ชาย";
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

  final unavailablePhoneNumberSnackBar = SnackBar(
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
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileImageArea(),
                firstNameFieldTitle(),
                firstNameField(),
                lastNameFieldTitle(),
                lastNameField(),
                phoneNumberFieldTitle(),
                phoneNumberField(),
                passwordFieldTitle(),
                passwordField(),
                repeatPasswordFieldTitle(),
                repeatPasswordField(),
                licenseNumberFieldTitle(),
                licenseNumberField(),
                workplaceFieldTitle(),
                workplaceField(),
                birthdayFieldTitle(),
                birthdayField(context),
                genderFieldTitle(),
                gendersField(),
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
          'ลงทะเบียน',
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

  Widget profileImageArea() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          profileImage(),
          formOnSubmitted == true
              ? profileImagePath == null
                  ? emptyProfileImageErrorMessage()
                  : SizedBox()
              : SizedBox(),
        ],
      ),
    );
  }

  Widget profileImage() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => selectImageSourceDialog(),
        );
      },
      child: Stack(
        alignment: Alignment(0, 0.9),
        children: [
          Container(
            width: 125,
            height: 125,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: formOnSubmitted == true
                  ? profileImagePath == null
                      ? Border.all(
                          width: 1,
                          color: snackBarRed,
                        )
                      : null
                  : null,
            ),
            child: profileImagePath == null
                ? Image.asset(
                    'assets/images/profileDefault_circle.png',
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    profileImagePath,
                    fit: BoxFit.cover,
                  ),
          ),
          Align(
            alignment: Alignment(0.25, 0),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFFF0F2F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_rounded,
                color: Colors.black,
                size: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget selectImageSourceDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              var profileImage = await ImagePicker().pickImage(
                source: ImageSource.camera,
              );
              setState(() {
                profileImagePath = File(profileImage.path);
                print('profileImagePath = $profileImagePath');
              });
            },
            title: Text(
              'เปิดกล้อง',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              var profileImage = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              setState(() {
                profileImagePath = File(profileImage.path);
                print('profileImagePath = $profileImagePath');
              });
            },
            title: Text(
              'เลือกรูปภาพ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget emptyProfileImageErrorMessage() {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Align(
        alignment: Alignment(0, 0),
        child: Text(
          'โปรดใส่รูปภาพโปรไฟล์',
          style: GoogleFonts.getFont(
            'Kanit',
            color: snackBarRed,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget firstNameFieldTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ชื่อ',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุชื่อ)',
              style: GoogleFonts.getFont(
                'Kanit',
                color:
                    emptyFirstName == true ? snackBarRed : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget firstNameField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        children: [
          Container(
            width: 95,
            height: 49,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              border: Border.all(
                color: secondaryColor,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: nameTitleValue,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  color: Colors.black,
                ),
                items: DropdownLists.nameTitles
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    nameTitleValue = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFormField(
                onChanged: (value) {
                  if (formOnSubmitted == true) {
                    if (value.isNotEmpty) {
                      setState(() {
                        emptyFirstName = false;
                      });
                    } else {
                      setState(() {
                        emptyFirstName = true;
                      });
                    }
                  }
                },
                controller: firstNameTextFieldController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          emptyFirstName == true ? snackBarRed : secondaryColor,
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
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget lastNameFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'นามสกุล',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุนามสกุล)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: emptyLastName == true ? snackBarRed : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lastNameField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onChanged: (value) {
          if (formOnSubmitted == true) {
            if (value.isNotEmpty) {
              setState(() {
                emptyLastName = false;
              });
            } else {
              setState(() {
                emptyLastName = true;
              });
            }
          }
        },
        controller: lastNameTextFieldController,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: emptyLastName == true ? snackBarRed : secondaryColor,
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
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget phoneNumberFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'หมายเลขโทรศัพท์',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              emptyPhoneNumber == true
                  ? '(โปรดระบุหมายเลขโทรศัพท์)'
                  : phoneNumberNineDigits == false
                      ? '(ต้องประกอบด้วยตัวเลข 9 หลัก)'
                      : '(หมายเลขนี้ถูกใช้งานแล้ว)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: emptyPhoneNumber == true ||
                        phoneNumberNineDigits == false ||
                        availablePhoneNumber == false
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

  Widget phoneNumberField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
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
              padding: EdgeInsets.only(left: 10),
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
                      }
                    } else {
                      setState(() {
                        emptyPhoneNumber = true;
                      });
                    }
                  }
                },
                controller: phoneNumberTextFieldController,
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
                      color: emptyPhoneNumber == true ||
                              phoneNumberNineDigits == false ||
                              availablePhoneNumber == false
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

  Widget passwordFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'รหัสผ่าน',
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
        maxLines: 1,
      ),
    );
  }

  Widget licenseNumberFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'เลขที่ใบประกอบ',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุเลขที่ใบประกอบ)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: emptyLicenseNumber == true
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

  Widget licenseNumberField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        children: [
          Container(
            width: 95,
            height: 49,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              border: Border.all(
                color: secondaryColor,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: licenseTitleValue,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  color: Colors.black,
                ),
                items: DropdownLists.licenseNumberTitles
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    licenseTitleValue = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFormField(
                onChanged: (value) {
                  if (formOnSubmitted == true) {
                    if (value.isNotEmpty) {
                      setState(() {
                        emptyLicenseNumber = false;
                      });
                    } else {
                      setState(() {
                        emptyLicenseNumber = true;
                      });
                    }
                  }
                },
                controller: licenseNumberTextFieldController,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: emptyLicenseNumber == true
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

  Widget workplaceFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Text(
        'สถานพยาบาลที่ปฏิบัติงานอยู่',
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget workplaceField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Container(
        width: double.infinity,
        height: 49,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(
            color: secondaryColor,
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: workplaceValue,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.black,
            ),
            items: DropdownLists.workplaces
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String value) {
              setState(() {
                workplaceValue = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget birthdayFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'วันเกิด',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดเลือกวันเกิด)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: emptyBirthday == true ? snackBarRed : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget birthdayField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onTap: () => DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          currentTime: chosenDate == null ? DateTime.now() : chosenDate,
          maxTime: DateTime.now(),
          locale: LocaleType.th,
          onConfirm: (dateTime) {
            DateFormat dateFormat = DateFormat.yMd('th');
            setState(() {
              chosenDate = dateTime;
              birthday = dateFormat.format(chosenDate);
              emptyBirthday = false;
            });
          },
        ),
        readOnly: true,
        decoration: InputDecoration(
            hintText: birthday == null ? 'เลือกวันเกิด' : birthday,
            hintStyle: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: emptyBirthday == true ? snackBarRed : secondaryColor,
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
            contentPadding: EdgeInsets.fromLTRB(18, 14, 18, 14),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendarAlt,
                    color: primaryColor,
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget genderFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Text(
        'วันเกิด',
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget gendersField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 8, 0, 0),
      child: Column(
        children: [
          Row(
            children: [
              Radio(
                value: 'ชาย',
                groupValue: genderValue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) {
                  setState(() {
                    genderValue = value;
                    print("genderValue = $genderValue");
                  });
                },
              ),
              Text(
                'ชาย',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'หญิง',
                groupValue: genderValue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) {
                  setState(() {
                    genderValue = value;
                    print("genderValue = $genderValue");
                  });
                },
              ),
              Text(
                'หญิง',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'อื่นๆ',
                groupValue: genderValue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) {
                  setState(() {
                    genderValue = value;
                    print("genderValue = $genderValue");
                  });
                },
              ),
              Text(
                'อื่นๆ',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'ไม่ระบุ',
                groupValue: genderValue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) {
                  setState(() {
                    genderValue = value;
                    print("genderValue = $genderValue");
                  });
                },
              ),
              Text(
                'ไม่ระบุ',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget nextButton(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
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
      ),
    );
  }

  // ตรวจสอบว่าผู้ใช้กรอกข้อมูลครบถ้วนและถูกต้องหรือไม่
  Future<Null> validateForm() async {
    String firstName = firstNameTextFieldController.text;
    String lastName = lastNameTextFieldController.text;
    String phoneNumber = phoneNumberTextFieldController.text;
    String password = passwordTextFieldController.text;
    String repeatPassword = repeatPasswordTextFieldController.text;
    String licenseNumber = licenseNumberTextFieldController.text;

    setState(() {
      formOnSubmitted = true;
    });

    if (firstName.isEmpty) {
      setState(() {
        emptyFirstName = true;
      });
    }

    if (lastName.isEmpty) {
      setState(() {
        emptyLastName = true;
      });
    }

    if (phoneNumber.isEmpty) {
      setState(() {
        emptyPhoneNumber = true;
      });
    } else {
      if (phoneNumber.length < 9) {
        setState(() {
          phoneNumberNineDigits = false;
        });
      }
    }

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

    if (licenseNumber.isEmpty) {
      setState(() {
        emptyLicenseNumber = true;
      });
    }

    if (birthday == null) {
      setState(() {
        emptyBirthday = true;
      });
    }

    if (profileImagePath == null ||
        emptyFirstName == true ||
        emptyLastName == true ||
        emptyPhoneNumber == true ||
        phoneNumberNineDigits == false ||
        emptyPassword == true ||
        passwordEightDigits == false ||
        emptyRepeatPassword == true ||
        matchedPasswords == false ||
        emptyLicenseNumber == true ||
        emptyBirthday == true) {
      setState(() {
        validForm = false;
      });
    } else {
      setState(() {
        validForm = true;
      });
    }

    if (validForm == true) {
      await checkPhoneNumber();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
  }

  // ตรวจสอบว่าหมายเลขโทรศัพท์นี้ถูกใช้งานแล้วหรือไม่
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
          .then((value) async {
        // ถ้าหมายเลขโทรศัพท์นี้ยังไม่ถูกใช้งานให้ goToNextPage
        if (value.docs.length == 0) {
          await goToNextPage();
        } else {
          // ถ้าหมายเลขโทรศัพท์นี้ถูกใช้งานแล้วให้เปลี่ยนค่า validaPhoneNumber เป็น false เพื่อแสดง error,
          // ปิด ProgressIndicatorNoDialog, แสดง invalidPhoneNumberSnackBar
          setState(() {
            availablePhoneNumber = false;
          });
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(unavailablePhoneNumberSnackBar);
        }
      });
    });
  }

  // ไปที่หน้าถัดไป
  Future<Null> goToNextPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationInSignupPageWidget(
          profileImagePath: profileImagePath,
          nameTitleValue: nameTitleValue,
          firstName: firstNameTextFieldController.text,
          lastName: lastNameTextFieldController.text,
          callingCodeValue: callingCodeValue,
          phoneNumber: phoneNumberTextFieldController.text,
          password: passwordTextFieldController.text,
          repeatPassword: repeatPasswordTextFieldController.text,
          licenseTitleValue: licenseTitleValue,
          licenseNumber: licenseNumberTextFieldController.text,
          workplaceValue: workplaceValue,
          birthday: chosenDate,
          genderValue: genderValue,
        ),
      ),
    );
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
