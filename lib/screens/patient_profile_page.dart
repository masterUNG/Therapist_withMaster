import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import '../widgets/info_container.dart';

class PatientProfilePageWidget extends StatefulWidget {
  final String patientUserProfileImage;
  final String patientUserFirstName;
  final String patientUserLastName;
  final int patientUserAge;

  PatientProfilePageWidget(
      {Key key,
      @required this.patientUserProfileImage,
      @required this.patientUserFirstName,
      @required this.patientUserLastName,
      @required this.patientUserAge})
      : super(key: key);

  @override
  _PatientProfilePageWidgetState createState() =>
      _PatientProfilePageWidgetState();
}

class _PatientProfilePageWidgetState extends State<PatientProfilePageWidget> {
  var subscription;
  bool internetIsConnected;
  String patientUserProfileImage;
  String patientUserFirstName;
  String patientUserLastName;
  int patientUserAge;

  @override
  void initState() {
    super.initState();
    patientUserProfileImage = widget.patientUserProfileImage;
    patientUserFirstName = widget.patientUserFirstName;
    patientUserLastName = widget.patientUserLastName;
    patientUserAge = widget.patientUserAge;
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
        child: Column(
          children: [
            profileImageArea(),
            InfoContainer(
                title: 'ชื่อ',
                info: '$patientUserFirstName $patientUserLastName'),
            InfoContainer(title: 'อายุ', info: '$patientUserAge ปี'),
          ],
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
          'ข้อมูลโปรไฟล์คนไข้',
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
        elevation: 2,
      ),
    );
  }

  Widget profileImageArea() {
    return Stack(
      alignment: Alignment(0, 0),
      children: [
        Align(
          alignment: Alignment(0, 0),
          child: Image.asset(
            'assets/images/patientUserProfile_background.jpg',
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment(0, 0),
          child: Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: Color(0x73494949),
            ),
          ),
        ),
        Align(
          alignment: Alignment(0, 0),
          child: CachedNetworkImage(
            imageUrl: patientUserProfileImage,
            placeholder: (context, url) => Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/profileDefault_circle.png',
                fit: BoxFit.cover,
              ),
            ),
            imageBuilder: (context, imageProvider) => Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
