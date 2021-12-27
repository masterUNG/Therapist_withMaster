import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/appointments_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'patient_page.dart';
import 'no_internet_connection_page.dart';

class ConfirmAppointmentPageWidget extends StatefulWidget {
  final String treatmentID;
  final DateTime chosenDate;
  final String appointmentDate;
  final DateTime chosenStartTime;
  final String appointmentStartTime;
  final DateTime chosenFinishTime;
  final String appointmentFinishTime;
  final String patientID;
  final String patientUserID;

  ConfirmAppointmentPageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.chosenDate,
      @required this.appointmentDate,
      @required this.chosenStartTime,
      @required this.appointmentStartTime,
      @required this.chosenFinishTime,
      @required this.appointmentFinishTime,
      @required this.patientID,
      @required this.patientUserID})
      : super(key: key);

  @override
  _ConfirmAppointmentPageWidgetState createState() =>
      _ConfirmAppointmentPageWidgetState();
}

class _ConfirmAppointmentPageWidgetState
    extends State<ConfirmAppointmentPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  DateTime chosenDate;
  String appointmentDate;
  DateTime chosenStartTime;
  String appointmentStartTime;
  DateTime chosenFinishTime;
  String appointmentFinishTime;
  String userDocumentID;
  String patientID;
  String patientUserID;

  @override
  void initState() {
    super.initState();
    treatmentID = widget.treatmentID;
    chosenDate = widget.chosenDate;
    appointmentDate = widget.appointmentDate;
    chosenStartTime = widget.chosenStartTime;
    appointmentStartTime = widget.appointmentStartTime;
    chosenFinishTime = widget.chosenFinishTime;
    appointmentFinishTime = widget.appointmentFinishTime;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
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

  final addedAppointmentSuccessfullySnackBar = SnackBar(
    content: Text(
      'เพิ่มการนัดหมายเรียบร้อยแล้ว',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dateFieldTitle(),
            dateContainer(),
            timeFieldTitle(),
            timeContainer(),
            confirmButton(context)
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
          'ยืนยันการนัดหมายคนไข้',
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

  Widget dateFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 25, 0, 8),
      child: Text(
        'วันที่',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget dateContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                appointmentDate,
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget timeFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 8),
      child: Text(
        'เวลา',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget timeContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '$appointmentStartTime  ถึง  $appointmentFinishTime น.',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget confirmButton(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: Padding(
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
              await addAppointment();
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
      ),
    );
  }

  Future<Null> addAppointment() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังเพิ่มการนัดหมาย'),
    );

    await Firebase.initializeApp().then((value) async {
      DateTime date =
          DateTime(chosenDate.year, chosenDate.month, chosenDate.day);
      DateTime startTime = DateTime(chosenDate.year, chosenDate.month,
          chosenDate.day, chosenStartTime.hour, chosenStartTime.minute);
      DateTime finishTime = DateTime(chosenDate.year, chosenDate.month,
          chosenDate.day, chosenFinishTime.hour, chosenFinishTime.minute);

      AppointmentsModel appointmentsModel = AppointmentsModel(
          date: Timestamp.fromDate(date),
          startTime: Timestamp.fromDate(startTime),
          finishTime: Timestamp.fromDate(finishTime),
          isActive: true,
          finishStatus: null,
          createdAt: Timestamp.now(),
          lastUpdate: null,
          deletedAt: null);
      Map<String, dynamic> data = appointmentsModel.toMap();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('appointments')
          .doc()
          .set(data)
          .then((value) async {
        await findUserDocumentID();
      });
    });
  }

  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    await addNotification();
  }

  Future<Null> addNotification() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) async {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());
        String therapistProfileImage = therapistsModel.profileImage;
        String therapistName =
            '${therapistsModel.nameTitle}${therapistsModel.firstName} ${therapistsModel.lastName}';

        PatientNotificationsModel patientNotificationsModel =
            PatientNotificationsModel(
                image: therapistProfileImage,
                title: 'การนัดหมายใหม่',
                body: '$therapistName ได้เพิ่มการนัดหมายใหม่',
                category: appointment,
                readAt: null,
                createdAt: Timestamp.now());
        Map<String, dynamic> data = patientNotificationsModel.toMap();

        await FirebaseFirestore.instance
            .collection('patientUsers')
            .doc(patientUserID)
            .collection('notifications')
            .doc()
            .set(data)
            .then((value) async {
          await sendNotification(therapistName);
        });
      });
    });
  }

  Future<Null> sendNotification(String therapistName) async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientID)
          .collection('tokens')
          .where('isActive', isEqualTo: true)
          .get()
          .then((value) async {
        List<String> tokens = [];

        for (var item in value.docs) {
          TokensModel tokensModel = TokensModel.fromMap(item.data());
          String token = tokensModel.token;
          tokens.add(token);
        }

        for (var item in tokens) {
          String token = item;
          String title = 'มีการนัดหมายใหม่';
          String body = '$therapistName ได้เพิ่มการนัดหมายใหม่';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(addedAppointmentSuccessfullySnackBar);
    await backToPatientPage();
  }

  Future backToPatientPage() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PatientPageWidget(),
      ),
      (r) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
