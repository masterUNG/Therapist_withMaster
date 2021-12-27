import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:therapist_buddy/main.dart';
import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/assigned_exercises_model.dart';
import 'package:therapist_buddy/models/exercise_images_model.dart';
import 'package:therapist_buddy/models/exercises_in_patient_page_model.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/models/appointments_model.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/models/diseases_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/progress_indicator_no_dialog.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'package:therapist_buddy/screens/patient_profile_page.dart';
import 'package:therapist_buddy/screens/treatment_info_page.dart';
import 'assign_exercise_page.dart';
import 'assigned_exercises_page.dart';
import 'edit_appointment_page.dart';
import 'make_appointment_page.dart';
import 'patient_all_exercises_page.dart';
import 'patient_treatment_results_page.dart';
import 'no_internet_connection_page.dart';

class PatientPageWidget extends StatefulWidget {
  PatientPageWidget({
    Key key,
  }) : super(key: key);

  @override
  _PatientPageWidgetState createState() => _PatientPageWidgetState();
}

class _PatientPageWidgetState extends State<PatientPageWidget> {
  var subscription;
  bool internetIsConnected;
  double actionButtonsHeight = 75;
  String userDocumentID;
  String treatmentID;
  String patientID;
  String patientUserID;
  String patientProfileImage;
  String patientFirstName;
  String patientLastName;
  int patientAge;
  List<String> patientDiseases = [];
  DateTime treatmentStartDate;
  bool neverHasAppointment;
  bool hasAppointment;
  String appointmentID;
  DateTime chosenAppointmentDate;
  String appointmentDate;
  DateTime chosenAppointmentStartTime;
  String appointmentStartTime;
  DateTime chosenAppointmentFinishTime;
  String appointmentFinishTime;
  List<ExercisesInPatientPageModel> exercisesInPatientPageModel = [];
  bool neverAssignedExercises;
  List<DateTime> exerciseDates = [];
  List<ExerciseImagesModel> exerciseImagesModel = [];
  List<bool> exerciseCompletions = [];
  DateTime exerciseFirstDate;
  DateTime exerciseLastDate;
  int exerciseNumberOfWeeks;
  int exerciseCompletionPercentage;
  bool noPatientExercises;
  bool availableExerciseResults;
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    findUserDocumentID();
    findTreatmentID();
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
  }

  //  อ่านค่า treatmentID ใน SharedPreferences
  Future<Null> findTreatmentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    treatmentID = sharedPreferences.getString('treatmentID');
    print('treatmentID = $treatmentID');
    await readPatientProfileInfoAndTreatmentInfo();
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
        patientID = treatmentsModel.patientID;
        patientUserID = treatmentsModel.patientUserID;
        treatmentStartDate = treatmentsModel.startDate.toDate();

        // อ่านข้อมูลโปรไฟล์คนไข้
        await FirebaseFirestore.instance
            .collection('patientUsers')
            .doc(patientUserID)
            .get()
            .then((value) async {
          PatientUsersModel patientUsersModel =
              PatientUsersModel.fromMap(value.data());

          DateTime patientBirthday = patientUsersModel.birthday.toDate();
          patientProfileImage = patientUsersModel.profileImage;
          patientFirstName = patientUsersModel.firstName;
          patientLastName = patientUsersModel.lastName;
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

            DiseasesModel model = DiseasesModel(
                disease: assignedExercisesListModel.disease,
                createdAt: assignedExercisesListModel.createdAt);
            diseasesModel.add(model);
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
    await readAppointmentInfo();
  }

  // อ่านการนัดหมายที่มีอยู่
  Future<Null> readAppointmentInfo() async {
    await Firebase.initializeApp().then((value) async {
      // ตรวจสอบก่อนว่าเคยมีการนัดหมายคนไข้มาก่อนหรือไม่
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('appointments')
          .get()
          .then((value) async {
        // หากไม่มีให้เปลี่ยนค่า neverHasAppointment เป็น true
        if (value.docs.length == 0) {
          setState(() {
            neverHasAppointment = true;
          });
        } else {
          // หากเคยมีการนัดหมายคนไข้มาก่อนให้เปลี่ยนค่า neverHasAppointment เป็น false
          // และทำการตรวจสอบว่ามีการนัดหมายในปัจจุบันหรือไม่
          setState(() {
            neverHasAppointment = false;
          });
          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(treatmentID)
              .collection('appointments')
              .where('isActive', isEqualTo: true)
              .get()
              .then((value) async {
            // หากไม่มีการนัดหมายในปัจจุบันให้เปลี่ยนค่า hasAppointment เป็น false
            if (value.docs.length == 0) {
              setState(() {
                hasAppointment = false;
              });
            } else {
              // หากมีการนัดหมายในปัจจุบันให้เปลี่ยนค่า hasAppointment เป็น true
              // และการทำการอ่านข้อมูลการนัดหมายนั้น
              setState(() {
                hasAppointment = true;
              });

              for (var item in value.docs) {
                AppointmentsModel appointmentsModel =
                    AppointmentsModel.fromMap(item.data());

                setState(() {
                  appointmentID = item.id;
                  chosenAppointmentDate = appointmentsModel.date.toDate();
                  appointmentDate =
                      DateFormat.yMd('th').format(chosenAppointmentDate);
                  chosenAppointmentStartTime =
                      appointmentsModel.startTime.toDate();
                  appointmentStartTime =
                      DateFormat.Hm().format(chosenAppointmentStartTime);
                  chosenAppointmentFinishTime =
                      appointmentsModel.finishTime.toDate();
                  appointmentFinishTime =
                      DateFormat.Hm().format(chosenAppointmentFinishTime);
                });
              }
            }
          });
        }
        // หากอ่านการนัดหมายที่มีอยู่เสร็จเรียบร้อยแล้วให้ทำการ readAssignedExercises
        await readAssignedExercises();
      });
    });
  }

  // อ่านท่าออกกำลังกายที่มอบหมายที่อยู่ในช่วงเวลาปัจจุบัน
  Future<Null> readAssignedExercises() async {
    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    await Firebase.initializeApp().then((value) async {
      // ตรวจสอบว่าเคยมีการมอบหมายรายการออกกำลังกายมาก่อนหรือไม่
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('assignedExercisesList')
          .get()
          .then((value) async {
        // หากไม่เคยมีการมอบหมายรายการออกกำลังกายมาก่อนให้เปลี่ยนค่า neverAssignedExercises เป็น true
        if (value.docs.length == 0) {
          setState(() {
            neverAssignedExercises = true;
          });
        } else {
          // หากเคยมีการมอบหมายรายการออกกำลังกายมาก่อนให้เปลี่ยนค่า neverAssignedExercises เป็น false
          // และอ่านรายการออกกำลังกายที่อยู่ในช่วงเวลาปัจจุบัน
          setState(() {
            neverAssignedExercises = false;
          });

          // อ่านรายการออกกำลังกายที่ยังไม่ถูกยกเลิกและอยู่ในช่วงเวลาปัจจุบัน
          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(treatmentID)
              .collection('assignedExercisesList')
              .where('canceledAt', isNull: true)
              .get()
              .then((value) async {
            // หากมีรายการออกกำลังกายที่ยังไม่ถูกยกเลิกและอยู่ในช่วงเวลาปัจจุบันให้ทำการอ่านท่าออกกำลังกายที่ถูกมอบหมาย
            for (var item in value.docs) {
              String assignedExercisesListID = item.id;
              AssignedExercisesListModel assignedExercisesListModel =
                  AssignedExercisesListModel.fromMap(item.data());

              if (assignedExercisesListModel.finishDate
                  .toDate()
                  .isAfter(todayDate.subtract(Duration(days: 1)))) {
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

                    // อ่านข้อมูลของท่าออกกำลังกายนั้น
                    // และเพิ่มท่าออกกำลังกายที่ถูกมอบหมายไปยัง exercisesInPatientPageModel
                    await FirebaseFirestore.instance
                        .collection('exercises')
                        .doc(assignedExercisesModel.exerciseID)
                        .get()
                        .then((value) async {
                      ExercisesModel exercisesModel =
                          ExercisesModel.fromMap(value.data());

                      ExercisesInPatientPageModel model =
                          ExercisesInPatientPageModel(
                              exerciseImagePath: exercisesModel.imagePath,
                              exerciseName: exercisesModel.name,
                              numberOfTimes:
                                  assignedExercisesModel.numberOfTimes,
                              numberOfSets: assignedExercisesModel.numberOfSets,
                              createdAt: assignedExercisesListModel.createdAt);
                      exercisesInPatientPageModel.add(model);
                    });
                  }
                });
              }
            }
          });
          // เมื่ออ่านท่าออกกำลังกายที่ถูกมอบหมายในช่วงเวลาปัจจุบันทั้งหมดเสร็จเรียบร้อยแล้ว
          // ให้ทำการเรียงข้อมูลใน exercisesInPatientPageModel ใหม่
          // โดยเรียงจากท่าออกกำลังกายที่ถูกมอบหมาย lastest ไปยังท่าออกกำลังกายที่ถูกมอบหมาย earliest
          exercisesInPatientPageModel.sort((a, b) {
            var aStartDate = a.createdAt;
            var bStartDate = b.createdAt;
            return bStartDate.compareTo(aStartDate);
          });
          // เมื่อเรียงข้อมูลใน exercisesInPatientPageModel เสร็จเรียบร้อยแล้ว
          // ให้ทำการเรียงข้อมูลใน exerciseImagesModel ใหม่
          // โดยเรียงจากรูปภาพของท่าออกกำลังกายที่มี startDate เร็วที่สดไปยังรูปภาพของท่าออกกำลังกายที่มี startDate ช้าที่สุด
          exerciseImagesModel.sort((a, b) {
            var aStartDate = a.exerciseDate;
            var bStartDate = b.exerciseDate;
            return aStartDate.compareTo(bStartDate);
          });
        }
        // หลังจากที่อ่านท่าออกกำลังกายที่มอบหมายที่อยู่ในช่วงเวลาปัจจุบันเสร็ยเรียบร้อยแล้ว
        // ให้ทำการ readPatientExerciseResults
        await readPatientExerciseResults();
      });
    });
  }

  // อ่านผลการออกกำลังกายของคนไข้
  Future<Null> readPatientExerciseResults() async {
    await Firebase.initializeApp().then((value) async {
      // ตรวจสอบก่อนว่ามีการออกกำลังกายที่ถูกมอบหมายหรือไม่
      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('patientExercises')
          .get()
          .then((value) async {
        // หากมีการออกกำลังกายี่ถูกมอบหมายให้ปลี่ยนค่า noPatientExercises เป็น false และทำดังต่อไปนี้
        if (value.docs.length > 0) {
          setState(() {
            noPatientExercises = false;
          });

          for (var item in value.docs) {
            PatientExercisesModel patientExercisesModel =
                PatientExercisesModel.fromMap(item.data());

            DateTime exerciseDate = patientExercisesModel.date.toDate();
            DateTime now = DateTime.now();
            DateTime todayDate = DateTime(now.year, now.month, now.day);

            // เพิ่มวันที่ของการออกกำลังกายไปยัง exerciseDates
            exerciseDates.add(exerciseDate);
            // ถ้าการออกกำลังกายนั้นมีก่อนวันนี้ให้ทำการเพิ่มสถานะของการออกกำลังกายไปยัง exerciseCompletions
            if (exerciseDate.isBefore(todayDate)) {
              setState(() {
                availableExerciseResults = true;
              });
              exerciseCompletions.add(patientExercisesModel.isCompleted);
            }

            // เพิ่มรูปภาพออกกำลังกายไปยัง exerciseImagesModel
            await FirebaseFirestore.instance
                .collection('exercises')
                .doc(patientExercisesModel.exerciseID)
                .get()
                .then((value) async {
              ExercisesModel exercisesModel =
                  ExercisesModel.fromMap(value.data());

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

          // เรียงข้อมูลใน exerciseDates โดยเรียงจากวันที่ก่อนไปยังวันที่หลัง
          exerciseDates.sort((a, b) {
            return a.compareTo(b);
          });

          // เมื่อเรียงข้อมูลเสร็จเรียบร้อยแล้วให้ทำการ define ค่าตัวแปรเหล่านี้
          setState(() {
            exerciseFirstDate = exerciseDates.first;
            exerciseLastDate = exerciseDates.last;
            exerciseNumberOfWeeks =
                ((exerciseDates.last.difference(exerciseDates.first).inDays) /
                        7)
                    .ceil();
          });
          if (exerciseNumberOfWeeks == 0) {
            setState(() {
              exerciseNumberOfWeeks = 1;
            });
          }

          // ถ้ามีผลการออกกำลังกายให้คำณวนหา exerciseCompletionPercentage
          if (availableExerciseResults == true) {
            exerciseCompletionPercentage = ((exerciseCompletions
                            .where((element) => element == true)
                            .length /
                        exerciseCompletions.length) *
                    100)
                .floor();
          }

          // เรียงข้อมูลใน exerciseImagesModel โดยเรียงจากวันที่ออกกำลังกายก่อนไปยังวันที่ออกกำลังกายหลัง
          exerciseImagesModel.sort((a, b) {
            var aExerciseDate = a.exerciseDate;
            var bExerciseDate = b.exerciseDate;
            return aExerciseDate.compareTo(bExerciseDate);
          });
        } else {
          // หากไม่มีการออกกำลังกายที่ถูกมอบหมายให้เปลี่ยนค่า noPatientExercises เป็น true
          setState(() {
            noPatientExercises = true;
          });
        }
        setState(() {
          readDataIsFinished = true;
        });
      });
    });
  }

  final completeTreatmentSuccessfullySnackBar = SnackBar(
    content: Text(
      'สำเร็จการรักษาเรียบร้อยแล้ว',
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
    return readDataIsFinished == true
        ? Scaffold(
            appBar: appBar(context),
            backgroundColor: Color(0xFFF5F5F5),
            body: SafeArea(
              child: Column(
                children: [
                  bodyContainer(context),
                  actionButtonsRow(context),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            body: Center(
              child: SmallProgressIndicator(),
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
            await backToTreatmentsPage();
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
                      fontSize: 19,
                    ),
                    overflow: TextOverflow.ellipsis,
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

  // กลับไปยังหน้า TreatmentsPage
  Future<Null> backToTreatmentsPage() async {
    // ก่อนที่จะกลับไปยังหน้า TreatmentsPage ให้ทำการ remove ค่า treatmentID ออกจาก SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('treatmentID').then((value) async {
      String treatmentID = sharedPreferences.getString('treatmentID');
      print('treatmentID = $treatmentID');
      // เมื่อ remove ค่า treatmentID ออกจาก SharedPreferences ให้ navigate ไปยังหน้า TreatmentsPage
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NavBarPage(initialPage: 'Treatments_page'),
        ),
        (r) => false,
      );
    });
  }

  // ทำการ refresh ข้อมูลหน้านี้
  Future<void> refreshPage() async {
    if (internetIsConnected == true) {
      patientDiseases.clear();
      exercisesInPatientPageModel.clear();
      exerciseDates.clear();
      exerciseImagesModel.clear();
      exerciseCompletions.clear();
      await readPatientProfileInfoAndTreatmentInfo();
    }
  }

  Widget bodyContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: internetIsConnected == false
          ? MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              appbarHeight -
              noInternetAppBarContainerHeight -
              actionButtonsHeight
          : MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              appbarHeight -
              actionButtonsHeight,
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            patientProfileContainer(context),
            treatmentInfoContainer(context),
            appointmentContainer(context),
            assignedExercisesContainer(context),
            patientExerciseResultContainer(context),
            // treatmentResultsAreaContainer(context),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget patientProfileContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
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
            await goToPatientProfilePage();
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
                                  overflow: TextOverflow.ellipsis,
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

//  ไปยังหน้า PatientProfilePage
  Future<Null> goToPatientProfilePage() async {
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
    String diseases = this.patientDiseases.join(', ');
    String startDate = DateFormat.yMd('th').format(treatmentStartDate);

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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TreatmentInfoPageWidget(
                            patientUserFirstName: patientFirstName,
                            patientUserLastName: patientLastName,
                            diseases: diseases,
                            startDate: startDate,
                            finishDate: null,
                            finishStatus: null,
                          ),
                        ),
                      );
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
                  'วันที่เข้ารับการรักษา',
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
            )
          ],
        ),
      ),
    );
  }

  Widget appointmentContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
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
                    'การนัดหมาย',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  neverHasAppointment == true || hasAppointment == false
                      ? Container()
                      : GestureDetector(
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
                              await goToEditAppointmentPage();
                            }
                          },
                          child: Text(
                            'แก้ไข',
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
              neverHasAppointment == true || hasAppointment == false
                  ? Container(
                      width: double.infinity,
                      height: 70,
                      child: Center(
                        child: Text(
                          neverHasAppointment == true
                              ? 'ยังไม่มีการนัดหมาย'
                              : 'ยังไม่มีการนัดหมายใหม่',
                          style: GoogleFonts.getFont(
                            'Kanit',
                            color: Color(0xFFA7A8AF),
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'วันที่',
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
                                  appointmentDate,
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
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
                              'เวลา',
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
                                  '$appointmentStartTime  ถึง  $appointmentFinishTime น.',
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
            ],
          ),
        ),
      ),
    );
  }

//  ไปยังหน้า EditAppointmentPageWidget
  Future<Null> goToEditAppointmentPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAppointmentPageWidget(
          treatmentID: treatmentID,
          patientID: patientID,
          patientUserID: patientUserID,
          appointmentID: appointmentID,
          appointmentDate: appointmentDate,
          chosenDate: chosenAppointmentDate,
          appointmentStartTime: appointmentStartTime,
          chosenStartTime: chosenAppointmentStartTime,
          appointmentFinishTime: appointmentFinishTime,
          chosenFinishTime: chosenAppointmentFinishTime,
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
                        ? neverAssignedExercises == true
                            ? Container()
                            : seeMoreDetailsAnchorText(context)
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
              builder: (context) => AssignedExercisesPageWidget(
                treatmentID: treatmentID,
                patientID: patientID,
                patientUserID: patientUserID,
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
          neverAssignedExercises == true
              ? 'ยังไม่มีการมอบหมายท่าออกกำลังกาย'
              : 'ยังไม่มีท่าออกกำลังกาย ณ ปัจจุบัน',
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
          noPatientExercises == true
              ? 'ยังไม่มีรายการออกกำลังกาย'
              : 'ยังไม่มีรายการออกกำลังกาย ณ ปัจจุบัน',
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
    DateTime now = new DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);
    String exerciseFirstDateText =
        DateFormat.yMd('th').format(exerciseFirstDate);
    String exerciseLastDateText = DateFormat.yMd('th').format(exerciseLastDate);

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
                            '$exerciseNumberOfWeeks สัปดาห์',
                            style: GoogleFonts.getFont(
                              'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '$exerciseFirstDateText - $exerciseLastDateText',
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
                child: exerciseImages(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Text(
                  availableExerciseResults == true
                      ? 'ความสม่ำเสมอ : $exerciseCompletionPercentage%'
                      : exerciseFirstDate == todayDate
                          ? 'ความสม่ำเสมอ : ยังไม่ถูกคำณวน'
                          : 'ความสม่ำเสมอ : ยังไม่ถึงวันออกกำลังกาย',
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
                  percent: availableExerciseResults == true
                      ? exerciseCompletionPercentage / 100
                      : 0,
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
                    builder: (context) => PatientAllExercisesPageWidget(
                      treatmentID: treatmentID,
                      patientUserProfileImage: patientProfileImage,
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

  Widget exerciseImages() {
    return Container(
      height: 25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exerciseImagesModel.length,
        itemBuilder: (context, index) =>
            exerciseImage(context, index, exerciseImagesModel[index]),
      ),
    );
  }

  Widget exerciseImage(BuildContext context, int index,
      ExerciseImagesModel exerciseImagesModel) {
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
        index == this.exerciseImagesModel.length - 1
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
                padding: EdgeInsets.symmetric(horizontal: 18),
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

  Widget actionButtonsRow(BuildContext context) {
    return Row(
      children: [
        appointButton(context),
        assignButton(context),
        accomplishButton(context)
      ],
    );
  }

  Widget appointButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (neverHasAppointment == true || hasAppointment == false) {
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
                builder: (context) => MakeAppointmentPageWidget(
                  treatmentID: treatmentID,
                  patientID: patientID,
                  patientUserID: patientUserID,
                ),
              ),
            );
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: actionButtonsHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x41000000),
              offset: Offset(2, 0),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: neverHasAppointment == true || hasAppointment == false
                  ? primaryColor
                  : secondaryColor,
              size: 30,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'นัดคนไข้',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: neverHasAppointment == true || hasAppointment == false
                      ? primaryColor
                      : secondaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget assignButton(BuildContext context) {
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
              builder: (context) => AssignExercisePageWidget(
                treatmentID: treatmentID,
                patientID: patientID,
                patientUserID: patientUserID,
              ),
            ),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: actionButtonsHeight,
        decoration: BoxDecoration(
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x41000000),
              offset: Offset(2, 0),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 31,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'มอบหมาย',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget accomplishButton(BuildContext context) {
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
          await showDialog(
            context: context,
            builder: (alertDialogContext) {
              return completeTreatmentConfirmationAlertDialog(
                  alertDialogContext);
            },
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: actionButtonsHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x41000000),
              offset: Offset(2, 0),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: primaryColor,
              size: 31,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'สำเร็จ',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget completeTreatmentConfirmationAlertDialog(
      BuildContext alertDialogContext) {
    return AlertDialog(
      title: Text(
        'ยืนยันการสำเร็จการรักษา',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องการสำเร็จการรักษานี้',
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
              await completeTreatment();
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
  }

  // สำเร็จการรักษา
  Future<Null> completeTreatment() async {
    // ขณะทำการสำเร็จการรักษาให้แสดง ProgressIndicatorNoDialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressIndicatorNoDialog(),
    );

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['isActive'] = false;
      data['finishStatus'] = 'completed';
      data['finishDate'] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .update(data)
          .then((value) async {
        await addNotification();
      });
    });
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
                title: 'การรักษาเสร็จสมบูรณ์',
                body: 'การรักษาของคุณกับ $therapistName ได้เสร็จสิ้นลงแล้ว',
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
          String title = 'การรักษาเสร็จสมบูรณ์';
          String body = 'การรักษาของคุณกับ $therapistName ได้เสร็จสิ้นลงแล้ว';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    // หากทำการสำเร็จการรักษาเรียบร้อยแล้วให้แสดง completeTreatmentSuccessfullySnackBar
    ScaffoldMessenger.of(context)
        .showSnackBar(completeTreatmentSuccessfullySnackBar);
    // และ navigate ไปยังหน้า TreatmentsPage
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => NavBarPage(initialPage: 'Treatments_page'),
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
