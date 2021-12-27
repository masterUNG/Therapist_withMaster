import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/main.dart';
import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import '../dropdown_lists.dart';
import 'change_password_page.dart';
import 'change_phone_number_page.dart';
import 'no_internet_connection_page.dart';

class EditProfilePageWidget extends StatefulWidget {
  EditProfilePageWidget({Key key}) : super(key: key);

  @override
  _EditProfilePageWidgetState createState() => _EditProfilePageWidgetState();
}

class _EditProfilePageWidgetState extends State<EditProfilePageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController firstNameTextFieldController;
  TextEditingController lastNameTextFieldController;
  TextEditingController phoneNumberTextFieldController;
  TextEditingController passwordTextFieldController;
  TextEditingController licenseNumberTextFieldController;
  bool passwordTextFieldVisibility;
  String userDocumentID;
  bool readDataIsFinished;
  File profileImageFile;
  String profileImagePath;
  String nameTitleValue;
  String callingCodeValue;
  String licenseNumberTitleValue;
  String workplaceValue;
  DateTime chosenDate;
  String birthdayText;
  String genderValue;
  double saveAreaHeight = 125;
  String nameTitle;
  String firstName;
  String lastName;
  String callingCode;
  String phoneNumber;
  String password;
  String licenseNumberTitle;
  String licenseNumber;
  String workplace;
  String gender;
  String birthday;
  bool profileImageIsChanged;
  bool nameTitleValueIsChanged;
  bool firstNameIsChanged;
  bool lastNameIsChanged;
  bool licenseNumberTitleValueIsChanged;
  bool licenseNumberIsChanged;
  bool workplaceValueIsChanged;
  bool birthdayTextIsChanged;
  bool genderValueIsChanged;
  bool newProfileImageIsSelected;
  bool emptyFirstName;
  bool emptyLastName;
  bool emptyLicenseNumber;
  bool validForm;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    passwordTextFieldVisibility = false;
    profileImageIsChanged = false;
    nameTitleValueIsChanged = false;
    firstNameIsChanged = false;
    lastNameIsChanged = false;
    licenseNumberTitleValueIsChanged = false;
    licenseNumberIsChanged = false;
    workplaceValueIsChanged = false;
    birthdayTextIsChanged = false;
    genderValueIsChanged = false;
    newProfileImageIsSelected = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    readUserDocumentID();
    readUserProfile();
    initializeDateFormatting();
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

  Future<Null> readUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
  }

  Future<Null> readUserProfile() async {
    await Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());

        nameTitle = therapistsModel.nameTitle;
        firstName = therapistsModel.firstName;
        lastName = therapistsModel.lastName;
        callingCode = therapistsModel.callingCode;
        phoneNumber = therapistsModel.phoneNumber;
        password = therapistsModel.password;
        licenseNumberTitle = therapistsModel.licenseNumberTitle;
        licenseNumber = therapistsModel.licenseNumber;
        workplace = therapistsModel.workplace;
        gender = therapistsModel.gender;

        setState(() {
          profileImagePath = therapistsModel.profileImage;
          nameTitleValue = nameTitle;
          firstNameTextFieldController = TextEditingController(text: firstName);
          lastNameTextFieldController = TextEditingController(text: lastName);
          callingCodeValue = callingCode;
          phoneNumberTextFieldController =
              TextEditingController(text: phoneNumber);
          passwordTextFieldController = TextEditingController(text: password);
          licenseNumberTitleValue = licenseNumberTitle;
          licenseNumberTextFieldController =
              TextEditingController(text: licenseNumber);
          workplaceValue = workplace;
          genderValue = gender;

          Timestamp birthdayTimestamp = therapistsModel.birthday;
          chosenDate = birthdayTimestamp.toDate();
          birthday = DateFormat.yMd('th').format(chosenDate);
          birthdayText = birthday;

          readDataIsFinished = true;
        });
      });
    });
  }

  final emptyTextFieldSnackBar = SnackBar(
    content: Text(
      'กรุณากรอกข้อมูลให้ครบถ้วน',
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
      'แก้ไขโปรไฟล์เสร็จสมบูรณ์',
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
        child: readDataIsFinished == true
            ? SingleChildScrollView(
                child: GestureDetector(
                  onTap: () =>
                      FocusScope.of(context).requestFocus(FocusScopeNode()),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileImage(),
                      firstNameFieldTitle(),
                      firstNameField(),
                      lastNameFieldTitle(),
                      lastNameField(),
                      phoneNumberFieldTitle(context),
                      phoneNumberField(),
                      passwordFieldTitle(context),
                      passwordField(),
                      licenseNumberFieldTitle(),
                      licenseNumberField(),
                      workplaceFieldTitle(),
                      workplaceField(),
                      birthdayFieldTitle(),
                      birthdayField(context),
                      genderFieldTitle(),
                      gendersField(),
                      saveButton(context)
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
    return PreferredSize(
      preferredSize: internetIsConnected == false
          ? Size.fromHeight(appbarHeight + noInternetAppBarContainerHeight)
          : Size.fromHeight(appbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            if (profileImageIsChanged == true ||
                nameTitleValueIsChanged == true ||
                firstNameIsChanged == true ||
                lastNameIsChanged == true ||
                licenseNumberTitleValueIsChanged == true ||
                licenseNumberIsChanged == true ||
                workplaceValueIsChanged == true ||
                birthdayTextIsChanged == true ||
                genderValueIsChanged == true) {
              await showDialog(
                context: context,
                builder: (context) {
                  return saveChangesConfirmationAlertDialog();
                },
              );
            } else {
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => NavBarPage(initialPage: 'Others_page'),
                ),
                (r) => false,
              );
            }
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: primaryColor,
            size: 24,
          ),
          iconSize: 24,
        ),
        title: Text(
          'แก้ไขโปรไฟล์',
          style: GoogleFonts.getFont(
            'Kanit',
            color: primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 21,
          ),
        ),
        bottom: internetIsConnected == false
            ? PreferredSize(
                preferredSize: Size.fromHeight(noInternetAppBarContainerHeight),
                child: Container(
                  height: noInternetAppBarContainerHeight,
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
        elevation: 0,
      ),
    );
  }

  Widget saveChangesConfirmationAlertDialog() {
    return AlertDialog(
      title: Text(
        'บันทึกการเปลี่ยนแปลง',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณต้องการบันทึกการเปลี่ยนแปลงโปรไฟล์ก่อนออกจากหน้านี้หรือไม่',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavBarPage(initialPage: 'Others_page'),
              ),
              (r) => false,
            );
          },
          child: Text(
            'ไม่บันทึก',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              await validateForm().then((value) async {
                if (validForm == true) {
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NavBarPage(initialPage: 'Others_page'),
                    ),
                    (r) => false,
                  );
                }
              });
            }
          },
          child: Text(
            'บันทึก',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
      ],
    );
  }

  Widget profileImage() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
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
              ),
              child: newProfileImageIsSelected == false
                  ? CachedNetworkImage(
                      imageUrl: profileImagePath,
                      placeholder: (context, url) =>
                          Center(child: SmallProgressIndicator()),
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      profileImageFile,
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
                newProfileImageIsSelected = true;
                profileImageIsChanged = true;
                profileImageFile = File(profileImage.path);
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
                newProfileImageIsSelected = true;
                profileImageIsChanged = true;
                profileImageFile = File(profileImage.path);
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

  Widget firstNameFieldTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
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
                color: validForm == false
                    ? emptyFirstName == true
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
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
                  if (value != nameTitle) {
                    setState(() {
                      nameTitleValueIsChanged = true;
                    });
                  } else {
                    setState(() {
                      nameTitleValueIsChanged = false;
                    });
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFormField(
                onChanged: (value) {
                  if (value != firstName) {
                    setState(() {
                      firstNameIsChanged = true;
                    });
                  } else {
                    setState(() {
                      firstNameIsChanged = false;
                    });
                  }

                  if (validForm == false) {
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
                      color: validForm == false
                          ? emptyFirstName == true
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
                color: validForm == false
                    ? emptyLastName == true
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
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
          if (value != lastName) {
            setState(() {
              lastNameIsChanged = true;
            });
          } else {
            setState(() {
              lastNameIsChanged = false;
            });
          }

          if (validForm == false) {
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
              color: validForm == false
                  ? emptyLastName == true
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

  Widget phoneNumberFieldTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePhoneNumberPageWidget(),
                  ),
                );
              },
              child: Text(
                'เปลี่ยน',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Color(0xFF7A7A7A),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
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
                    '+$callingCode',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: secondaryColor,
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
                readOnly: true,
                controller: phoneNumberTextFieldController,
                decoration: InputDecoration(
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
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: secondaryColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                keyboardType: TextInputType.number,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget passwordFieldTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPageWidget(
                      userDocumentID: userDocumentID,
                      userPassword: password,
                      userCallingCode: callingCode,
                      userPhoneNumber: phoneNumber,
                    ),
                  ),
                );
              },
              child: Text(
                'เปลี่ยนรหัสผ่าน',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Color(0xFF7A7A7A),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
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
        readOnly: true,
        controller: passwordTextFieldController,
        obscureText: !passwordTextFieldVisibility,
        decoration: InputDecoration(
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
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        style: GoogleFonts.getFont(
          'Kanit',
          color: secondaryColor,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget licenseNumberFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: Row(
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
                color: validForm == false
                    ? emptyLicenseNumber == true
                        ? snackBarRed
                        : Colors.transparent
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
                value: licenseNumberTitleValue,
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
                    licenseNumberTitleValue = value;
                  });
                  if (value != licenseNumberTitle) {
                    setState(() {
                      licenseNumberTitleValueIsChanged = true;
                    });
                  } else {
                    setState(() {
                      licenseNumberTitleValueIsChanged = false;
                    });
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFormField(
                onChanged: (value) {
                  if (value != licenseNumber) {
                    setState(() {
                      licenseNumberIsChanged = true;
                    });
                  } else {
                    setState(() {
                      licenseNumberIsChanged = false;
                    });
                  }

                  if (validForm == false) {
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
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: validForm == false
                          ? emptyLicenseNumber == true
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
              if (value != workplace) {
                setState(() {
                  workplaceValueIsChanged = true;
                });
              } else {
                setState(() {
                  workplaceValueIsChanged = false;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget birthdayFieldTitle() {
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

  Widget birthdayField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 8, 30, 0),
      child: TextFormField(
        onTap: () => DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          currentTime: chosenDate == null ? DateTime.now() : chosenDate,
          locale: LocaleType.th,
          onConfirm: (dateTime) {
            DateFormat dateFormat = DateFormat.yMd('th');
            setState(() {
              chosenDate = dateTime;
              birthdayText = dateFormat.format(chosenDate);
            });
            if (birthdayText != birthday) {
              setState(() {
                birthdayTextIsChanged = true;
              });
            } else {
              setState(() {
                birthdayTextIsChanged = false;
              });
            }
          },
        ),
        readOnly: true,
        decoration: InputDecoration(
            hintText: birthdayText == null ? 'เลือกวันเกิด' : birthdayText,
            hintStyle: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
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
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
        'เพศ',
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
      padding: EdgeInsets.only(left: 18, top: 8),
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
                  if (value != gender) {
                    setState(() {
                      genderValueIsChanged = true;
                    });
                  } else {
                    setState(() {
                      genderValueIsChanged = false;
                    });
                  }
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
                  if (value != gender) {
                    setState(() {
                      genderValueIsChanged = true;
                    });
                  } else {
                    setState(() {
                      genderValueIsChanged = false;
                    });
                  }
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
                  if (value != gender) {
                    setState(() {
                      genderValueIsChanged = true;
                    });
                  } else {
                    setState(() {
                      genderValueIsChanged = false;
                    });
                  }
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
                    print("radioButtonValue = $genderValue");
                  });
                  if (value != gender) {
                    setState(() {
                      genderValueIsChanged = true;
                    });
                  } else {
                    setState(() {
                      genderValueIsChanged = false;
                    });
                  }
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

  Widget saveButton(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.only(top: 20, bottom: 40),
        child: FFButtonWidget(
          onPressed: () async {
            if (profileImageIsChanged == true ||
                nameTitleValueIsChanged == true ||
                firstNameIsChanged == true ||
                lastNameIsChanged == true ||
                licenseNumberTitleValueIsChanged == true ||
                licenseNumberIsChanged == true ||
                workplaceValueIsChanged == true ||
                birthdayTextIsChanged == true ||
                genderValueIsChanged == true) {
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
            }
          },
          text: 'บันทึก',
          options: FFButtonOptions(
            width: 190,
            height: 49,
            color: profileImageIsChanged == true ||
                    nameTitleValueIsChanged == true ||
                    firstNameIsChanged == true ||
                    lastNameIsChanged == true ||
                    licenseNumberTitleValueIsChanged == true ||
                    licenseNumberIsChanged == true ||
                    workplaceValueIsChanged == true ||
                    birthdayTextIsChanged == true ||
                    genderValueIsChanged == true
                ? primaryColor
                : secondaryColor,
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

  Future<Null> validateForm() async {
    if (firstNameTextFieldController.text.isEmpty) {
      setState(() {
        emptyFirstName = true;
      });
    }

    if (lastNameTextFieldController.text.isEmpty) {
      setState(() {
        emptyLastName = true;
      });
    }

    if (licenseNumberTextFieldController.text.isEmpty) {
      setState(() {
        emptyLicenseNumber = true;
      });
    }

    if (emptyFirstName == true ||
        emptyLastName == true ||
        emptyLicenseNumber == true) {
      setState(() {
        validForm = false;
      });
    } else {
      setState(() {
        validForm = true;
      });
    }

    if (validForm == true) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ProgressDialog(title: 'กำลังอัปเดตข้อมูล'),
      );
      if (profileImageIsChanged == true) {
        await uploadProfileImage();
      } else {
        await updateUserProfile();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(emptyTextFieldSnackBar);
    }
  }

  Future<Null> uploadProfileImage() async {
    await Firebase.initializeApp();
    String imageFileName = '$userDocumentID.jpg';

    UploadTask task = FirebaseStorage.instance
        .ref()
        .child('therapistProfileImage/$imageFileName')
        .putFile(profileImageFile);

    await task.whenComplete(() async {
      await updateUserProfile();
    });
  }

  Future<Null> updateUserProfile() async {
    String imageFileName = '$userDocumentID.jpg';
    String profileImagePath = await FirebaseStorage.instance
        .ref()
        .child('therapistProfileImage/$imageFileName')
        .getDownloadURL();

    Map<String, dynamic> data = {};
    data['profileImage'] = profileImagePath;
    data['nameTitle'] = nameTitleValue;
    data['firstName'] = firstNameTextFieldController.text;
    data['lastName'] = lastNameTextFieldController.text;
    data['licenseNumberTitle'] = licenseNumberTitleValue;
    data['licenseNumber'] = licenseNumberTextFieldController.text;
    data['workplace'] = workplaceValue;
    data['birthday'] = Timestamp.fromDate(chosenDate);
    data['gender'] = genderValue;
    data['lastUpdate'] = Timestamp.now();

    await FirebaseFirestore.instance
        .collection('therapists')
        .doc(userDocumentID)
        .update(data)
        .then((value) async {
      setState(() {
        profileImageIsChanged = false;
        nameTitleValueIsChanged = false;
        firstNameIsChanged = false;
        lastNameIsChanged = false;
        licenseNumberTitleValueIsChanged = false;
        licenseNumberIsChanged = false;
        workplaceValueIsChanged = false;
        birthdayTextIsChanged = false;
        genderValueIsChanged = false;

        nameTitle = nameTitleValue;
        firstName = firstNameTextFieldController.text;
        lastName = lastNameTextFieldController.text;
        licenseNumberTitle = licenseNumberTitleValue;
        licenseNumber = licenseNumberTextFieldController.text;
        workplace = workplaceValue;
        birthday = birthdayText;
        gender = genderValue;
      });

      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(successfulUpdateSnackBar);
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
