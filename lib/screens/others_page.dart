import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/progress_indicator_no_dialog.dart';
import 'edit_profile_page.dart';
import 'treatments_history_page.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'no_internet_connection_page.dart';

class OthersPageWidget extends StatefulWidget {
  OthersPageWidget({Key key}) : super(key: key);

  @override
  _OthersPageWidgetState createState() => _OthersPageWidgetState();
}

class _OthersPageWidgetState extends State<OthersPageWidget> {
  var subscription;
  bool internetIsConnected;
  String userDocumentID;
  String profileImage;
  int notificationNumber;
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    readDataSharedPreferences();
    readUserProfileImage();
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

  Future<Null> readDataSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
  }

  Future<Null> readUserProfileImage() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) async {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());
        setState(() {
          profileImage = therapistsModel.profileImage;
          readDataIsFinished = true;
        });
      });
    });
    await readNotifications();
  }

  Future<Null> readNotifications() async {
    await Firebase.initializeApp().then((value) {
      FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .collection('notifications')
          .where('readAt', isNull: true)
          .snapshots()
          .listen((event) {
        setState(() {
          notificationNumber = event.docs.length;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: readDataIsFinished == true
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  editProfileButton(context),
                  treatmentsHistoryButton(context),
                  settingsButton(context),
                  logoutButton(context)
                ],
              )
            : Center(
                child: SmallProgressIndicator(),
              ),
      ),
    );
  }

  Widget appBar() {
    double noInternetContainerHeight = 30.0;

    return PreferredSize(
      preferredSize: internetIsConnected == false
          ? Size.fromHeight(appbarHeight + noInternetContainerHeight)
          : Size.fromHeight(appbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        title: Text(
          'TherapistBuddy',
          style: GoogleFonts.getFont(
            'Raleway',
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
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
                        builder: (context) => NotificationsPageWidget(),
                      ),
                    );
                  }
                },
                icon: notificationNumber == null
                    ? Icon(
                        Icons.notifications_none,
                        color: primaryColor,
                        size: 25,
                      )
                    : notificationNumber == 0
                        ? Icon(
                            Icons.notifications_none,
                            color: primaryColor,
                            size: 25,
                          )
                        : Stack(
                            alignment: Alignment(0, 0),
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: primaryColor,
                                size: 25,
                              ),
                              Align(
                                alignment: Alignment(1, -1),
                                child: Container(
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: snackBarRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    notificationNumber > 9
                                        ? '9+'
                                        : '$notificationNumber',
                                    style: GoogleFonts.getFont(
                                      'Kanit',
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
              );
            },
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget editProfileButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GestureDetector(
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
                builder: (context) => EditProfilePageWidget(),
              ),
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 73,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: Color(0x3F000000),
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 9, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: profileImage == null
                      ? Container(
                          width: 61,
                          height: 61,
                          child: Image.asset(
                            'assets/images/profileDefault_rectangle.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: profileImage,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/profileDefault_rectangle.png',
                            width: 61,
                            height: 61,
                            fit: BoxFit.cover,
                          ),
                          width: 61,
                          height: 61,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Text(
                'แก้ไขโปรไฟล์ของคุณ',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget treatmentsHistoryButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GestureDetector(
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
                builder: (context) => TreatmentsHistoryPageWidget(),
              ),
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 73,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: Color(0x3F000000),
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(9, 0, 15, 0),
                child: Container(
                  width: 61,
                  height: 61,
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/healthHistory_icon.png',
                        width: 37,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
              Text(
                'ประวัติการรักษาคนไข้',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget settingsButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GestureDetector(
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
                builder: (context) => SettingsPageWidget(),
              ),
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 73,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: Color(0x3F000000),
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(9, 0, 15, 0),
                child: Container(
                  width: 61,
                  height: 61,
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/settings_icon.png',
                        width: 34,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
              Text(
                'การตั้งค่า',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget logoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GestureDetector(
        onTap: () async {
          if (internetIsConnected == false) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoInternetConnectionPageWidget(),
              ),
            );
          } else {
            await showDialog(
              context: context,
              builder: (alertDialogContext) {
                return logoutConfirmationAlertDialog(context);
              },
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 73,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: Color(0x3F000000),
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(9, 0, 15, 0),
                child: Container(
                  width: 61,
                  height: 61,
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logout_icon.png',
                        width: 32,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
              Text(
                'ออกจากระบบ',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget logoutConfirmationAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Text(
        'ออกจากระบบ',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ',
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
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              // หากผู้ใช้กดยืนยันให้ปิด AlertDialog, ล้างค่าข้อมูลใน SharedPreferences, disable token นี้,
              // และ navigate ไปยังหน้า LoginPage
              Navigator.pop(context);

              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ProgressIndicatorNoDialog(),
              );

              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              String userDocumentID =
                  sharedPreferences.getString('userDocumentID');
              sharedPreferences
                  .clear()
                  .then((value) => disableThisToken(userDocumentID));

              // ตรวจสอบว่าค่า phoneNumber ใน SharedPreferences ยังมีอยู่หรือไม่
              print('userDocumentID = $userDocumentID');
            }
          },
          child: Text(
            'ยืนยัน',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
      ],
    );
  }

  // disable token นี้หาก token นี้มีอยู่ในฐานข้อมูล
  Future<Null> disableThisToken(String userDocumentID) async {
    String token = await FirebaseMessaging.instance.getToken();
    print('token = $token');

    await Firebase.initializeApp().then((value) {
      FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .collection('tokens')
          .where('token', isEqualTo: token)
          .get()
          .then((value) async {
        // หาก token นี้มีในฐานข้อมูลให้ update ค่า isActive เป็น false พร้อมระบุเวลา
        if (value.docs.length != 0) {
          print('token นี้มีในฐานข้อมูล');
          for (var item in value.docs) {
            String tokenDocumentID = item.id;
            print('tokenDocumentID = $tokenDocumentID');

            Map<String, dynamic> data = {};
            data['isActive'] = false;
            data['lastUpdate'] = Timestamp.now();

            await FirebaseFirestore.instance
                .collection('therapists')
                .doc(userDocumentID)
                .collection('tokens')
                .doc(tokenDocumentID)
                .update(data)
                .then(
              (value) {
                // หาก update ข้อมูลเสร็จแล้วให้ navigate ไปยัง LoginPageWidget
                print('Update token successfully');

                return Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPageWidget(),
                  ),
                  (r) => false,
                );
              },
            );
          }
        } else {
          // ถ้า token นี้ไม่มีในฐานข้อมูลให้ navigate ไปยัง LoginPageWidget
          print('token นี้ไม่มีในฐานข้อมูล');

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPageWidget(),
            ),
            (r) => false,
          );
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
