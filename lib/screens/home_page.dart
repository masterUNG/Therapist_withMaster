import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/appointments_list_model.dart';
import 'package:therapist_buddy/models/appointments_model.dart';
import 'package:therapist_buddy/models/exercise_ids_model.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/patient_exercise_results_model.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/colon.dart';
import 'package:therapist_buddy/screens/patient_all_exercises_page.dart';
import 'all_appointments_page.dart';
import 'appointment_page.dart';
import 'notifications_page.dart';
import 'no_internet_connection_page.dart';

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  var subscription;
  bool internetIsConnected;
  String userDocumentID;
  String therapistWorkplace;
  List<AppointmentsListModel> appointmentsListModel = [];
  DateTime todayDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<String> treatmentIDs = [];
  List<PatientExerciseResults> patientExerciseResults = [];
  int notificationNumber;
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    findUserDocumentID();
    checkToken();
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

  // ดึงค่า userDocumentID ใน sharedPreferences
  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
  }

  // ตรวจสอบว่า token นี้มีในฐานข้อมูลแล้วหรือไม่
  Future<Null> checkToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    print('token = $token');

    await Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .collection('tokens')
          .where('token', isEqualTo: token)
          .get()
          .then((value) async {
        // หากยังไม่มี token นี้ในฐานข้อมูลให้ทำการเพิ่ม token นี้ในฐานข้อมูล
        if (value.docs.length == 0) {
          print('token นี้ยังไม่มีในฐานข้อมูล');

          TokensModel tokensModel = TokensModel(
            token: token,
            isActive: true,
            createdAt: Timestamp.now(),
            lastUpdate: null,
          );
          Map<String, dynamic> data = tokensModel.toMap();

          await FirebaseFirestore.instance
              .collection('therapists')
              .doc(userDocumentID)
              .collection('tokens')
              .doc()
              .set(data)
              .then((value) {
            print('Added token successfully');
          });
        } else {
          // หากมี token นี้ในฐานข้อมูลแล้วให้เปลี่ยน isActive เป็น true
          print('token นี้มีในฐานข้อมูลแล้ว');
          for (var item in value.docs) {
            String tokenDocumentID = item.id;
            print('tokenDocumentID = $tokenDocumentID');

            Map<String, dynamic> data = {};
            data['isActive'] = true;
            data['lastUpdate'] = Timestamp.now();

            await FirebaseFirestore.instance
                .collection('therapists')
                .doc(userDocumentID)
                .collection('tokens')
                .doc(tokenDocumentID)
                .update(data)
                .then(
              (value) {
                print('Update token successfully');
              },
            );
          }
        }
        await readTherapistWorkPlace();
      });
    });
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
          String treatmentID = item.id;
          treatmentIDs.add(treatmentID);

          TreatmentsModel treatmentsModel =
              TreatmentsModel.fromMap(item.data());
          String patientUserID = treatmentsModel.patientUserID;

          await FirebaseFirestore.instance
              .collection('treatments')
              .doc(treatmentID)
              .collection('appointments')
              .where('isActive', isEqualTo: true)
              .get()
              .then((value) async {
            for (var item in value.docs) {
              String appointmentID = item.id;
              AppointmentsModel appointmentsModel =
                  AppointmentsModel.fromMap(item.data());

              if (appointmentsModel.date.toDate() == todayDate) {
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
              } else if (appointmentsModel.date.toDate().isBefore(todayDate) &&
                  appointmentsModel.isActive == true) {
                Map<String, dynamic> data = {};
                data['isActive'] = false;
                data['finishStatus'] = 'completed';

                await FirebaseFirestore.instance
                    .collection('treatments')
                    .doc(treatmentID)
                    .collection('appointments')
                    .doc(appointmentID)
                    .update(data);
              }
            }
          });
        }
        appointmentsListModel.sort((a, b) {
          var aStartTime = DateTime(a.appointmentStartTime.toDate().hour,
              a.appointmentStartTime.toDate().minute);
          var bStartTime = DateTime(b.appointmentStartTime.toDate().hour,
              b.appointmentStartTime.toDate().minute);
          return aStartTime.compareTo(bStartTime);
        });

        await readPatientExerciseResults();
      });
    });
  }

  Future<Null> readPatientExerciseResults() async {
    for (var item in treatmentIDs) {
      String treatmentID = item;
      List<DateTime> exerciseDates = [];
      List<ExerciseIDsModel> exerciseIDsModel = [];
      List<bool> exerciseCompletions = [];
      List<String> exerciseImages = [];
      DateTime exerciseFirstDate;
      DateTime exerciseLastDate;
      int exerciseNumberOfWeeks;
      int completionPercentage;
      String patientProfileImage;
      String patientFirstName;
      String patientLastName;

      await Firebase.initializeApp().then((value) async {
        await FirebaseFirestore.instance
            .collection('treatments')
            .doc(item)
            .collection('patientExercises')
            .get()
            .then((value) async {
          if (value.docs.length > 0) {
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
              if (patientExercisesModel.date.toDate().isBefore(todayDate)) {
                exerciseCompletions.add(patientExercisesModel.isCompleted);
              }
            }
            exerciseDates.sort((a, b) {
              return a.compareTo(b);
            });
            exerciseFirstDate = exerciseDates.first;
            exerciseLastDate = exerciseDates.last;
            exerciseNumberOfWeeks =
                ((exerciseDates.last.difference(exerciseDates.first).inDays) /
                        7)
                    .ceil();
            if (exerciseNumberOfWeeks == 0) {
              exerciseNumberOfWeeks = 1;
            }

            if (exerciseCompletions.length > 0) {
              completionPercentage = ((exerciseCompletions
                              .where((element) => element == true)
                              .length /
                          exerciseCompletions.length) *
                      100)
                  .floor();
            }

            exerciseIDsModel.sort((a, b) {
              return a.exerciseDate.compareTo(b.exerciseDate);
            });

            for (var item in exerciseIDsModel) {
              await FirebaseFirestore.instance
                  .collection('exercises')
                  .doc(item.exerciseID)
                  .get()
                  .then((value) async {
                ExercisesModel exercisesModel =
                    ExercisesModel.fromMap(value.data());
                exerciseImages.add(exercisesModel.imagePath);
              });
            }
            await Firebase.initializeApp().then((value) async {
              await FirebaseFirestore.instance
                  .collection('treatments')
                  .doc(treatmentID)
                  .get()
                  .then((value) async {
                TreatmentsModel treatmentsModel =
                    TreatmentsModel.fromMap(value.data());

                await FirebaseFirestore.instance
                    .collection('patientUsers')
                    .doc(treatmentsModel.patientUserID)
                    .get()
                    .then((value) async {
                  PatientUsersModel patientUsersModel =
                      PatientUsersModel.fromMap(value.data());
                  patientProfileImage = patientUsersModel.profileImage;
                  patientFirstName = patientUsersModel.firstName;
                  patientLastName = patientUsersModel.lastName;
                });
              });
            });
            PatientExerciseResults model = PatientExerciseResults(
                treatmentID: treatmentID,
                patientProfileImage: patientProfileImage,
                patientFirstName: patientFirstName,
                patientLastName: patientLastName,
                exerciseNumberOfWeeks: exerciseNumberOfWeeks,
                exerciseFirstDate: exerciseFirstDate,
                exerciseLastDate: exerciseLastDate,
                exerciseImages: exerciseImages,
                completionPercentage: completionPercentage);
            patientExerciseResults.add(model);
          }
        });
      });
    }
    patientExerciseResults.sort((a, b) {
      return a.exerciseFirstDate.compareTo(b.exerciseFirstDate);
    });
    setState(() {
      readDataIsFinished = true;
    });
    await readNotifications();
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

  //  ทำการ refresh ข้อมูลหน้านี้
  Future<void> refreshPage() async {
    if (internetIsConnected == true) {
      appointmentsListModel.clear();
      treatmentIDs.clear();
      patientExerciseResults.clear();
      await readAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: readDataIsFinished == true
            ? RefreshIndicator(
                onRefresh: refreshPage,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    appointmentsAreaContainer(context),
                    patientExerciseResultsAreaContainer(context),
                    // patientsLatestTreatmentResultsAreaContainer(),
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
          padding: EdgeInsets.only(left: 20),
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

  Widget appointmentsAreaContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'การนัดหมายวันนี้',
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
                            builder: (context) => AllAppointmentsPageWidget(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'ดูการนัดหมายทั้งหมด',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: primaryColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: appointmentsListModel.length == 0
                  ? noAppointments()
                  : Container(
                      height: 165,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: appointmentsListModel.length,
                        itemBuilder: (context, index) => appointmentCard(
                            context, index, appointmentsListModel[index]),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget noAppointments() {
    return Container(
      height: 165,
      child: Center(
        child: Text(
          'ไม่มีการนัดหมายในวันนี้',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Color(0xFFA7A8AF),
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget appointmentCard(
      context, int index, AppointmentsListModel appointmentsListModel) {
    String startTime = DateFormat.Hm()
        .format(appointmentsListModel.appointmentStartTime.toDate());
    String finishTime = DateFormat.Hm()
        .format(appointmentsListModel.appointmentFinishTime.toDate());

    return Row(
      children: [
        index == 0 ? SizedBox(width: 18) : SizedBox(width: 10),
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
            width: 120,
            child: Card(
              margin: EdgeInsets.all(0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: appointmentsListModel.patientProfileImage,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/profileDefault_rectangle.png',
                        width: 120,
                        height: 85,
                        fit: BoxFit.cover,
                      ),
                      width: 120,
                      height: 85,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      appointmentsListModel.patientFirstName,
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      appointmentsListModel.patientLastName,
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$startTime - $finishTime น.',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        index == this.appointmentsListModel.length - 1
            ? SizedBox(width: 18)
            : Container(),
      ],
    );
  }

  Widget patientExerciseResultsAreaContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
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
            patientExerciseResults.length == 0
                ? Container()
                : SizedBox(height: 10),
            patientExerciseResults.length == 0
                ? noExerciseResults()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: patientExerciseResults.length,
                    itemBuilder: (context, index) =>
                        patientExerciseResultContainer(
                            context, index, patientExerciseResults[index]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget noExerciseResults() {
    return Column(
      children: [
        Container(
          height: 165,
          child: Center(
            child: Text(
              'ไม่มีการมอบหมายการออกกำลังกาย',
              style: GoogleFonts.getFont(
                'Kanit',
                color: Color(0xFFA7A8AF),
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 18),
      ],
    );
  }

  Widget patientExerciseResultContainer(
      context, int index, PatientExerciseResults patientExerciseResult) {
    String exerciseFirstDate =
        DateFormat.yMd('th').format(patientExerciseResult.exerciseFirstDate);
    String exerciseLastDate =
        DateFormat.yMd('th').format(patientExerciseResult.exerciseLastDate);

    return Padding(
      padding: EdgeInsets.only(bottom: 18),
      child: Stack(
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
                          imageUrl: patientExerciseResult.patientProfileImage,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/profileDefault_circle.png',
                            fit: BoxFit.cover,
                          ),
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
                                '${patientExerciseResult.patientFirstName} ${patientExerciseResult.patientLastName}',
                                style: GoogleFonts.getFont(
                                  'Kanit',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${patientExerciseResult.exerciseNumberOfWeeks} สัปดาห์',
                                    style: GoogleFonts.getFont(
                                      'Kanit',
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Colon(),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        '$exerciseFirstDate - $exerciseLastDate',
                                        style: GoogleFonts.getFont(
                                          'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: exerciseImages(patientExerciseResult),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
                  child: Text(
                    patientExerciseResult.completionPercentage == null
                        ? patientExerciseResult.exerciseFirstDate == todayDate
                            ? 'ความสม่าเสมอ : ยังไม่ถูกคำณวน'
                            : 'ยังไม่ถึงวันออกกำลังกาย'
                        : 'ความสม่าเสมอ : ${patientExerciseResult.completionPercentage}%',
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
                    percent: patientExerciseResult.completionPercentage == null
                        ? 0
                        : patientExerciseResult.completionPercentage / 100,
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
                        treatmentID: patientExerciseResult.treatmentID,
                        patientUserProfileImage:
                            patientExerciseResult.patientProfileImage,
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
      ),
    );
  }

  Widget exerciseImages(PatientExerciseResults patientExerciseResult) {
    return Container(
      height: 25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: patientExerciseResult.exerciseImages.length,
        itemBuilder: (context, index) => exerciseImage(
            context,
            index,
            patientExerciseResult.exerciseImages[index],
            patientExerciseResult.exerciseImages.length),
      ),
    );
  }

  Widget exerciseImage(BuildContext context, int index, String exerciseImage,
      int exerciseImagesLength) {
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
        index == exerciseImagesLength - 1 ? SizedBox(width: 18) : Container(),
      ],
    );
  }

  Widget patientsLatestTreatmentResultsAreaContainer() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 0, 8),
              child: Text(
                'ผลการประเมิณการรักษาล่าสุดของคนไข้',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                eachPatientTreatmentResultsContainer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget eachPatientTreatmentResultsContainer() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Text(
              'ธนวิชญ์ แซ่ลิ่ม',
              style: GoogleFonts.getFont(
                'Kanit',
                color: primaryColor,
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              treatmentResultContainer(),
            ],
          )
        ],
      ),
    );
  }

  Widget treatmentResultContainer() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularPercentIndicator(
              radius: 133.0,
              lineWidth: 12.0,
              animation: true,
              percent: 0.5,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '5.0',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 93,
                    child: Text(
                      'Office Syndrome',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Color(0xff7A7A7A),
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Color(0xffF5F5F5),
              progressColor: defaultYellow,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(21, 0, 21, 0),
              child: Container(
                width: 1.5,
                height: 133,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Office Syndrome',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'วันที่ : 25 ส.ค. 2564',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'คะแนน : 5/5',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'สถานะ : ปานกลาง',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
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
