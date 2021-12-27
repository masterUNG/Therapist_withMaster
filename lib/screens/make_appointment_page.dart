import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'confirm_appointment_page.dart';
import 'no_internet_connection_page.dart';

class MakeAppointmentPageWidget extends StatefulWidget {
  final String treatmentID;
  final String patientID;
  final String patientUserID;

  MakeAppointmentPageWidget(
      {Key key, @required this.treatmentID, @required this.patientID,@required this.patientUserID})
      : super(key: key);

  @override
  _MakeAppointmentPageWidgetState createState() =>
      _MakeAppointmentPageWidgetState();
}

class _MakeAppointmentPageWidgetState extends State<MakeAppointmentPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String patientID;
  String patientUserID;
  DateTime chosenDate;
  String appointmentDate;
  DateTime chosenStartTime;
  String appointmentStartTime;
  DateTime chosenFinishTime;
  String appointmentFinishTime;
  bool validaForm;

  @override
  void initState() {
    super.initState();
    treatmentID = widget.treatmentID;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
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
            dateField(),
            timeFieldTitle(),
            timeField(),
            nextButton(context)
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
          'นัดหมายคนไข้',
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'วันที่',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุวันที่)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: validaForm == false
                    ? appointmentDate == null
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

  Widget dateField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        onTap: () => DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          currentTime: chosenDate == null ? DateTime.now() : chosenDate,
          minTime: DateTime.now(),
          locale: LocaleType.th,
          onConfirm: (dateTime) {
            DateFormat dateFormat = DateFormat.yMd('th');
            setState(() {
              chosenDate = dateTime;
              appointmentDate = dateFormat.format(chosenDate);
            });
          },
        ),
        readOnly: true,
        decoration: InputDecoration(
            hintText:
                appointmentDate == null ? 'เลือกวันนัดหมาย' : appointmentDate,
            hintStyle: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: validaForm == false
                    ? appointmentDate == null
                        ? snackBarRed
                        : secondaryColor
                    : secondaryColor,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'เวลา',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุเวลาให้ครบถ้วน)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: validaForm == false
                    ? appointmentStartTime == null ||
                            appointmentFinishTime == null
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
                currentTime: chosenStartTime == null
                    ? chosenFinishTime == null
                        ? DateTime.now()
                        : chosenFinishTime
                    : chosenStartTime,
                locale: LocaleType.th,
                onConfirm: (dateTime) {
                  DateFormat dateFormat = DateFormat.Hm();
                  setState(() {
                    chosenStartTime = dateTime;
                    appointmentStartTime = dateFormat.format(chosenStartTime);
                  });
                },
              ),
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  border: Border.all(
                    color: validaForm == false
                        ? appointmentStartTime == null
                            ? snackBarRed
                            : secondaryColor
                        : secondaryColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Text(
                        appointmentStartTime == null
                            ? 'เลือกเวลา'
                            : '$appointmentStartTime น.',
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                currentTime: chosenFinishTime == null
                    ? chosenStartTime == null
                        ? DateTime.now()
                        : chosenStartTime
                    : chosenFinishTime,
                locale: LocaleType.th,
                onConfirm: (dateTime) {
                  DateFormat dateFormat = DateFormat.Hm();
                  setState(() {
                    chosenFinishTime = dateTime;
                    appointmentFinishTime = dateFormat.format(chosenFinishTime);
                  });
                },
              ),
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  border: Border.all(
                    color: validaForm == false
                        ? appointmentFinishTime == null
                            ? snackBarRed
                            : secondaryColor
                        : secondaryColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Text(
                        appointmentFinishTime == null
                            ? 'เลือกเวลา'
                            : '$appointmentFinishTime น.',
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

  Future<Null> validateForm() async {
    if (appointmentDate == null ||
        appointmentStartTime == null ||
        appointmentFinishTime == null) {
      setState(() {
        validaForm = false;
      });
    } else {
      setState(() {
        validaForm = true;
      });
      await goToNextPage();
    }
  }

  Future<Null> goToNextPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmAppointmentPageWidget(
          treatmentID: treatmentID,
          chosenDate: chosenDate,
          appointmentDate: appointmentDate,
          chosenStartTime: chosenStartTime,
          appointmentStartTime: appointmentStartTime,
          chosenFinishTime: chosenFinishTime,
          appointmentFinishTime: appointmentFinishTime,
          patientID: patientID,
          patientUserID: patientUserID,
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
