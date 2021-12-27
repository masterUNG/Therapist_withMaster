import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import '../widgets/info_container.dart';

class TreatmentInfoPageWidget extends StatefulWidget {
  final String patientUserFirstName;
  final String patientUserLastName;
  final String diseases;
  final String startDate;
  final String finishDate;
  final String finishStatus;

  const TreatmentInfoPageWidget(
      {Key key,
      @required this.patientUserFirstName,
      @required this.patientUserLastName,
      @required this.diseases,
      @required this.startDate,
      @required this.finishDate,
      @required this.finishStatus})
      : super(key: key);

  @override
  _TreatmentInfoPageWidgetState createState() =>
      _TreatmentInfoPageWidgetState();
}

class _TreatmentInfoPageWidgetState extends State<TreatmentInfoPageWidget> {
  var subscription;
  bool internetIsConnected;
  String patientUserFirstName;
  String patientUserLastName;
  String diseases;
  String startDate;
  String finishDate;
  String finishStatus;

  @override
  void initState() {
    super.initState();
    patientUserFirstName = widget.patientUserFirstName;
    patientUserLastName = widget.patientUserLastName;
    diseases = widget.diseases;
    startDate = widget.startDate;
    finishDate = widget.finishDate;
    finishStatus = widget.finishStatus;
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              InfoContainer(
                  title: 'ชื่อคนไข้',
                  info: '$patientUserFirstName $patientUserLastName'),
              InfoContainer(
                  title: 'โรคที่ทำการรักษา',
                  info: diseases.isEmpty ? '-' : diseases),
              InfoContainer(title: 'วันที่เริ่มทำการรักษา', info: startDate),
              InfoContainer(
                  title: 'วันที่เสร็จสิ้นการรักษา',
                  info: finishDate == null ? '-' : finishDate),
              treatmentStatusContainer(),
            ],
          ),
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
          'ข้อมูลการรักษา',
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

  Widget treatmentStatusContainer() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สถานะการรักษา',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    finishStatus == null ? 'อยู่ระหว่างการรักษา' : finishStatus,
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: finishStatus == null
                          ? Colors.black
                          : finishStatus == 'สำเร็จการรักษา'
                              ? defaultGreen
                              : defaultRed,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE5E5E5),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
