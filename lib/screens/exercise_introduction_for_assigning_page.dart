import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_youtube_player.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import '../widgets/info_container.dart';
import 'no_internet_connection_page.dart';

class ExerciseIntroductionForAssigningPageWidget extends StatefulWidget {
  final String exerciseVideoURL;
  final String exerciseName;
  final List<String> exercisePatientTypes;
  final int exerciseNumberOfTimes;
  final int exerciseNumberOfSets;

  ExerciseIntroductionForAssigningPageWidget(
      {Key key,
      @required this.exerciseVideoURL,
      @required this.exerciseName,
      @required this.exercisePatientTypes,
      @required this.exerciseNumberOfTimes,
      @required this.exerciseNumberOfSets})
      : super(key: key);

  @override
  _ExerciseIntroductionForAssigningPageWidgetState createState() =>
      _ExerciseIntroductionForAssigningPageWidgetState();
}

class _ExerciseIntroductionForAssigningPageWidgetState
    extends State<ExerciseIntroductionForAssigningPageWidget> {
  var subscription;
  bool internetIsConnected;
  double smallButtonWidth = 35.0;
  double smallButtonHeight = 35.0;
  double actionButtonAreaHeight = 85.0;
  String exerciseVideoURL;
  String exerciseName;
  List<String> exercisePatientTypes;
  List<Widget> patientTypeWidgets = [];
  int exerciseNumberOfTimes;
  int exerciseNumberOfSets;
  int numberOfTimes;
  int numberOfSets;
  bool editMode;
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    exerciseVideoURL = widget.exerciseVideoURL;
    exerciseName = widget.exerciseName;
    exercisePatientTypes = widget.exercisePatientTypes;
    numberOfTimes = widget.exerciseNumberOfTimes;
    numberOfSets = widget.exerciseNumberOfSets;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    readPatientTypes();
    checkData();
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

  Future<Null> readPatientTypes() async {
    for (int i = 0; i < exercisePatientTypes.length; i++) {
      patientTypeWidgets.add(
        Text(
          i == exercisePatientTypes.length - 1
              ? exercisePatientTypes[i]
              : '${exercisePatientTypes[i]}, ',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Future<Null> checkData() async {
    if (numberOfTimes != 0 && numberOfSets != 0) {
      setState(() {
        exerciseNumberOfTimes = numberOfTimes;
        exerciseNumberOfSets = numberOfSets;
        editMode = true;
      });
    }
    setState(() {
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
            ? Column(
                children: [
                  bodyContainer(context),
                  actionButtonArea(context),
                ],
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
        centerTitle: false,
        elevation: 2,
      ),
    );
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
              actionButtonAreaHeight
          : MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              appbarHeight -
              actionButtonAreaHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            videoArea(context),
            InfoContainer(title: 'ชื่อ', info: exerciseName),
            patientTypesContainer(),
            SizedBox(height: 25),
            numberOfTimesRow(context),
            SizedBox(height: 15),
            numberOfSetsRow(context),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget videoArea(BuildContext context) {
    return FlutterFlowYoutubePlayer(
      url: exerciseVideoURL,
      width: MediaQuery.of(context).size.width,
      autoPlay: false,
      looping: false,
      mute: false,
      showControls: true,
      showFullScreen: true,
    );
  }

  Widget patientTypesContainer() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ประเภทผู้ป่วย',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: patientTypeWidgets,
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

  Widget numberOfTimesRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: (MediaQuery.of(context).size.width - 200) / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "จำนวน",
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (numberOfTimes <= 0) {
                      numberOfTimes = 0;
                    } else {
                      numberOfTimes--;
                    }
                  });
                },
                child: Container(
                  width: smallButtonWidth,
                  height: smallButtonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
              ),
              Container(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$numberOfTimes",
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    numberOfTimes++;
                  });
                },
                child: Container(
                  width: smallButtonWidth,
                  height: smallButtonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 200) / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ครั้ง/เซ็ต",
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget numberOfSetsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: (MediaQuery.of(context).size.width - 200) / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "จำนวน",
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (numberOfSets <= 0) {
                      numberOfSets = 0;
                    } else {
                      numberOfSets--;
                    }
                  });
                },
                child: Container(
                  width: smallButtonWidth,
                  height: smallButtonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
              ),
              Container(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$numberOfSets",
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    numberOfSets++;
                  });
                },
                child: Container(
                  width: smallButtonWidth,
                  height: smallButtonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 200) / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "เซ็ต/วัน",
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget actionButtonArea(BuildContext context) {
    return Container(
      width: double.infinity,
      height: actionButtonAreaHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xff000000).withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(2, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: MediaQuery.of(context).size.width - 36, height: 48),
            child: ElevatedButton(
              onPressed: () async {
                if (editMode == true) {
                  if (numberOfTimes != exerciseNumberOfTimes ||
                      numberOfSets != exerciseNumberOfSets) {
                    if (numberOfTimes == 0 || numberOfSets == 0) {
                      if (numberOfTimes == 0 && numberOfSets == 0) {
                        if (internetIsConnected == false) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoInternetConnectionPageWidget(),
                            ),
                          );
                        } else {
                          await backToPreviousPage();
                        }
                      }
                    } else {
                      if (internetIsConnected == false) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NoInternetConnectionPageWidget(),
                          ),
                        );
                      } else {
                        await backToPreviousPage();
                      }
                    }
                  }
                } else {
                  if (numberOfTimes != 0 && numberOfSets != 0) {
                    if (internetIsConnected == false) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NoInternetConnectionPageWidget(),
                        ),
                      );
                    } else {
                      await backToPreviousPage();
                    }
                  }
                }
              },
              child: Text(
                editMode == true
                    ? numberOfTimes == 0 && numberOfSets == 0
                        ? 'ลบ'
                        : 'บันทึก'
                    : 'เพิ่ม',
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: editMode == true
                    ? numberOfTimes != exerciseNumberOfTimes ||
                            numberOfSets != exerciseNumberOfSets
                        ? numberOfTimes == 0 || numberOfSets == 0
                            ? numberOfTimes == 0 && numberOfSets == 0
                                ? primaryColor
                                : secondaryColor
                            : primaryColor
                        : secondaryColor
                    : numberOfTimes == 0 || numberOfSets == 0
                        ? secondaryColor
                        : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> backToPreviousPage() async {
    Map<String, dynamic> data = {};
    data['numberOfTimes'] = numberOfTimes;
    data['numberOfSets'] = numberOfSets;
    print('data = $data');
    Navigator.pop(context, data);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
