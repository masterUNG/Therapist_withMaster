import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_youtube_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import '../widgets/info_container.dart';

class ExerciseResultPageWidget extends StatefulWidget {
  final String exerciseID;
  final String exerciseName;
  final DateTime exerciseDate;
  final int numberOfTimes;
  final bool isCompleted;
  final Timestamp completionDate;

  ExerciseResultPageWidget(
      {Key key,
      @required this.exerciseID,
      @required this.exerciseName,
      @required this.exerciseDate,
      @required this.numberOfTimes,
      @required this.isCompleted,
      @required this.completionDate})
      : super(key: key);

  @override
  _ExerciseResultPageWidgetState createState() =>
      _ExerciseResultPageWidgetState();
}

class _ExerciseResultPageWidgetState extends State<ExerciseResultPageWidget> {
  var subscription;
  bool internetIsConnected;
  String exerciseID;
  String exerciseName;
  DateTime exerciseDate;
  int numberOfTimes;
  bool isCompleted;
  Timestamp completionDate;
  String videoURL;
  bool readExerciseInfoIsFinished;
  DateTime todayDateTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    readExerciseInfoIsFinished = false;
    exerciseID = widget.exerciseID;
    exerciseName = widget.exerciseName;
    exerciseDate = widget.exerciseDate;
    numberOfTimes = widget.numberOfTimes;
    isCompleted = widget.isCompleted;
    completionDate = widget.completionDate;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    initializeDateFormatting();
    readExerciseInfo();
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

  Future<Null> readExerciseInfo() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('exercises')
          .doc(exerciseID)
          .get()
          .then((value) async {
        ExercisesModel exercisesModel = ExercisesModel.fromMap(value.data());

        setState(() {
          videoURL = exercisesModel.videoURL;
          readExerciseInfoIsFinished = true;
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
        child: readExerciseInfoIsFinished == true
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    videoArea(context),
                    InfoContainer(
                        title: 'การออกกำลังกายของวันที่',
                        info: DateFormat.yMd('th').format(exerciseDate)),
                    InfoContainer(
                        title: 'จำนวนครั้งต่อเซ็ต',
                        info: numberOfTimes.toString()),
                    statusContainer(),
                    InfoContainer(
                        title: 'วันที่สำเร็จการออกกำลังกาย',
                        info: completionDate == null
                            ? '-'
                            : DateFormat.yMd('th')
                                .format(completionDate.toDate())),
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
          exerciseName,
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

  Widget videoArea(BuildContext context) {
    return FlutterFlowYoutubePlayer(
      url: videoURL,
      width: MediaQuery.of(context).size.width,
      autoPlay: false,
      looping: false,
      mute: false,
      showControls: true,
      showFullScreen: true,
    );
  }

  Widget statusContainer() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สถานะการออกกำลังกาย',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    exerciseDate.isAfter(todayDateTime) == true
                        ? 'ยังไม่ถึงวันออกกำลังกาย'
                        : isCompleted == true
                            ? 'สำเร็จ'
                            : 'ยังไม่สำเร็จ',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: exerciseDate.isAfter(todayDateTime) == true
                          ? Colors.black
                          : isCompleted == true
                              ? defaultGreen
                              : defaultRed,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE5E5E5),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
