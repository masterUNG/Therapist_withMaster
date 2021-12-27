import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/diseases_model.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/previous_treatments_model.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'patient_in_previous_treatment_page.dart';
import 'no_internet_connection_page.dart';

class TreatmentsHistoryPageWidget extends StatefulWidget {
  TreatmentsHistoryPageWidget({Key key}) : super(key: key);

  @override
  _TreatmentsHistoryPageWidgetState createState() =>
      _TreatmentsHistoryPageWidgetState();
}

class _TreatmentsHistoryPageWidgetState
    extends State<TreatmentsHistoryPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController searchTextController;
  String userDocumentID;
  List<PreviousTreatmentsModel> previousTreatmentsModel = [];
  List<PreviousTreatmentsModel> filteredPreviousTreatmentsModel = [];
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
    await readPreviousTreatments();
  }

  Future<Null> readPreviousTreatments() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .where('therapistID', isEqualTo: userDocumentID)
          .where('isActive', isEqualTo: false)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          String treatmentID = item.id;
          String patientUserID;
          String patientProfileImage;
          String patientFirstName;
          String patientLastName;
          List<String> patientDiseases = [];
          Timestamp treatmentStartDate;
          Timestamp treatmentFinishDate;
          String finishStatus;

          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(treatmentID)
              .get()
              .then((value) async {
            TreatmentsModel treatmentsModel =
                TreatmentsModel.fromMap(value.data());
            patientUserID = treatmentsModel.patientUserID;
            treatmentStartDate = treatmentsModel.startDate;
            treatmentFinishDate = treatmentsModel.finishDate;
            finishStatus = treatmentsModel.finishStatus;

            await FirebaseFirestore.instance
                .collection('treatments')
                .doc(treatmentID)
                .collection('assignedExercisesList')
                .get()
                .then((value) async {
              List<DiseasesModel> diseasesModel = [];

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
                patientDiseases.add(item.disease);
              }
            });
          });
          await Firebase.initializeApp().then((value) async {
            await FirebaseFirestore.instance
                .collection('patientUsers')
                .doc(patientUserID)
                .get()
                .then((value) async {
              PatientUsersModel patientUsersModel =
                  PatientUsersModel.fromMap(value.data());
              patientProfileImage = patientUsersModel.profileImage;
              patientFirstName = patientUsersModel.firstName;
              patientLastName = patientUsersModel.lastName;
            });
          });
          PreviousTreatmentsModel model = PreviousTreatmentsModel(
              treatmentID: treatmentID,
              patientProfileImage: patientProfileImage,
              patientFirstName: patientFirstName,
              patientLastName: patientLastName,
              patientDiseases: patientDiseases,
              treatmentStartDate: treatmentStartDate,
              treatmentFinishDate: treatmentFinishDate,
              finishStatus: finishStatus);
          previousTreatmentsModel.add(model);
        }
      });
    });
    previousTreatmentsModel.sort((a, b) {
      return b.treatmentFinishDate.compareTo(a.treatmentFinishDate);
    });

    setState(() {
      filteredPreviousTreatmentsModel = previousTreatmentsModel;
      readDataIsFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: readDataIsFinished == true
            ? previousTreatmentsModel.length == 0
                ? Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        appbarHeight -
                        bottomNavigationBarHeight,
                    child: Center(
                      child: Text(
                        'ไม่มีการรักษาก่อนหน้านี้',
                        style: GoogleFonts.getFont(
                          'Kanit',
                          color: Color(0xFFA7A8AF),
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: GestureDetector(
                      onTap: () =>
                          FocusScope.of(context).requestFocus(FocusScopeNode()),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          searchAreaContainer(),
                          titleContainer(),
                          patientsList(context),
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
          'ประวัติการรักษาคนไข้',
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
                  filteredPreviousTreatmentsModel = previousTreatmentsModel
                      .where((previousTreatmentsModel) =>
                          '${previousTreatmentsModel.patientFirstName} ${previousTreatmentsModel.patientLastName}'
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
                            filteredPreviousTreatmentsModel =
                                previousTreatmentsModel
                                    .where((previousTreatmentsModel) =>
                                        '${previousTreatmentsModel.patientFirstName} ${previousTreatmentsModel.patientLastName}'
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
            'ประวัติการรักษาทั้งหมด (${previousTreatmentsModel.length})',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }

  Widget patientsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredPreviousTreatmentsModel.length,
      itemBuilder: (context, index) =>
          patientContainer(context, filteredPreviousTreatmentsModel[index]),
    );
  }

  Widget patientContainer(BuildContext context,
      PreviousTreatmentsModel filteredPreviousTreatmentsModel) {
    String patientDiseases =
        filteredPreviousTreatmentsModel.patientDiseases.join(', ');
    String treatmentStartDate = DateFormat.yMd('th')
        .format(filteredPreviousTreatmentsModel.treatmentStartDate.toDate());
    String treatmentFinishDate = DateFormat.yMd('th')
        .format(filteredPreviousTreatmentsModel.treatmentFinishDate.toDate());
    String finishStatus;
    if (filteredPreviousTreatmentsModel.finishStatus == 'completed') {
      finishStatus = 'สำเร็จการรักษา';
    } else if (filteredPreviousTreatmentsModel.finishStatus == 'canceled') {
      finishStatus = 'ยกเลิกการรักษา';
    }

    return Column(
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
              await goToPatientInPreviousTreatmentPage(
                  filteredPreviousTreatmentsModel);
            }
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        imageUrl:
                            filteredPreviousTreatmentsModel.patientProfileImage,
                        placeholder: (context, url) => Image.asset(
                          'assets/images/profileDefault_rectangle.png',
                          fit: BoxFit.cover,
                        ),
                        width: 109,
                        height: 109,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredPreviousTreatmentsModel.patientFirstName} ${filteredPreviousTreatmentsModel.patientLastName}',
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
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Colon(),
                            Expanded(
                              child: Container(
                                child: Text(
                                  patientDiseases.isEmpty
                                      ? '-'
                                      : patientDiseases,
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
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
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Colon(),
                            Expanded(
                              child: Container(
                                child: Text(
                                  treatmentStartDate,
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
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
                              'เสร็จสิ้นการรักษา',
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Colon(),
                            Expanded(
                              child: Container(
                                child: Text(
                                  treatmentFinishDate,
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'สถานะการรักษา',
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Colon(),
                            Expanded(
                              child: Container(
                                child: Text(
                                  '$finishStatus',
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: finishStatus == 'สำเร็จการรักษา'
                                        ? defaultGreen
                                        : defaultRed,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 2,
          thickness: 2,
          color: Color(0xFFF5F5F5),
        )
      ],
    );
  }

  Future<Null> goToPatientInPreviousTreatmentPage(
      PreviousTreatmentsModel filteredPreviousTreatmentsModel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientInPreviousTreatmentPageWidget(
          treatmentID: filteredPreviousTreatmentsModel.treatmentID,
          patientProfileImage:
              filteredPreviousTreatmentsModel.patientProfileImage,
          patientFirstName: filteredPreviousTreatmentsModel.patientFirstName,
          patientLastName: filteredPreviousTreatmentsModel.patientLastName,
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
