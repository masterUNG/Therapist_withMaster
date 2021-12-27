import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/diseases_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_model.dart';
import 'package:therapist_buddy/models/exercises_in_patient_page_model.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/exercise_ids_model.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'patient_profile_page.dart';
import 'package:therapist_buddy/screens/treatment_info_page.dart';
import 'assigned_exercises_in_previous_treatment_page.dart';
import 'package:therapist_buddy/screens/patient_all_exercises_in_previous_treatment_page.dart';
import 'patient_treatment_results_page.dart';
import 'no_internet_connection_page.dart';

class PatientInPreviousTreatmentPageWidget extends StatefulWidget {
  final String treatmentID;
  final String patientProfileImage;
  final String patientFirstName;
  final String patientLastName;

  PatientInPreviousTreatmentPageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.patientProfileImage,
      @required this.patientFirstName,
      @required this.patientLastName})
      : super(key: key);

  @override
  _PatientInPreviousTreatmentPageWidgetState createState() =>
      _PatientInPreviousTreatmentPageWidgetState();
}

class _PatientInPreviousTreatmentPageWidgetState
    extends State<PatientInPreviousTreatmentPageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String patientProfileImage;
  String patientFirstName;
  String patientLastName;
  int patientAge;
  List<String> patientDiseases = [];
  DateTime treatmentStartDate;
  DateTime treatmentFinishDate;
  String treatmentFinishStatus;
  List<ExercisesInPatientPageModel> exercisesInPatientPageModel = [];
  DateTime exerciseFirstDate;
  DateTime exerciseLastDate;
  int exerciseNumberOfWeeks;
  int exerciseCompletionPercentage;
  List<String> exerciseImages = [];
  bool noPatientExercises;
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    treatmentID = widget.treatmentID;
    patientProfileImage = widget.patientProfileImage;
    patientFirstName = widget.patientFirstName;
    patientLastName = widget.patientLastName;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    readPatientProfileInfoAndTreatmentInfo();
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

  Future<Null> readPatientProfileInfoAndTreatmentInfo() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .get()
          .then((value) async {
        TreatmentsModel treatmentsModel = TreatmentsModel.fromMap(value.data());

        // อ่านค่า patientUserID และข้อมูลการรักษาบางส่วน
        String patientUserID = treatmentsModel.patientUserID;
        treatmentStartDate = treatmentsModel.startDate.toDate();
        treatmentFinishDate = treatmentsModel.finishDate.toDate();
        treatmentFinishStatus = treatmentsModel.finishStatus;

        // อ่านข้อมูลโปรไฟล์คนไข้
        await FirebaseFirestore.instance
            .collection('patientUsers')
            .doc(patientUserID)
            .get()
            .then((value) async {
          PatientUsersModel patientUsersModel =
              PatientUsersModel.fromMap(value.data());

          DateTime patientBirthday = patientUsersModel.birthday.toDate();
          patientAge = DateTime.now().year - patientBirthday.year;
        });

        // อ่านโรคของคนไข้
        await FirebaseFirestore.instance
            .collection('treatments')
            .doc(treatmentID)
            .collection('assignedExercisesList')
            .get()
            .then((value) async {
          List<DiseasesModel> diseasesModel = [];
          for (var item in value.docs) {
            AssignedExercisesListModel assignedExercisesListModel =
                AssignedExercisesListModel.fromMap(item.data());

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
          }
          diseasesModel.sort((a, b) {
            return a.createdAt.compareTo(b.createdAt);
          });
          for (var item in diseasesModel) {
            patientDiseases.add(item.disease);
          }
        });
      });
    });
    await readAssignedExercisesList();
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
          AssignedExercisesListModel assignedExercisesListModel =
              AssignedExercisesListModel.fromMap(item.data());
          Timestamp exerciseStartDate = assignedExercisesListModel.startDate;

          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(treatmentID)
              .collection('assignedExercisesList')
              .doc(assignedExercisesListID)
              .collection('assignedExercises')
              .get()
              .then((value) async {
            for (var item in value.docs) {
              AssignedExercisesModel assignedExercisesModel =
                  AssignedExercisesModel.fromMap(item.data());
              int exerciseNumberOfTimes = assignedExercisesModel.numberOfTimes;
              int exerciseNumberOfSets = assignedExercisesModel.numberOfSets;

              await FirebaseFirestore.instance
                  .collection('exercises')
                  .doc(assignedExercisesModel.exerciseID)
                  .get()
                  .then((value) async {
                ExercisesModel exercisesModel =
                    ExercisesModel.fromMap(value.data());
                String exerciseImagePath = exercisesModel.imagePath;
                String exerciseName = exercisesModel.name;

                ExercisesInPatientPageModel model = ExercisesInPatientPageModel(
                    exerciseImagePath: exerciseImagePath,
                    exerciseName: exerciseName,
                    numberOfTimes: exerciseNumberOfTimes,
                    numberOfSets: exerciseNumberOfSets,
                    createdAt: exerciseStartDate);
                exercisesInPatientPageModel.add(model);
              });
            }
          });
        }
        exercisesInPatientPageModel.sort((a, b) {
          return a.createdAt.compareTo(b.createdAt);
        });
      });
    });
    await readPatientExerciseResult();
  }

  Future<Null> readPatientExerciseResult() async {
    DateTime treatmentFinishDate = DateTime(this.treatmentFinishDate.year,
        this.treatmentFinishDate.month, this.treatmentFinishDate.day);
    List<DateTime> exerciseDates = [];
    List<bool> exerciseCompletions = [];
    List<ExerciseIDsModel> exerciseIDsModel = [];

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('patientExercises')
          .get()
          .then((value) async {
        if (value.docs.length > 0) {
          setState(() {
            noPatientExercises = false;
          });

          for (var item in value.docs) {
            PatientExercisesModel patientExercisesModel =
                PatientExercisesModel.fromMap(item.data());

            exerciseDates.add(patientExercisesModel.date.toDate());
            if (exerciseIDsModel
                    .where((exerciseIDsModel) =>
                        exerciseIDsModel.exerciseID ==
                        patientExercisesModel.exerciseID)
                    .length ==
                0) {
              ExerciseIDsModel model = ExerciseIDsModel(
                  exerciseID: patientExercisesModel.exerciseID,
                  exerciseDate: patientExercisesModel.date);
              exerciseIDsModel.add(model);
            }
            if (patientExercisesModel.date
                .toDate()
                .isBefore(treatmentFinishDate)) {
              exerciseCompletions.add(patientExercisesModel.isCompleted);
            }
          }
          exerciseDates.sort((a, b) => a.compareTo(b));

          exerciseFirstDate = exerciseDates.first;
          exerciseLastDate = exerciseDates.last;
          exerciseNumberOfWeeks =
              ((exerciseLastDate.difference(exerciseFirstDate).inDays) / 7)
                  .ceil();
          if (exerciseNumberOfWeeks == 0) {
            exerciseNumberOfWeeks = 1;
          }
          if (exerciseCompletions.length > 0) {
            exerciseCompletionPercentage = ((exerciseCompletions
                            .where((element) => element == true)
                            .length /
                        exerciseCompletions.length) *
                    100)
                .floor();
          }

          exerciseIDsModel
              .sort((a, b) => a.exerciseDate.compareTo(b.exerciseDate));
          for (var item in exerciseIDsModel) {
            String exerciseID = item.exerciseID;

            await FirebaseFirestore.instance
                .collection('exercises')
                .doc(exerciseID)
                .get()
                .then((value) async {
              ExercisesModel exercisesModel =
                  ExercisesModel.fromMap(value.data());
              exerciseImages.add(exercisesModel.imagePath);
            });
          }
        } else {
          setState(() {
            noPatientExercises = true;
          });
        }
      });
    });
    setState(() {
      readDataIsFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: readDataIsFinished == true
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    patientProfileContainer(context),
                    treatmentInfoContainer(context),
                    assignedExercisesContainer(context),
                    patientExerciseResultContainer(context),
                    // treatmentResultsAreaContainer(context),
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
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Container(
                width: 38,
                height: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CachedNetworkImage(
                  imageUrl: patientProfileImage,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/profileDefault_circle.png',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$patientFirstName $patientLastName',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 21,
                    ),
                  )
                ],
              ),
            )
          ],
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

  Widget patientProfileContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: GestureDetector(
        onTap: () async {
          if (internetIsConnected == false) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoInternetConnectionPageWidget(),
              ),
            );
          } else {
            await goToPatientProfilePageWidget();
          }
        },
        child: Card(
          margin: EdgeInsets.all(0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: patientProfileImage,
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
                    padding: EdgeInsets.only(left: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ข้อมูลโปรไฟล์คนไข้',
                          style: GoogleFonts.getFont(
                            'Kanit',
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'ชื่อ',
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
                                  '$patientFirstName $patientLastName',
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
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
                              'อายุ',
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
                                  '$patientAge ปี',
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> goToPatientProfilePageWidget() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientProfilePageWidget(
          patientUserProfileImage: patientProfileImage,
          patientUserFirstName: patientFirstName,
          patientUserLastName: patientLastName,
          patientUserAge: patientAge,
        ),
      ),
    );
  }

  Widget treatmentInfoContainer(BuildContext context) {
    String diseases = patientDiseases.join(', ');
    String startDate = DateFormat.yMd('th').format(treatmentStartDate);
    String finishDate = DateFormat.yMd('th').format(treatmentFinishDate);
    String finishStatus;
    if (treatmentFinishStatus == 'completed') {
      finishStatus = 'สำเร็จการรักษา';
    } else {
      finishStatus = 'ยกเลิกการรักษา';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ข้อมูลการรักษา',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
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
                      await goToTreatmentInfoPageWidget();
                    }
                  },
                  child: Text(
                    'ดูเพิ่มเติม',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: primaryColor,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  'โรค',
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
                      diseases.isEmpty ? '-' : diseases,
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
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
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
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
                    fontSize: 15,
                  ),
                ),
                Colon(),
                Expanded(
                  child: Container(
                    child: Text(
                      finishDate,
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
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
                  'สถานะการเสร็จสิ้นการรักษา',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Colon(),
                Text(
                  finishStatus,
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: finishStatus == 'สำเร็จการรักษา'
                        ? defaultGreen
                        : defaultRed,
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Null> goToTreatmentInfoPageWidget() async {
    String diseases = patientDiseases.join(', ');
    String startDate = DateFormat.yMd('th').format(treatmentStartDate);
    String finishDate = DateFormat.yMd('th').format(treatmentFinishDate);
    String finishStatus;
    if (treatmentFinishStatus == 'completed') {
      finishStatus = 'สำเร็จการรักษา';
    } else if (treatmentFinishStatus == 'canceled') {
      finishStatus = 'ยกเลิกการรักษา';
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentInfoPageWidget(
          patientUserFirstName: patientFirstName,
          patientUserLastName: patientLastName,
          diseases: diseases,
          startDate: startDate,
          finishDate: finishDate,
          finishStatus: finishStatus,
        ),
      ),
    );
  }

  Widget assignedExercisesContainer(BuildContext context) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ท่าออกกำลังกายที่มอบหมาย',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    exercisesInPatientPageModel.length == 0
                        ? Container()
                        : seeMoreDetailsAnchorText(context),
                  ],
                ),
              ),
              exercisesInPatientPageModel.length == 0
                  ? Container()
                  : SizedBox(height: 10),
              exercisesInPatientPageModel.length == 0
                  ? noExercises()
                  : exercisesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget seeMoreDetailsAnchorText(BuildContext context) {
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
              builder: (context) =>
                  AssignedExercisesInPreviousTreatmentPageWidget(
                treatmentID: treatmentID,
              ),
            ),
          );
        }
      },
      child: Text(
        'ดูรายละเอียด',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.normal,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget noExercises() {
    return Container(
      width: double.infinity,
      height: 170,
      child: Center(
        child: Text(
          'ไม่มีท่าออกกำลังกายที่มอบหมาย',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Color(0xFFA7A8AF),
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget exercisesList() {
    return Container(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exercisesInPatientPageModel.length,
        itemBuilder: (context, index) =>
            exerciseCard(context, index, exercisesInPatientPageModel[index]),
      ),
    );
  }

  Widget exerciseCard(BuildContext context, int index,
      ExercisesInPatientPageModel exercisesInPatientPageModel) {
    return Row(
      children: [
        index == 0 ? SizedBox(width: 18) : SizedBox(width: 15),
        Container(
          width: 155,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  imageUrl: exercisesInPatientPageModel.exerciseImagePath,
                  placeholder: (context, url) => Container(
                    width: 155,
                    height: 100,
                    color: loadingImageBG,
                  ),
                  width: 155,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      exercisesInPatientPageModel.exerciseName,
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${exercisesInPatientPageModel.numberOfTimes} ครั้ง/เซ็ต, ${exercisesInPatientPageModel.numberOfSets} เซ็ต/วัน',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        index == this.exercisesInPatientPageModel.length - 1
            ? SizedBox(width: 18)
            : Container(),
      ],
    );
  }

  Widget patientExerciseResultContainer(BuildContext context) {
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
                child: Text(
                  'การออกกำลังกายของคนไข้',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
              noPatientExercises == true ? Container() : SizedBox(height: 10),
              noPatientExercises == true
                  ? noExerciseResult()
                  : exerciseResult(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget noExerciseResult() {
    return Container(
      width: double.infinity,
      height: 150,
      child: Center(
        child: Text(
          'ไม่มีรายการออกกำลังกาย',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Color(0xFFA7A8AF),
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget exerciseResult(BuildContext context) {
    String exerciseFirstDate =
        DateFormat.yMd('th').format(this.exerciseFirstDate);
    String exerciseLastDate =
        DateFormat.yMd('th').format(this.exerciseLastDate);
    DateTime treatmentFinishDate = DateTime(this.treatmentFinishDate.year,
        this.treatmentFinishDate.month, this.treatmentFinishDate.day);

    return Stack(
      alignment: Alignment(1, 0),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: patientProfileImage,
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
                            '$exerciseNumberOfWeeks สัปดาห์ที่',
                            style: GoogleFonts.getFont(
                              'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '$exerciseFirstDate - $exerciseLastDate',
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
                child: exerciseImagesList(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Text(
                  exerciseCompletionPercentage == null
                      ? 'ความสม่ำเสมอ : ไม่ถูกคำณวน'
                      : 'ความสม่ำเสมอ : $exerciseCompletionPercentage%',
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
                  percent: exerciseCompletionPercentage == null
                      ? 0
                      : exerciseCompletionPercentage / 100,
                  backgroundColor: Color(0xffF5F5F5),
                  progressColor: defaultGreen,
                ),
              ),
            ],
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PatientAllExercisesInPreviousTreatmentPageWidget(
                      treatmentID: treatmentID,
                      patientUserProfileImage: patientProfileImage,
                      treatmentFinishDate: treatmentFinishDate,
                    ),
                  ),
                );
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
    );
  }

  Widget exerciseImagesList() {
    return Container(
      height: 25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exerciseImages.length,
        itemBuilder: (context, index) =>
            exerciseImage(context, index, exerciseImages[index]),
      ),
    );
  }

  Widget exerciseImage(BuildContext context, int index, String exerciseImage) {
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
            imageUrl: exerciseImage,
            placeholder: (context, url) => Container(
              color: loadingImageBG,
            ),
            fit: BoxFit.cover,
          ),
        ),
        index == this.exerciseImages.length - 1
            ? SizedBox(width: 18)
            : Container(),
      ],
    );
  }

  Widget treatmentResultsAreaContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Text(
                  "ผลการรักษา",
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
              treatmentResultsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget treatmentResultsList(BuildContext context) {
    return Column(
      children: [
        treatmentResultContainer(context),
      ],
    );
  }

  Widget treatmentResultContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18, 13, 18, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Office Syndrome",
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: primaryColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientTreatmentResultsPageWidget(),
                      ),
                    );
                  },
                  child: Text(
                    "ดูเพิ่มเติม",
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: primaryColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 55, 14),
            child: Container(
              width: double.infinity,
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 3,
                  minY: 0,
                  maxY: 5,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) {
                        return TextStyle(
                          color: Colors.black,
                          fontFamily: 'Kanit',
                          fontSize: 15,
                        );
                      },
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 0:
                            return '14 มิ.ย. 64';
                          case 1:
                            return '17 มิ.ย. 64';
                          case 2:
                            return '20 มิ.ย. 64';
                          case 3:
                            return '25 มิ.ย. 64';
                        }
                        return '';
                      },
                      margin: 12,
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) {
                        return TextStyle(
                          color: Colors.black,
                          fontFamily: 'Kanit',
                          fontSize: 15,
                        );
                      },
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 1:
                            return '1';
                          case 2:
                            return '2';
                          case 3:
                            return '3';
                          case 4:
                            return '4';
                          case 5:
                            return '5';
                        }
                        return '';
                      },
                      margin: 18,
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Color(0xffF5F5F5),
                        strokeWidth: 1,
                      );
                    },
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Color(0xffF5F5F5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Color(0xffF5F5F5),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 2),
                        FlSpot(1, 3),
                        FlSpot(2, 3.5),
                        FlSpot(3, 4),
                      ],
                      colors: lineChartColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        colors: lineChartColor
                            .map((color) => color.withOpacity(0.3))
                            .toList(),
                      ),
                    ),
                  ],
                ),
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
