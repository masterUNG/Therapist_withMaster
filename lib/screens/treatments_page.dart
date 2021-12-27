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
import 'package:dio/dio.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/present_treatments_list_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/appointments_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/diseases_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/progress_indicator_no_dialog.dart';
import 'patient_page.dart';
import 'notifications_page.dart';
import 'no_internet_connection_page.dart';

class TreatmentsPageWidget extends StatefulWidget {
  TreatmentsPageWidget({Key key}) : super(key: key);

  @override
  _TreatmentsPageWidgetState createState() => _TreatmentsPageWidgetState();
}

class _TreatmentsPageWidgetState extends State<TreatmentsPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController searchTextController;
  String userDocumentID;
  List<PresentTreatmentsListModel> presentTreatmentsListModel = [];
  List<PresentTreatmentsListModel> filteredPresentTreatmentsListModel = [];
  int notificationNumber;
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    searchTextController = TextEditingController();
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    findUserDocumentID();
    readTreatments();
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

  // ดึงค่า userDocumentID ใน sharedPreferences
  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
  }

  // อ่านการรักษาปัจจุบันที่มีอยู่และเพิ่มข้อมูลการรักษานั้นไปยัง presentTreatmentsListModel
  Future<Null> readTreatments() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .where('therapistID', isEqualTo: userDocumentID)
          .where('isActive', isEqualTo: true)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          String treatmentID = item.id;
          TreatmentsModel treatmentsModel =
              TreatmentsModel.fromMap(item.data());

          await FirebaseFirestore.instance
              .collection('patientUsers')
              .doc(treatmentsModel.patientUserID)
              .get()
              .then((value) async {
            PatientUsersModel patientUserModel =
                PatientUsersModel.fromMap(value.data());

            await FirebaseFirestore.instance
                .collection('treatments')
                .doc(treatmentID)
                .collection('assignedExercisesList')
                .get()
                .then((value) async {
              List<DiseasesModel> diseasesModel = [];
              List<String> diseases = [];

              for (var item in value.docs) {
                String assignedExercisesListID = item.id;

                await FirebaseFirestore.instance
                    .collection('treatments')
                    .doc(treatmentID)
                    .collection('assignedExercisesList')
                    .doc(assignedExercisesListID)
                    .get()
                    .then((value) async {
                  AssignedExercisesListModel assignedExercisesListModel =
                      AssignedExercisesListModel.fromMap(value.data());

                  if (diseasesModel
                          .where((diseasesModel) =>
                              diseasesModel.disease ==
                              assignedExercisesListModel.disease)
                          .length ==
                      0) {
                    DiseasesModel model = DiseasesModel(
                        disease: assignedExercisesListModel.disease,
                        createdAt: assignedExercisesListModel.createdAt);

                    diseasesModel.add(model);
                  }
                });
              }
              diseasesModel.sort((a, b) {
                return a.createdAt.compareTo(b.createdAt);
              });

              for (var item in diseasesModel) {
                diseases.add(item.disease);
              }

              String diseasesText = diseases.join(', ');
              Timestamp appointmentDate;

              await FirebaseFirestore.instance
                  .collection('treatments')
                  .doc(treatmentID)
                  .collection('appointments')
                  .where('isActive', isEqualTo: true)
                  .get()
                  .then((value) async {
                for (var item in value.docs) {
                  AppointmentsModel appointmentsModel =
                      AppointmentsModel.fromMap(item.data());
                  appointmentDate = appointmentsModel.date;
                }

                PresentTreatmentsListModel model = PresentTreatmentsListModel(
                    treatmentID: treatmentID,
                    patientID: treatmentsModel.patientID,
                    patientUserID: treatmentsModel.patientUserID,
                    patientUserProfileImage: patientUserModel.profileImage,
                    patientUserFirstName: patientUserModel.firstName,
                    patientUserLastName: patientUserModel.lastName,
                    diseases: diseasesText,
                    appointmentDate: appointmentDate,
                    treatmentStartDate: treatmentsModel.startDate);

                presentTreatmentsListModel.add(model);
              });
            });
          });
        }
        // หากอ่านการรักษาปัจจุบันเสร็จเรียบร้อยแล้วให้เรียงข้อมูลใน presentTreatmentsListModel ใหม่
        // และเปลี่ยนค่า readTreatmentsIsFinished เป็น true
        presentTreatmentsListModel.sort((a, b) {
          return b.treatmentStartDate
              .toDate()
              .compareTo(a.treatmentStartDate.toDate());
        });
        setState(() {
          filteredPresentTreatmentsListModel = presentTreatmentsListModel;
          readDataIsFinished = true;
        });
      });
    });
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

  final cancelTreatmentSuccessfullySnackBar = SnackBar(
    content: Text(
      'ยกเลิกการรักษาเรียบร้อยแล้ว',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: defaultGreen,
  );

//  ทำการ refresh ข้อมูลหน้านี้
  Future<void> refreshPage() async {
    if (internetIsConnected == true) {
      presentTreatmentsListModel.clear();
      filteredPresentTreatmentsListModel.clear();
      await readTreatments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: readDataIsFinished == true
            ? presentTreatmentsListModel.length == 0
                ? RefreshIndicator(
                    onRefresh: refreshPage,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom -
                              appbarHeight -
                              bottomNavigationBarHeight,
                          child: Center(
                            child: Text(
                              'ไม่มีการรักษา ณ ขณะนี้',
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: Color(0xFFA7A8AF),
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refreshPage,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        GestureDetector(
                          onTap: () => FocusScope.of(context)
                              .requestFocus(FocusScopeNode()),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              searchAreaContainer(),
                              titleContainer(),
                              patientsList(context)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
            : Center(
                child: SmallProgressIndicator(),
              ),
      ),
    );
  }

  Widget appBar() {
    return PreferredSize(
      preferredSize: internetIsConnected == false
          ? Size.fromHeight(appbarHeight + noInternetAppBarContainerHeight)
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

  Widget searchAreaContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Container(
              width: double.infinity,
              height: 41,
              child: TextFormField(
                onChanged: (value) {
                  setState(() {});
                  filteredPresentTreatmentsListModel = presentTreatmentsListModel
                      .where((presentTreatmentsListModel) =>
                          '${presentTreatmentsListModel.patientUserFirstName} ${presentTreatmentsListModel.patientUserLastName}'
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                },
                controller: searchTextController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'ค้นหา',
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: Color(0xFFA7A8AF),
                    fontSize: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF0F2F5),
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 20,
                  ),
                  suffixIcon: searchTextController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              searchTextController.clear();
                            });
                            filteredPresentTreatmentsListModel =
                                presentTreatmentsListModel
                                    .where((presentTreatmentsListModel) =>
                                        '${presentTreatmentsListModel.patientUserFirstName} ${presentTreatmentsListModel.patientUserLastName}'
                                            .toLowerCase()
                                            .contains(searchTextController.text
                                                .toLowerCase()))
                                    .toList();
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.black,
                            size: 22,
                          ),
                        )
                      : null,
                ),
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget titleContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 12, 0),
              child: Icon(
                Icons.perm_identity_rounded,
                color: primaryColor,
                size: 24,
              ),
            ),
            Text(
              'การรักษาปัจจุบัน (${presentTreatmentsListModel.length})',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget patientsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredPresentTreatmentsListModel.length,
      itemBuilder: (context, index) => patientContainer(
          context, index, filteredPresentTreatmentsListModel[index]),
    );
  }

  Widget patientContainer(BuildContext context, int index,
      PresentTreatmentsListModel filteredPresentTreatmentsListModel) {
    String appointmentDate;
    if (filteredPresentTreatmentsListModel.appointmentDate != null) {
      appointmentDate = DateFormat.yMd('th')
          .format(filteredPresentTreatmentsListModel.appointmentDate.toDate());
    }
    String treatmentStartDate = DateFormat.yMd('th')
        .format(filteredPresentTreatmentsListModel.treatmentStartDate.toDate());
    DateTime now = DateTime.now();
    String todayDateText =
        DateFormat.yMd('th').format(DateTime(now.year, now.month, now.day));

    return Column(
      children: [
        Stack(
          alignment: Alignment(1, -0.85),
          children: [
            GestureDetector(
              onTap: () async {
                if (internetIsConnected == false) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoInternetConnectionPageWidget(),
                    ),
                  );
                } else {
                  await goToPatientPage(
                      filteredPresentTreatmentsListModel.treatmentID);
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          imageUrl: filteredPresentTreatmentsListModel
                              .patientUserProfileImage,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/profileDefault_rectangle.png',
                            fit: BoxFit.cover,
                          ),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${filteredPresentTreatmentsListModel.patientUserFirstName} ${filteredPresentTreatmentsListModel.patientUserLastName}',
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
                                    'โรค',
                                    style: GoogleFonts.getFont(
                                      'Kanit',
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Colon(),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        filteredPresentTreatmentsListModel
                                                .diseases.isEmpty
                                            ? '-'
                                            : filteredPresentTreatmentsListModel
                                                .diseases,
                                        style: GoogleFonts.getFont(
                                          'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'นัดหมาย',
                                    style: GoogleFonts.getFont(
                                      'Kanit',
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Colon(),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        appointmentDate == null
                                            ? '-'
                                            : appointmentDate == todayDateText
                                                ? 'วันนี้'
                                                : appointmentDate,
                                        style: GoogleFonts.getFont(
                                          'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'เริ่มการรักษา',
                                    style: GoogleFonts.getFont(
                                      'Kanit',
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Colon(),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        treatmentStartDate == todayDateText
                                            ? 'วันนี้'
                                            : treatmentStartDate,
                                        style: GoogleFonts.getFont(
                                          'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'cancelTreatment',
                    child: Text(
                      'ยกเลิกการักษา',
                      style: GoogleFonts.getFont(
                        'Kanit',
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (String value) async {
                if (internetIsConnected == false) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoInternetConnectionPageWidget(),
                    ),
                  );
                } else {
                  return popupMenuButtonActions(
                      value,
                      filteredPresentTreatmentsListModel.treatmentID,
                      filteredPresentTreatmentsListModel.patientID,
                      filteredPresentTreatmentsListModel.patientUserID);
                }
              },
            ),
          ],
        ),
        index != this.filteredPresentTreatmentsListModel.length - 1
            ? Divider(
                height: 2,
                thickness: 2,
                color: Color(0xFFF5F5F5),
              )
            : Container(),
      ],
    );
  }

//  ไปยังหน้า patientPage
  Future<Null> goToPatientPage(String treatmentID) async {
    // ก่อนที่จะไปยังหน้า patientPage ให้ set ค่า treatmentID ไปยัง SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('treatmentID', treatmentID).then((value) async {
      // เมื่อ set ค่า treatmentID ไปยัง SharedPreferences เรียบร้อยแล้วให้ navigate ไปยังหน้า PatientPageWidget
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientPageWidget(),
        ),
      );
    });
  }

  void popupMenuButtonActions(String value, String treatmentID,
      String patientID, String patientUserID) {
    if (value == "cancelTreatment") {
      showDialog(
        context: context,
        builder: (alertDialogContext) {
          return AlertDialog(
            title: Text(
              'ยืนยันการยกเลิกการรักษา',
              style: GoogleFonts.getFont(
                'Kanit',
              ),
            ),
            content: Text(
              'เมื่อยกเลิกการรักษาแล้วจะไม่สามารถเรียกคืนการรักษานี้ได้อีก คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการรักษานี้',
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
                  if (internetIsConnected == false) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoInternetConnectionPageWidget(),
                      ),
                    );
                  } else {
                    await cancelTreatment(
                        treatmentID, patientID, patientUserID);
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
        },
      );
    }
  }

  // ยกเลิกการรักษา
  Future<Null> cancelTreatment(
      String treatmentID, String patientID, String patientUserID) async {
    // ระหว่างยกเลิกการรักษาให้แสดง ProgressIndicatorNoDialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressIndicatorNoDialog(),
    );

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['isActive'] = false;
      data['finishStatus'] = 'canceled';
      data['finishDate'] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .update(data)
          .then((value) async {
        await addNotification(patientID, patientUserID);
      });
    });
  }

  Future<Null> addNotification(String patientID, String patientUserID) async {
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
                title: 'การรักษาถูกยกเลิก',
                body: 'การรักษาของคุณกับ $therapistName ถูกยกเลิก',
                category: previousTreatment,
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
          await sendNotification(patientID, therapistName);
        });
      });
    });
  }

  Future<Null> sendNotification(String patientID, String therapistName) async {
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
          String title = 'การรักษาถูกยกเลิก';
          String body = 'การรักษาของคุณกับ $therapistName ถูกยกเลิก';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    // เมื่อยกเลิกการรักษาเรียบร้อยแล้วให้ทำการ readTreatments ใหม่,
    // ปิด ProgressIndicatorNoDialog และแสดง cancelTreatmentSuccessfullySnackBar
    searchTextController.clear();
    presentTreatmentsListModel.clear();
    filteredPresentTreatmentsListModel.clear();
    readDataIsFinished = false;
    readTreatments();

    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(cancelTreatmentSuccessfullySnackBar);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
