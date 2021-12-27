import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/exercise_results_in_each_week_model.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/exercise_results_model.dart';
import 'package:therapist_buddy/models/exercise_results_in_a_day_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/screens/exercise_result_page.dart';
import 'no_internet_connection_page.dart';

class PatientThatWeekExercisesPageWidget extends StatefulWidget {
  final String treatmentID;
  final ExerciseResultsInEachWeekModel exerciseResultsInEachWeekModel;
  final String patientUserProfileImage;

  const PatientThatWeekExercisesPageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.exerciseResultsInEachWeekModel,
      @required this.patientUserProfileImage})
      : super(key: key);

  @override
  _PatientThatWeekExercisesPageWidgetState createState() =>
      _PatientThatWeekExercisesPageWidgetState();
}

class _PatientThatWeekExercisesPageWidgetState
    extends State<PatientThatWeekExercisesPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  ExerciseResultsInEachWeekModel exerciseResultsInEachWeekModel;
  String patientUserProfileImage;
  List<ExerciseResultsInADayModel> exerciseResultsInADayModel = [];
  bool readDataIsFinished;
  DateTime todayDateTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    treatmentID = widget.treatmentID;
    exerciseResultsInEachWeekModel = widget.exerciseResultsInEachWeekModel;
    patientUserProfileImage = widget.patientUserProfileImage;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    readExerciseResults();
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

  Future<Null> readExerciseResults() async {
    int difference = (exerciseResultsInEachWeekModel.lastDate
            .difference(exerciseResultsInEachWeekModel.firstDate)
            .inDays) +
        1;
    DateTime date = exerciseResultsInEachWeekModel.firstDate;

    for (int i = 0; i < difference; i++) {
      List<ExerciseResultsModel> exerciseResultsModel = [];

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

            if (exerciseDate == date) {
              await FirebaseFirestore.instance
                  .collection('exercises')
                  .doc(patientExercisesModel.exerciseID)
                  .get()
                  .then((value) async {
                ExercisesModel exercisesModel =
                    ExercisesModel.fromMap(value.data());

                ExerciseResultsModel model = ExerciseResultsModel(
                    exerciseID: patientExercisesModel.exerciseID,
                    exerciseImage: exercisesModel.imagePath,
                    exerciseName: exercisesModel.name,
                    numberOfTimes: patientExercisesModel.numberOfTimes,
                    isCompleted: patientExercisesModel.isCompleted,
                    completionDate: patientExercisesModel.completionDate);
                exerciseResultsModel.add(model);
              });
            }
          }
          ExerciseResultsInADayModel model = ExerciseResultsInADayModel(
              date: date, exerciseResultsModel: exerciseResultsModel);
          exerciseResultsInADayModel.add(model);

          date = date.add(Duration(days: 1));
        });
      });
    }
    setState(() {
      readDataIsFinished = true;
    });
  }

  // ทำการ refresh ข้อมูลหน้านี้
  Future<void> refreshPage() async {
    if (internetIsConnected == true) {
      exerciseResultsInADayModel.clear();
      await readExerciseResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: readDataIsFinished == true
            ? RefreshIndicator(
                onRefresh: refreshPage,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    introContainer(context),
                    exercisesList(context),
                    SizedBox(height: 12),
                  ],
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
          'สัปดาห์ที่ ${exerciseResultsInEachWeekModel.weekNumber}',
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

  Widget introContainer(BuildContext context) {
    String firstDate =
        DateFormat.yMd('th').format(exerciseResultsInEachWeekModel.firstDate);
    String lastDate =
        DateFormat.yMd('th').format(exerciseResultsInEachWeekModel.lastDate);
    bool isThisWeek = todayDateTime.isAfter(exerciseResultsInEachWeekModel
            .firstDate
            .subtract(Duration(days: 1))) &&
        todayDateTime.isBefore(
            exerciseResultsInEachWeekModel.lastDate.add(Duration(days: 1)));

    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
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
                            isThisWeek == true
                                ? 'สัปดาห์ที่ ${exerciseResultsInEachWeekModel.weekNumber} (ปัจจุบัน)'
                                : 'สัปดาห์ที่ ${exerciseResultsInEachWeekModel.weekNumber}',
                            style: GoogleFonts.getFont(
                              'Kanit',
                              color: isThisWeek == true
                                  ? primaryColor
                                  : Colors.black,
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
                padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: Text(
                  exerciseResultsInEachWeekModel.completionPercentage != null
                      ? 'ความสม่ำเสมอ : ${exerciseResultsInEachWeekModel.completionPercentage}%'
                      : todayDateTime.isBefore(
                                  exerciseResultsInEachWeekModel.firstDate) ==
                              true
                          ? 'ความสม่ำเสมอ : ยังไม่ถึงวันออกกำลังกาย'
                          : 'ความสม่ำเสมอ : ยังไม่ถูกคำณวน',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 20,
                  lineHeight: 5.0,
                  animation: true,
                  percent: exerciseResultsInEachWeekModel
                              .completionPercentage !=
                          null
                      ? exerciseResultsInEachWeekModel.completionPercentage /
                          100
                      : 0,
                  backgroundColor: Color(0xffF5F5F5),
                  progressColor: defaultGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget exercisesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: exerciseResultsInADayModel.length,
      itemBuilder: (context, index) => oneDayExercisesListContainer(
          context, index, exerciseResultsInADayModel[index]),
    );
  }

  Widget oneDayExercisesListContainer(BuildContext context, int index,
      ExerciseResultsInADayModel exerciseResultsInADayModel) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 18, 0, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dayContainer(exerciseResultsInADayModel),
              exerciseResultsInADayModel.exerciseResultsModel.length == 0
                  ? noExercises()
                  : availableExercises(exerciseResultsInADayModel,
                      exerciseResultsInADayModel.date),
            ],
          ),
        ),
      ),
    );
  }

  Widget dayContainer(ExerciseResultsInADayModel exerciseResultsInADayModel) {
    String dateAsText =
        DateFormat.yMd('th').format(exerciseResultsInADayModel.date);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            exerciseResultsInADayModel.date == todayDateTime
                ? 'วันนี้'
                : dateAsText,
            style: GoogleFonts.getFont(
              'Kanit',
              color: exerciseResultsInADayModel.date == todayDateTime
                  ? primaryColor
                  : Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
          exerciseResultsInADayModel.exerciseResultsModel.length == 0
              ? Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      '-',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Color(0xFFA7A8AF),
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'ไม่มีรายการออกกำลังกาย',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Color(0xFFA7A8AF),
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget noExercises() {
    return Container(
      height: 8,
    );
  }

  Widget availableExercises(
      ExerciseResultsInADayModel exerciseResultsInADayModel, DateTime date) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: exerciseResultsInADayModel.exerciseResultsModel.length,
      itemBuilder: (context, index) => exerciseContainer(context, index,
          exerciseResultsInADayModel.exerciseResultsModel[index], date),
    );
  }

  Widget exerciseContainer(BuildContext context, int index,
      ExerciseResultsModel exerciseResultsModel, DateTime date) {
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
          await goToExerciseIntroductionPageWidget(exerciseResultsModel, date);
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: exerciseResultsModel.exerciseImage,
                    placeholder: (context, url) => Container(
                      width: 87,
                      height: 59,
                      color: loadingImageBG,
                    ),
                    width: 87,
                    height: 59,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseResultsModel.exerciseName,
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                      Text(
                        '${exerciseResultsModel.numberOfTimes} ครั้ง',
                        style: GoogleFonts.getFont(
                          'Kanit',
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      )
                    ],
                  )
                ],
              ),
              date.isBefore(todayDateTime) == true
                  ? Expanded(
                      child: Align(
                        alignment: Alignment(1, 0),
                        child: Icon(
                          exerciseResultsModel.isCompleted == true
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: exerciseResultsModel.isCompleted == true
                              ? defaultGreen
                              : defaultRed,
                          size: 32,
                        ),
                      ),
                    )
                  : date == todayDateTime
                      ? exerciseResultsModel.isCompleted == true
                          ? Expanded(
                              child: Align(
                                alignment: Alignment(1, 0),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: defaultGreen,
                                  size: 32,
                                ),
                              ),
                            )
                          : Container()
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> goToExerciseIntroductionPageWidget(
      ExerciseResultsModel exerciseResultsModel, DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseResultPageWidget(
          exerciseID: exerciseResultsModel.exerciseID,
          exerciseName: exerciseResultsModel.exerciseName,
          exerciseDate: date,
          numberOfTimes: exerciseResultsModel.numberOfTimes,
          isCompleted: exerciseResultsModel.isCompleted,
          completionDate: exerciseResultsModel.completionDate,
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
