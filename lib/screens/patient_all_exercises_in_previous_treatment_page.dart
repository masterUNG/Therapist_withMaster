import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/exercise_results_in_each_week_model.dart';
import 'package:therapist_buddy/models/exercise_images_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/screens/patient_that_week_exercises_in_previous_treatment_page.dart';
import 'no_internet_connection_page.dart';

class PatientAllExercisesInPreviousTreatmentPageWidget extends StatefulWidget {
  final String treatmentID;
  final String patientUserProfileImage;
  final DateTime treatmentFinishDate;

  PatientAllExercisesInPreviousTreatmentPageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.patientUserProfileImage,
      @required this.treatmentFinishDate})
      : super(key: key);

  @override
  _PatientAllExercisesInPreviousTreatmentPageWidgetState createState() =>
      _PatientAllExercisesInPreviousTreatmentPageWidgetState();
}

class _PatientAllExercisesInPreviousTreatmentPageWidgetState
    extends State<PatientAllExercisesInPreviousTreatmentPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String patientUserProfileImage;
  DateTime treatmentFinishDate;
  List<DateTime> exerciseDates = [];
  DateTime exerciseFirstDate;
  DateTime exerciseLastDate;
  int exerciseNumberOfWeeks;
  DateTime firstDateOfTheWeek;
  List<bool> exerciseCompletions = [];
  List<ExerciseResultsInEachWeekModel> exerciseResultsInEachWeekModel = [];
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    treatmentID = widget.treatmentID;
    patientUserProfileImage = widget.patientUserProfileImage;
    treatmentFinishDate = widget.treatmentFinishDate;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    readExerciseDates();
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

  // อ่านวันที่ที่มีการออกกำลังกายทั้งหมด
  Future<Null> readExerciseDates() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('patientExercises')
          .get()
          .then((value) async {
        for (var item in value.docs) {
          PatientExercisesModel patientExercisesModel =
              PatientExercisesModel.fromMap(item.data());
          // เพิ่มไปยัง exerciseDates
          exerciseDates.add(patientExercisesModel.date.toDate());
        }
        // เมื่ออ่านวันที่ที่มีการออกกำลังกายทั้งหมดเสร็จแล้ว ให้เรียงวันที่โดยเรียงจากวันที่แรกสุดจนถึงวันที่สุดท้าย
        exerciseDates.sort((a, b) {
          return a.compareTo(b);
        });
        // เมื่อเรียงวันที่เสร็จแล้วให้ define ค่าตัวแปรเหล่านี้
        setState(() {
          exerciseFirstDate = exerciseDates[0];
          exerciseLastDate = exerciseDates.last;
          exerciseNumberOfWeeks =
              ((exerciseLastDate.difference(exerciseFirstDate).inDays) / 7)
                  .ceil();
          if (exerciseNumberOfWeeks == 0) {
            exerciseNumberOfWeeks = 1;
          }
          firstDateOfTheWeek = exerciseFirstDate;
        });
        // หลังจากที่ define ค่าตัวแปรเสร็จสมบูรณ์ให้ทำการ readExerciseResults
        await readExerciseResults();
      });
    });
  }

  // อ่านผลการออกกำลังกายและท่าออกกำลังกายในแต่ละสัปดาห์
  Future<Null> readExerciseResults() async {
    for (var i = 0; i < exerciseNumberOfWeeks; i++) {
      DateTime lastDateOfTheWeek;
      List<ExerciseImagesModel> exerciseImagesModel = [];

      // กำหนดวันสุดท้ายของสัปดาห์นั้น
      setState(() {
        if (i == exerciseNumberOfWeeks - 1) {
          lastDateOfTheWeek = exerciseLastDate;
        } else {
          lastDateOfTheWeek = firstDateOfTheWeek.add(Duration(days: 6));
        }
      });

      // อ่านผลการออกกำลังกายทั้งหมด
      await Firebase.initializeApp().then((value) async {
        await FirebaseFirestore.instance
            .collection('treatments')
            .doc(treatmentID)
            .collection('patientExercises')
            .get()
            .then((value) async {
          for (var item in value.docs) {
            PatientExercisesModel patientExercisesModel =
                PatientExercisesModel.fromMap(item.data());

            DateTime exerciseDate = patientExercisesModel.date.toDate();

            // ตรวจสอบว่าการออกกำลังกายนั้นอยู่ภายในสัปดาห์นั้นจริงหรือไม่
            if (exerciseDate
                    .isAfter(firstDateOfTheWeek.subtract(Duration(days: 1))) &&
                exerciseDate
                    .isBefore(lastDateOfTheWeek.add(Duration(days: 1)))) {
              // ตรวจสอบว่าวันที่มีการออกกำลังกายนั้นอยู่ก่อนถึง treatmentFinishDate หรือไม่ ถ้าใช่ให้ทำการเพิ่มสถานะการออกกำลังกายไปยัง exerciseCompletions
              if (exerciseDate.isBefore(treatmentFinishDate)) {
                exerciseCompletions.add(patientExercisesModel.isCompleted);
              }

              // อ่านรูปภาพท่าออกกำลังกายของการออกกำลังกายนั้น
              await FirebaseFirestore.instance
                  .collection('exercises')
                  .doc(patientExercisesModel.exerciseID)
                  .get()
                  .then((value) async {
                ExercisesModel exercisesModel =
                    ExercisesModel.fromMap(value.data());

                // ตรวจสอบว่ารูปภาพท่าออกกำลังกายนั้นมีอยู่ใน exerciseImagesModel แล้วหรือไม่ หากยังไม่มีให้เพิ่มรูปภาพนั้นไปยัง exerciseImagesModel
                if (exerciseImagesModel
                        .where((exerciseImagesModel) =>
                            exerciseImagesModel.exerciseImage ==
                            exercisesModel.imagePath)
                        .length ==
                    0) {
                  ExerciseImagesModel model = ExerciseImagesModel(
                      exerciseImage: exercisesModel.imagePath,
                      exerciseDate: patientExercisesModel.date);

                  exerciseImagesModel.add(model);
                }
              });
            }
          }
        });
      });
      // เมื่ออ่านผลการออกกำลังกายและท่าออกกำลังกายในสัปดาห์นั้นเสร็จแล้ว ให้จัดเรียงรูปภาพของสัปดาห์นั้นใน exerciseImagesModel โดยเรียงจากท่าออกกำลังกายที่มีการออกกำลังกายก่อนจนถึงสุดท้าย
      exerciseImagesModel.sort((a, b) {
        return a.exerciseDate.compareTo(b.exerciseDate);
      });

      // คำณวนหาเปอร์เซ็นต์ความสม่ำเสมอของการออกกำลังกายในสัปดาห์นั้น
      int completionPercentage;
      if (exerciseCompletions.length > 0) {
        completionPercentage =
            ((exerciseCompletions.where((element) => element == true).length /
                        exerciseCompletions.length) *
                    100)
                .floor();
      } else {
        completionPercentage = null;
      }

      // เพิ่มข้อมูลผลการออกกำลังกายและรูปภาพท่าออกกำลังกายของสัปดาห์นั้นไปยัง exerciseResultsInEachWeekModel
      ExerciseResultsInEachWeekModel model = ExerciseResultsInEachWeekModel(
          weekNumber: i + 1,
          firstDate: firstDateOfTheWeek,
          lastDate: lastDateOfTheWeek,
          exerciseImagesModel: exerciseImagesModel,
          completionPercentage: completionPercentage);
      exerciseResultsInEachWeekModel.add(model);

      // หลังจากเพิ่มข้อมูลผลการออกกำลังกายและรูปภาพท่าออกกำลังกายของสัปดาห์นั้นเรียบร้อยแล้ว ให้ทำการเปลี่ยนค่า firstDateOfTheWeek และ clear exerciseCompletions เพื่อที่จะหาอมูลผลการออกกำลังกายและรูปภาพท่าออกกำลังกายของสัปดาห์ถัดไป
      setState(() {
        firstDateOfTheWeek = firstDateOfTheWeek.add(Duration(days: 7));
        exerciseCompletions.clear();
      });
    }
    // หากอ่านผลการออกกำลังกายและท่าออกกำลังกายในแต่ละสัปดาห์เสร็จเรียบร้อยแล้ว ให้เปลี่ยนค่า readDataIsFinished เป็น true
    setState(() {
      readDataIsFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: readDataIsFinished == true
            ? exerciseResults()
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SmallProgressIndicator(),
                    SizedBox(height: 15),
                    Text(
                      'กำลังโหลด',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
          'การออกกำลังกายของคนไข้',
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

  Widget exerciseResults() {
    return ListView.builder(
      itemCount: exerciseResultsInEachWeekModel.length,
      itemBuilder: (context, index) => thatWeekExerciseResultContainer(
          context, index, exerciseResultsInEachWeekModel[index]),
    );
  }

  Widget thatWeekExerciseResultContainer(BuildContext context, int index,
      ExerciseResultsInEachWeekModel exerciseResultsInEachWeekModel) {
    String firstDate =
        DateFormat.yMd('th').format(exerciseResultsInEachWeekModel.firstDate);
    String lastDate =
        DateFormat.yMd('th').format(exerciseResultsInEachWeekModel.lastDate);

    return Column(
      children: [
        SizedBox(height: 12),
        Stack(
          alignment: Alignment(1, 0),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 18, 0, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: patientUserProfileImage,
                              placeholder: (context, url) => Image.asset(
                                'assets/images/profileDefault_circle.png',
                                fit: BoxFit.cover,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'สัปดาห์ที่ ${exerciseResultsInEachWeekModel.weekNumber}',
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '$firstDate - $lastDate',
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: exerciseImages(
                          exerciseResultsInEachWeekModel.exerciseImagesModel),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: Text(
                        exerciseResultsInEachWeekModel.completionPercentage ==
                                null
                            ? 'ความสม่ำเสมอ : ไม่ถูกคำณวน'
                            : 'ความสม่ำเสมอ : ${exerciseResultsInEachWeekModel.completionPercentage}%',
                        style: GoogleFonts.getFont(
                          'Kanit',
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 20,
                        lineHeight: 5.0,
                        animation: true,
                        percent: exerciseResultsInEachWeekModel
                                    .completionPercentage ==
                                null
                            ? 0
                            : exerciseResultsInEachWeekModel
                                    .completionPercentage /
                                100,
                        backgroundColor: Color(0xffF5F5F5),
                        progressColor: defaultGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 18),
              child: IconButton(
                onPressed: () async {
                  if (internetIsConnected == false) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoInternetConnectionPageWidget(),
                      ),
                    );
                  } else {
                    await goToPatientThatWeekExercisesPageWidget(
                        exerciseResultsInEachWeekModel);
                  }
                },
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.black,
                  size: 30,
                ),
                iconSize: 30,
              ),
            )
          ],
        ),
        index == this.exerciseResultsInEachWeekModel.length - 1
            ? SizedBox(height: 12)
            : Container(),
      ],
    );
  }

  Future<Null> goToPatientThatWeekExercisesPageWidget(
      ExerciseResultsInEachWeekModel exerciseResultsInEachWeekModel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PatientThatWeekExercisesInPreviousTreatmentPageWidget(
          treatmentID: treatmentID,
          exerciseResultsInEachWeekModel: exerciseResultsInEachWeekModel,
          patientUserProfileImage: patientUserProfileImage,
          treatmentFinishDate: treatmentFinishDate,
        ),
      ),
    );
  }

  Widget exerciseImages(List<ExerciseImagesModel> exerciseImagesModel) {
    return Container(
      height: 25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exerciseImagesModel.length,
        itemBuilder: (context, index) => exerciseImage(context, index,
            exerciseImagesModel[index], exerciseImagesModel.length),
      ),
    );
  }

  Widget exerciseImage(BuildContext context, int index,
      ExerciseImagesModel exerciseImagesModel, int exerciseImagesModelLength) {
    return Row(
      children: [
        index == 0 ? SizedBox(width: 18) : SizedBox(width: 7),
        Container(
          width: 25,
          height: 25,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CachedNetworkImage(
            imageUrl: exerciseImagesModel.exerciseImage,
            placeholder: (context, url) => Container(
              color: loadingImageBG,
            ),
            fit: BoxFit.cover,
          ),
        ),
        index == exerciseImagesModelLength - 1
            ? SizedBox(width: 18)
            : Container(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
