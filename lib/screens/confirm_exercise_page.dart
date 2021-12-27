import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/exercises_list_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_model.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'package:therapist_buddy/dropdown_lists.dart';
import 'patient_page.dart';
import 'no_internet_connection_page.dart';

class ConfirmExercisePageWidget extends StatefulWidget {
  final String treatmentID;
  final String disease;
  final List<ExercisesListModel> exercisesListModel;
  final String exerciseFrequency;
  final DateTime chosenStartDate;
  final String startDate;
  final DateTime chosenFinishDate;
  final String finishDate;
  final String patientID;
  final String patientUserID;

  ConfirmExercisePageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.disease,
      @required this.exercisesListModel,
      @required this.exerciseFrequency,
      @required this.chosenStartDate,
      @required this.startDate,
      @required this.chosenFinishDate,
      @required this.finishDate,
      @required this.patientID,
      @required this.patientUserID})
      : super(key: key);

  @override
  _ConfirmExercisePageWidgetState createState() =>
      _ConfirmExercisePageWidgetState();
}

class _ConfirmExercisePageWidgetState extends State<ConfirmExercisePageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String disease;
  List<ExercisesListModel> exercisesListModel;
  String exerciseFrequency;
  DateTime chosenStartDate;
  String startDate;
  DateTime chosenFinishDate;
  String finishDate;
  String patientID;
  String patientUserID;
  Timestamp createdAt;
  String assignedExercisesListID;
  DateTime patientExerciseDate;
  String userDocumentID;

  @override
  void initState() {
    super.initState();
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    treatmentID = widget.treatmentID;
    disease = widget.disease;
    exercisesListModel = widget.exercisesListModel;
    exerciseFrequency = widget.exerciseFrequency;
    chosenStartDate = widget.chosenStartDate;
    startDate = widget.startDate;
    chosenFinishDate = widget.chosenFinishDate;
    finishDate = widget.finishDate;
    patientExerciseDate = widget.chosenStartDate;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
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

  final addedExercisesListSuccessfullySnackBar = SnackBar(
    content: Text(
      'มอบหมายท่าออกกำลังกายเรียบร้อยแล้ว',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              diseaseTitle(),
              diseaseContainer(),
              exercisesListTitle(),
              exercisesList(),
              exerciseFrequencyTitle(),
              exerciseFrequencyContainer(),
              startDateTitle(),
              startDateContainer(),
              finishDateTitle(),
              finishDateContainer(),
              confirmButton(context)
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
          'ยืนยันการมอบหมาย',
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

  Widget diseaseTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 25, 0, 12),
      child: Text(
        'โรคของคนไข้',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget diseaseContainer() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                disease,
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

  Widget exercisesListTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 12),
      child: Text(
        'ท่าออกกำลังกาย',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget exercisesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: exercisesListModel.length,
      itemBuilder: (context, index) =>
          exerciseContainer(context, index, exercisesListModel[index]),
    );
  }

  Widget exerciseContainer(
      BuildContext context, int index, ExercisesListModel exercisesListModel) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: exercisesListModel.exerciseImage,
                    placeholder: (context, url) => Container(
                      width: 92,
                      height: 61,
                      color: loadingImageBG,
                    ),
                    width: 92,
                    height: 61,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercisesListModel.exerciseName,
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${exercisesListModel.exerciseNumberOfTimes}  ครั้ง/เซ็ต',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${exercisesListModel.exerciseNumberOfSets}  เซ็ต/วัน',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget exerciseFrequencyTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 3, 0, 12),
      child: Text(
        'ตารางการออกกำลังกาย',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget exerciseFrequencyContainer() {
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
                exerciseFrequency,
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

  Widget startDateTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 12),
      child: Text(
        'วันเริ่มการออกกำลังกาย',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget startDateContainer() {
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
                startDate,
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

  Widget finishDateTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 12),
      child: Text(
        'วันสิ้นสุดการออกกำลังกาย',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget finishDateContainer() {
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
                finishDate,
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
        padding: EdgeInsets.only(top: 25, bottom: 40),
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
              await addAssignedExercisesList();
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

  Future<Null> addAssignedExercisesList() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังมอบหมาย'),
    );

    await Firebase.initializeApp().then((value) async {
      Timestamp startDate = Timestamp.fromDate(DateTime(
          this.chosenStartDate.year,
          this.chosenStartDate.month,
          this.chosenStartDate.day));
      Timestamp finishDate = Timestamp.fromDate(DateTime(
          this.chosenFinishDate.year,
          this.chosenFinishDate.month,
          this.chosenFinishDate.day));
      createdAt = Timestamp.now();

      AssignedExercisesListModel assignedExercisesListModel =
          AssignedExercisesListModel(
              disease: disease,
              exerciseFrequency: exerciseFrequency,
              startDate: startDate,
              finishDate: finishDate,
              createdAt: createdAt,
              lastUpdate: null,
              canceledAt: null);
      Map<String, dynamic> data = assignedExercisesListModel.toMap();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('assignedExercisesList')
          .doc()
          .set(data)
          .then((value) async {
        await addAssignedExercises();
      });
    });
  }

  Future<Null> addAssignedExercises() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('assignedExercisesList')
          .where('createdAt', isEqualTo: createdAt)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          assignedExercisesListID = item.id;
          for (var item in exercisesListModel) {
            AssignedExercisesModel assignedExercisesModel =
                AssignedExercisesModel(
                    exerciseID: item.exerciseID,
                    numberOfTimes: item.exerciseNumberOfTimes,
                    numberOfSets: item.exerciseNumberOfSets);
            Map<String, dynamic> data = assignedExercisesModel.toMap();

            await FirebaseFirestore.instance
                .collection('treatments')
                .doc(treatmentID)
                .collection('assignedExercisesList')
                .doc(assignedExercisesListID)
                .collection('assignedExercises')
                .doc()
                .set(data);
          }
        }
        await addPatientExercises();
      });
    });
  }

  Future<Null> addPatientExercises() async {
    String exerciseFrequencyValue1 = DropdownLists.exerciseFrequencyValues[0];
    String exerciseFrequencyValue2 = DropdownLists.exerciseFrequencyValues[1];
    String exerciseFrequencyValue3 = DropdownLists.exerciseFrequencyValues[2];
    String exerciseFrequencyValue4 = DropdownLists.exerciseFrequencyValues[3];
    String exerciseFrequencyValue5 = DropdownLists.exerciseFrequencyValues[4];
    String exerciseFrequencyValue6 = DropdownLists.exerciseFrequencyValues[5];
    String exerciseFrequencyValue7 = DropdownLists.exerciseFrequencyValues[6];

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('assignedExercisesList')
          .doc(assignedExercisesListID)
          .collection('assignedExercises')
          .get()
          .then((value) async {
        for (var item in value.docs) {
          int numberOfDays;

          if (exerciseFrequency == exerciseFrequencyValue1) {
            numberOfDays = chosenFinishDate.difference(chosenStartDate).inDays;
          } else if (exerciseFrequency == exerciseFrequencyValue2) {
            numberOfDays =
                ((chosenFinishDate.difference(chosenStartDate).inDays) / 2)
                    .floor();
          } else if (exerciseFrequency == exerciseFrequencyValue3) {
            numberOfDays =
                ((chosenFinishDate.difference(chosenStartDate).inDays) / 3)
                    .floor();
          } else if (exerciseFrequency == exerciseFrequencyValue4) {
            numberOfDays =
                ((chosenFinishDate.difference(chosenStartDate).inDays) / 4)
                    .floor();
          } else if (exerciseFrequency == exerciseFrequencyValue5) {
            numberOfDays =
                ((chosenFinishDate.difference(chosenStartDate).inDays) / 5)
                    .floor();
          } else if (exerciseFrequency == exerciseFrequencyValue6) {
            numberOfDays =
                ((chosenFinishDate.difference(chosenStartDate).inDays) / 6)
                    .floor();
          } else if (exerciseFrequency == exerciseFrequencyValue7) {
            numberOfDays =
                ((chosenFinishDate.difference(chosenStartDate).inDays) / 7)
                    .floor();
          }
          print('numberOfDays = $numberOfDays');

          AssignedExercisesModel assignedExercisesModel =
              AssignedExercisesModel.fromMap(item.data());

          for (var i = 0; i <= numberOfDays; i++) {
            for (var a = 0; a < assignedExercisesModel.numberOfSets; a++) {
              Timestamp exerciseDate = Timestamp.fromDate(DateTime(
                  this.patientExerciseDate.year,
                  this.patientExerciseDate.month,
                  this.patientExerciseDate.day));

              PatientExercisesModel patientExercisesModel =
                  PatientExercisesModel(
                      assignedExercisesListID: assignedExercisesListID,
                      exerciseID: assignedExercisesModel.exerciseID,
                      numberOfTimes: assignedExercisesModel.numberOfTimes,
                      date: exerciseDate,
                      isCompleted: false,
                      completionDate: null);
              Map<String, dynamic> data = patientExercisesModel.toMap();

              await FirebaseFirestore.instance
                  .collection('treatments')
                  .doc(treatmentID)
                  .collection('patientExercises')
                  .doc()
                  .set(data);
            }

            if (exerciseFrequency == exerciseFrequencyValue1) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 1));
            } else if (exerciseFrequency == exerciseFrequencyValue2) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 2));
            } else if (exerciseFrequency == exerciseFrequencyValue3) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 3));
            } else if (exerciseFrequency == exerciseFrequencyValue4) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 4));
            } else if (exerciseFrequency == exerciseFrequencyValue5) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 5));
            } else if (exerciseFrequency == exerciseFrequencyValue6) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 6));
            } else if (exerciseFrequency == exerciseFrequencyValue7) {
              patientExerciseDate = patientExerciseDate.add(Duration(days: 7));
            }
            print('patientExerciseDate = $patientExerciseDate');
          }
          patientExerciseDate = chosenStartDate;
        }
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
                title: 'รายการออกกำลังกายใหม่',
                body: '$therapistName ได้เพิ่มรายการออกกำลังกายใหม่',
                category: assignedExercise,
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
          String title = 'มีรายการออกกำลังกายใหม่';
          String body = '$therapistName ได้เพิ่มรายการออกกำลังกายใหม่';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(addedExercisesListSuccessfullySnackBar);
    await backToPatientPage();
  }

  Future<Null> backToPatientPage() async {
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
