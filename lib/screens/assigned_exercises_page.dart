import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_with_exercises_model.dart';
import 'package:therapist_buddy/models/exercises_in_assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'edit_assigned_exercise_page.dart';
import 'no_internet_connection_page.dart';

class AssignedExercisesPageWidget extends StatefulWidget {
  final String treatmentID;
  final String patientID;
  final patientUserID;

  AssignedExercisesPageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.patientID,
      @required this.patientUserID})
      : super(key: key);

  @override
  _AssignedExercisesPageWidgetState createState() =>
      _AssignedExercisesPageWidgetState();
}

class _AssignedExercisesPageWidgetState
    extends State<AssignedExercisesPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String patientID;
  String patientUserID;
  List<AssignedExercisesListWithExercisesModel>
      assignedExercisesListWithExercisesModel = [];
  bool readAssignedExercisesListIsFinished;

  @override
  void initState() {
    super.initState();
    readAssignedExercisesListIsFinished = false;
    treatmentID = widget.treatmentID;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    readAssignedExercisesList();
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

  Future<Null> readAssignedExercisesList() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('assignedExercisesList')
          .get()
          .then((value) async {
        for (var item in value.docs) {
          String assignedExercisesListID = item.id;
          List<ExercisesInAssignedExercisesListModel>
              exercisesInAssignedExercisesListModel = [];

          AssignedExercisesListModel assignedExercisesListModel =
              AssignedExercisesListModel.fromMap(item.data());

          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(treatmentID)
              .collection('assignedExercisesList')
              .doc(assignedExercisesListID)
              .collection('assignedExercises')
              .get()
              .then((value) async {
            for (var item in value.docs) {
              AssignedExercisesModel assignedExerciseModel =
                  AssignedExercisesModel.fromMap(item.data());

              await FirebaseFirestore.instance
                  .collection('exercises')
                  .doc(assignedExerciseModel.exerciseID)
                  .get()
                  .then((value) async {
                ExercisesModel exercisesModel =
                    ExercisesModel.fromMap(value.data());

                ExercisesInAssignedExercisesListModel model =
                    ExercisesInAssignedExercisesListModel(
                        exerciseID: assignedExerciseModel.exerciseID,
                        exerciseName: exercisesModel.name,
                        exerciseImagePath: exercisesModel.imagePath,
                        numberOfTimes: assignedExerciseModel.numberOfTimes,
                        numberOfSets: assignedExerciseModel.numberOfSets);
                exercisesInAssignedExercisesListModel.add(model);
              });
            }
          });
          AssignedExercisesListWithExercisesModel model =
              AssignedExercisesListWithExercisesModel(
                  assignedExercisesListID: assignedExercisesListID,
                  disease: assignedExercisesListModel.disease,
                  exercisesInAssignedExercisesListModel:
                      exercisesInAssignedExercisesListModel,
                  exerciseFrequency:
                      assignedExercisesListModel.exerciseFrequency,
                  startDate: assignedExercisesListModel.startDate,
                  finishDate: assignedExercisesListModel.finishDate,
                  createdAt: assignedExercisesListModel.createdAt,
                  canceledAt: assignedExercisesListModel.canceledAt);

          assignedExercisesListWithExercisesModel.add(model);
        }
        assignedExercisesListWithExercisesModel.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });
        setState(() {
          readAssignedExercisesListIsFinished = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: readAssignedExercisesListIsFinished == true
            ? assignedExercisesList()
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
          'รายการออกกำลังกายที่มอบหมาย',
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

  Widget assignedExercisesList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: assignedExercisesListWithExercisesModel.length,
      itemBuilder: (context, index) => assignedExercisesContainer(
          context,
          assignedExercisesListWithExercisesModel.length - index,
          assignedExercisesListWithExercisesModel[index]),
    );
  }

  Widget assignedExercisesContainer(
      BuildContext context,
      int index,
      AssignedExercisesListWithExercisesModel
          assignedExercisesListWithExercisesModel) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                firstRow(
                    context, index, assignedExercisesListWithExercisesModel),
                assignedExercises(assignedExercisesListWithExercisesModel
                    .exercisesInAssignedExercisesListModel),
                exerciseFrequency(context,
                    assignedExercisesListWithExercisesModel.exerciseFrequency),
                exerciseStartDate(
                    context, assignedExercisesListWithExercisesModel.startDate),
                exerciseFinishDate(
                    context,
                    assignedExercisesListWithExercisesModel.finishDate,
                    assignedExercisesListWithExercisesModel.canceledAt),
              ],
            ),
          ),
        ),
        index == 1 ? SizedBox(height: 12) : Container(),
      ],
    );
  }

  Widget firstRow(
      BuildContext context,
      int index,
      AssignedExercisesListWithExercisesModel
          assignedExercisesListWithExercisesModel) {
    DateTime finishDate =
        assignedExercisesListWithExercisesModel.finishDate.toDate();

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          Text(
            'รายการที่ $index  :  ',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 19,
            ),
          ),
          Expanded(
            child: Container(
              child: Text(
                assignedExercisesListWithExercisesModel.disease,
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: primaryColor,
                  fontSize: 19,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          assignedExercisesListWithExercisesModel.canceledAt == null
              ? finishDate.isAfter(DateTime.now()) == true
                  ? Container(
                      width: 50,
                      height: 28,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (internetIsConnected == false) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NoInternetConnectionPageWidget(),
                                  ),
                                );
                              } else {
                                await goToEditAssignedExercisePageWidget(
                                    assignedExercisesListWithExercisesModel);
                              }
                            },
                            child: Text(
                              'แก้ไข้',
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: primaryColor,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container()
              : Container(),
        ],
      ),
    );
  }

  Future<Null> goToEditAssignedExercisePageWidget(
      AssignedExercisesListWithExercisesModel
          assignedExercisesListWithExercisesModel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAssignedExercisePageWidget(
          treatmentID: treatmentID,
          assignedExercisesListID:
              assignedExercisesListWithExercisesModel.assignedExercisesListID,
          patientDisease: assignedExercisesListWithExercisesModel.disease,
          exercisesInAssignedExercisesListModel:
              assignedExercisesListWithExercisesModel
                  .exercisesInAssignedExercisesListModel,
          exerciseFrequency:
              assignedExercisesListWithExercisesModel.exerciseFrequency,
          exerciseStartDate:
              assignedExercisesListWithExercisesModel.startDate.toDate(),
          exerciseFinishDate:
              assignedExercisesListWithExercisesModel.finishDate.toDate(),
          patientID: patientID,
          patientUserID: patientUserID,
        ),
      ),
    );
  }

  Widget assignedExercises(
      List<ExercisesInAssignedExercisesListModel>
          exercisesInAssignedExercisesListModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: exercisesInAssignedExercisesListModel.length,
      itemBuilder: (context, index) =>
          assignedExercise(exercisesInAssignedExercisesListModel[index]),
    );
  }

  Widget assignedExercise(
      ExercisesInAssignedExercisesListModel
          exercisesInAssignedExercisesListModel) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl:
                        exercisesInAssignedExercisesListModel.exerciseImagePath,
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
                    exercisesInAssignedExercisesListModel.exerciseName,
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${exercisesInAssignedExercisesListModel.numberOfTimes}  ครั้ง/เซ็ต',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${exercisesInAssignedExercisesListModel.numberOfSets}  เซ็ต/วัน',
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

  Widget exerciseFrequency(BuildContext context, String exerciseFrequency) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        children: [
          Text(
            'ตารางการออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Colon(),
          Expanded(
            child: Container(
              child: Text(
                exerciseFrequency,
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget exerciseStartDate(BuildContext context, Timestamp startDateTimestamp) {
    String startDate = DateFormat.yMd('th').format(startDateTimestamp.toDate());

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        children: [
          Text(
            'วันเริ่มการออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Colon(),
          Expanded(
            child: Container(
              child: Text(
                startDate,
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget exerciseFinishDate(BuildContext context, Timestamp finishDateTimestamp,
      Timestamp canceledAt) {
    String finishDate =
        DateFormat.yMd('th').format(finishDateTimestamp.toDate());

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Row(
        children: [
          Text(
            'วันสิ้นสุดการออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Colon(),
          Expanded(
            child: Container(
              child: Text(
                canceledAt == null
                    ? finishDate
                    : 'ยกเลิกเมื่อ ${DateFormat.yMd('th').format(canceledAt.toDate())}',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: canceledAt == null ? Colors.black : defaultRed,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
