import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'patient_page.dart';
import 'confirm_edit_appointment_page.dart';
import 'no_internet_connection_page.dart';

class EditAppointmentPageWidget extends StatefulWidget {
  final String treatmentID;
  final String appointmentID;
  final String appointmentDate;
  final DateTime chosenDate;
  final String appointmentStartTime;
  final DateTime chosenStartTime;
  final String appointmentFinishTime;
  final DateTime chosenFinishTime;
  final String patientID;
  final String patientUserID;

  EditAppointmentPageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.appointmentID,
      @required this.appointmentDate,
      @required this.chosenDate,
      @required this.appointmentStartTime,
      @required this.chosenStartTime,
      @required this.appointmentFinishTime,
      @required this.chosenFinishTime,
      @required this.patientID,
      @required this.patientUserID})
      : super(key: key);

  @override
  _EditAppointmentPageWidgetState createState() =>
      _EditAppointmentPageWidgetState();
}

class _EditAppointmentPageWidgetState extends State<EditAppointmentPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String appointmentID;
  DateTime chosenDate;
  DateTime chosenStartTime;
  DateTime chosenFinishTime;
  String appointmentDate;
  String appointmentStartTime;
  String appointmentFinishTime;
  String patientID;
  String patientUserID;
  String date;
  String startTime;
  String finishTime;
  bool appointmentDateIsChanged;
  bool appointmentStartTimeIsChanged;
  bool appointmentFinishTimeIsChanged;
  String userDocumentID;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    treatmentID = widget.treatmentID;
    appointmentID = widget.appointmentID;
    chosenDate = widget.chosenDate;
    chosenStartTime = widget.chosenStartTime;
    chosenFinishTime = widget.chosenFinishTime;
    appointmentDate = widget.appointmentDate;
    appointmentStartTime = widget.appointmentStartTime;
    appointmentFinishTime = widget.appointmentFinishTime;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
    date = widget.appointmentDate;
    startTime = widget.appointmentStartTime;
    finishTime = widget.appointmentFinishTime;
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

  final deletedAppointmentSuccessfullySnackBar = SnackBar(
    content: Text(
      'ลบการนัดหมายเรียบร้อยแล้ว',
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
      floatingActionButton: deleteAppointmentButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dateFieldTitle(),
            dateField(),
            timeFieldTitle(),
            timeField(),
            nextButton(context),
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
            if (appointmentDateIsChanged == true ||
                appointmentStartTimeIsChanged == true ||
                appointmentFinishTimeIsChanged == true) {
              await showDialog(
                context: context,
                builder: (context) {
                  return leaveEditingAppointmentConfirmationAlertDialog(
                      context);
                },
              );
            } else {
              Navigator.pop(context);
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
          'แก้ไขการนัดหมายคนไข้',
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
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget leaveEditingAppointmentConfirmationAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Text(
        'ละทิ้งการแก้ไขการนัดหมาย',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องการละทิ้งการแก้ไขการนัดหมายนี้',
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
            Navigator.pop(context);
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

  Widget dateField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        onTap: () => DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          currentTime: chosenDate,
          minTime: DateTime.now(),
          locale: LocaleType.th,
          onConfirm: (dateTime) {
            DateFormat dateFormat = DateFormat.yMd('th');
            setState(() {
              chosenDate = dateTime;
              date = dateFormat.format(chosenDate);
            });
            if (date != appointmentDate) {
              setState(() {
                appointmentDateIsChanged = true;
              });
            } else {
              setState(() {
                appointmentDateIsChanged = false;
              });
            }
          },
        ),
        readOnly: true,
        decoration: InputDecoration(
            hintText: date,
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

  Widget timeField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => DatePicker.showTimePicker(
                context,
                showTitleActions: true,
                showSecondsColumn: false,
                currentTime: chosenStartTime,
                locale: LocaleType.th,
                onConfirm: (dateTime) {
                  DateFormat dateFormat = DateFormat.Hm();
                  setState(() {
                    chosenStartTime = dateTime;
                    startTime = dateFormat.format(chosenStartTime);
                  });
                  if (startTime != appointmentStartTime) {
                    setState(() {
                      appointmentStartTimeIsChanged = true;
                    });
                  } else {
                    setState(() {
                      appointmentStartTimeIsChanged = false;
                    });
                  }
                },
              ),
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  border: Border.all(
                    color: secondaryColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Text(
                        '$startTime น.',
                        style: GoogleFonts.getFont(
                          'Kanit',
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 49,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ถึง',
                  textAlign: TextAlign.center,
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
          Expanded(
            child: GestureDetector(
              onTap: () => DatePicker.showTimePicker(
                context,
                showTitleActions: true,
                showSecondsColumn: false,
                currentTime: chosenFinishTime,
                locale: LocaleType.th,
                onConfirm: (dateTime) {
                  DateFormat dateFormat = DateFormat.Hm();
                  setState(() {
                    chosenFinishTime = dateTime;
                    finishTime = dateFormat.format(chosenFinishTime);
                  });
                  if (finishTime != appointmentFinishTime) {
                    setState(() {
                      appointmentFinishTimeIsChanged = true;
                    });
                  } else {
                    setState(() {
                      appointmentFinishTimeIsChanged = false;
                    });
                  }
                },
              ),
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  border: Border.all(
                    color: secondaryColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Text(
                        '$finishTime น.',
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
            ),
          )
        ],
      ),
    );
  }

  Widget nextButton(BuildContext context) {
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
              if (appointmentDateIsChanged == true ||
                  appointmentStartTimeIsChanged == true ||
                  appointmentFinishTimeIsChanged == true) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmEditAppointmentPageWidget(
                      treatmentID: treatmentID,
                      appointmentID: appointmentID,
                      appointmentDate: date,
                      chosenDate: chosenDate,
                      appointmentStartTime: startTime,
                      chosenStartTime: chosenStartTime,
                      appointmentFinishTime: finishTime,
                      chosenFinishTime: chosenFinishTime,
                      patientID: patientID,
                      patientUserID: patientUserID,
                    ),
                  ),
                );
              }
            }
          },
          text: 'ถัดไป',
          options: FFButtonOptions(
            width: 190,
            height: 49,
            color: appointmentDateIsChanged == true ||
                    appointmentStartTimeIsChanged == true ||
                    appointmentFinishTimeIsChanged == true
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

  Widget deleteAppointmentButton(BuildContext context) {
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
          await showDialog(
            context: context,
            builder: (alertDialogContext) {
              return deleteAppointmentConfirmationAlertDialog(
                  alertDialogContext, context);
            },
          );
        }
      },
      backgroundColor: Colors.white,
      elevation: 0,
      label: Text(
        'ลบการนัดหมาย',
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

  Widget deleteAppointmentConfirmationAlertDialog(
      BuildContext alertDialogContext, BuildContext context) {
    return AlertDialog(
      title: Text(
        'ยืนยันการลบการนัดหมาย',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องการลบการนัดหมายนี้',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(alertDialogContext),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(alertDialogContext);
            await deleteAppointment();
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

  Future<Null> deleteAppointment() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังลบการนัดหมาย'),
    );

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['isActive'] = false;
      data['finishStatus'] = 'deleted';
      data['deletedAt'] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('appointments')
          .doc(appointmentID)
          .update(data)
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
                title: 'การนัดหมายถูกลบ',
                body: '$therapistName ได้ลบการนัดหมาย',
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
          String title = 'การนัดหมายถูกลบ';
          String body = '$therapistName ได้ลบการนัดหมาย';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(deletedAppointmentSuccessfullySnackBar);
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
