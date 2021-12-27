import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/appointments_list_model.dart';
import 'package:therapist_buddy/models/appointments_model.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'appointment_page.dart';
import 'no_internet_connection_page.dart';

class AllAppointmentsPageWidget extends StatefulWidget {
  AllAppointmentsPageWidget({Key key}) : super(key: key);

  @override
  _AllAppointmentsPageWidgetState createState() =>
      _AllAppointmentsPageWidgetState();
}

class _AllAppointmentsPageWidgetState extends State<AllAppointmentsPageWidget> {
  var subscription;
  bool internetIsConnected;
  String userDocumentID;
  String therapistWorkplace;
  List<AppointmentsListModel> appointmentsListModel = [];
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    findUserDocumentID();
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

  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
    await readTherapistWorkPlace();
  }

  Future<Null> readTherapistWorkPlace() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) async {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());
        therapistWorkplace = therapistsModel.workplace;

        await readAppointments();
      });
    });
  }

  Future<Null> readAppointments() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .where('therapistID', isEqualTo: userDocumentID)
          .where('isActive', isEqualTo: true)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          TreatmentsModel treatmentsModel =
              TreatmentsModel.fromMap(item.data());
          String patientUserID = treatmentsModel.patientUserID;

          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(item.id)
              .collection('appointments')
              .where('isActive', isEqualTo: true)
              .get()
              .then((value) async {
            for (var item in value.docs) {
              AppointmentsModel appointmentsModel =
                  AppointmentsModel.fromMap(item.data());

              await FirebaseFirestore.instance
                  .collection('patientUsers')
                  .doc(patientUserID)
                  .get()
                  .then((value) async {
                PatientUsersModel patientUsersModel =
                    PatientUsersModel.fromMap(value.data());

                AppointmentsListModel model = AppointmentsListModel(
                    patientProfileImage: patientUsersModel.profileImage,
                    patientFirstName: patientUsersModel.firstName,
                    patientLastName: patientUsersModel.lastName,
                    appointmentDate: appointmentsModel.date,
                    appointmentStartTime: appointmentsModel.startTime,
                    appointmentFinishTime: appointmentsModel.finishTime,
                    appointmentPlace: therapistWorkplace);
                appointmentsListModel.add(model);
              });
            }
          });
        }
        appointmentsListModel.sort((a, b) {
          return a.appointmentStartTime.compareTo(b.appointmentStartTime);
        });
        setState(() {
          readDataIsFinished = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: readDataIsFinished == true
            ? appointmentsListModel.length == 0
                ? Center(
                    child: Text(
                      'ไม่มีการนัดหมาย',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Color(0xFFA7A8AF),
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: appointmentsListModel.length,
                    itemBuilder: (context, index) => appointmentContainer(
                        context, index, appointmentsListModel[index]),
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
          'การนัดหมายทั้งหมด',
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

  Widget appointmentContainer(BuildContext context, int index,
      AppointmentsListModel appointmentsListModel) {
    String appointmentDate = DateFormat.yMd('th')
        .format(appointmentsListModel.appointmentDate.toDate());
    String startTime = DateFormat.Hm()
        .format(appointmentsListModel.appointmentStartTime.toDate());
    String finishTime = DateFormat.Hm()
        .format(appointmentsListModel.appointmentFinishTime.toDate());

    return GestureDetector(
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
              builder: (context) => AppointmentPageWidget(
                appointmentsListModel: appointmentsListModel,
              ),
            ),
          );
        }
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      imageUrl: appointmentsListModel.patientProfileImage,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/profileDefault_rectangle.png',
                        fit: BoxFit.cover,
                      ),
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${appointmentsListModel.patientFirstName} ${appointmentsListModel.patientLastName}',
                            style: GoogleFonts.getFont(
                              'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                'วันที่',
                                style: GoogleFonts.getFont(
                                  'Kanit',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Colon(),
                              Container(
                                child: Text(
                                  appointmentDate,
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'เวลา',
                                style: GoogleFonts.getFont(
                                  'Kanit',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Colon(),
                              Text(
                                '$startTime - $finishTime น.',
                                style: GoogleFonts.getFont(
                                  'Kanit',
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE5E5E5),
            ),
          ],
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
