import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:therapist_buddy/dropdown_lists.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/exercises_list_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'exercise_introduction_for_assigning_page.dart';
import 'confirm_exercise_page.dart';
import 'no_internet_connection_page.dart';

class AssignExercisePageWidget extends StatefulWidget {
  final String treatmentID;
  final String patientID;
  final String patientUserID;

  AssignExercisePageWidget(
      {Key key, @required this.treatmentID, @required this.patientID,@required this.patientUserID})
      : super(key: key);

  @override
  _AssignExercisePageWidgetState createState() =>
      _AssignExercisePageWidgetState();
}

class _AssignExercisePageWidgetState extends State<AssignExercisePageWidget> {
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String patientID;
  String patientUserID;
  String diseaseValue;
  String exerciseFrequencyValue;
  String startDate;
  DateTime chosenStartDate;
  String finishDate;
  DateTime chosenFinishDate;
  bool formOnSubmitted;
  List<ExercisesListModel> exercisesListModel = [];
  bool readExercisesIsFinished;
  bool emptyExercisesList;

  @override
  void initState() {
    super.initState();
    readExercisesIsFinished = false;
    treatmentID = widget.treatmentID;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    readExercises();
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

  Future<Null> readExercises() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('exercises')
          .where('patientTypes', arrayContains: diseaseValue)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          ExercisesModel exercisesModel = ExercisesModel.fromMap(item.data());

          String exerciseID = item.id;
          String exerciseImage = exercisesModel.imagePath;
          String exerciseName = exercisesModel.name;
          List<String> exercisePatientTypes = exercisesModel.patientTypes;
          String exerciseVideoURL = exercisesModel.videoURL;

          ExercisesListModel model = ExercisesListModel(
              exerciseID: exerciseID,
              exerciseImage: exerciseImage,
              exerciseName: exerciseName,
              exercisePatientTypes: exercisePatientTypes,
              exerciseVideoURL: exerciseVideoURL,
              exerciseNumberOfTimes: 0,
              exerciseNumberOfSets: 0);

          exercisesListModel.add(model);
        }
        setState(() {
          readExercisesIsFinished = true;
        });
      });
    });
  }

  final emptyFieldSnackBar = SnackBar(
    content: Text(
      'กรุณากรอกข้อมูลให้ครบถ้วน',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
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
              diseaseFieldTitle(),
              diseaseField(),
              exercisesListFieldTitle(),
              exercisesList(context),
              exerciseFrequencyFieldTitle(),
              exerciseFrequencyField(),
              startDateFieldTitle(),
              startDateField(),
              finishDateFieldTitle(),
              finishDateField(),
              nextButton(context)
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
          'มอบหมาย',
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

  Widget diseaseFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 25, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'โรคของคนไข้',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุโรคของคนไข้)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: formOnSubmitted == true
                    ? diseaseValue == null
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget diseaseField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Container(
        width: double.infinity,
        height: 49,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(
            color: secondaryColor,
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(
              'เลือกโรคของคนไข้',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            value: diseaseValue,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.black,
            ),
            items: DropdownLists.diseases
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String value) async {
              setState(() {
                diseaseValue = value;
                readExercisesIsFinished = false;
                exercisesListModel.clear();
              });
              await readExercises();
            },
          ),
        ),
      ),
    );
  }

  Widget exercisesListFieldTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 30, top: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ท่าออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุท่าออกกำลังกาย)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: formOnSubmitted == true
                    ? emptyExercisesList != false
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget exercisesList(BuildContext context) {
    return readExercisesIsFinished == true
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: exercisesListModel.length,
            itemBuilder: (context, index) =>
                exerciseContainer(context, index, exercisesListModel[index]),
          )
        : loadingExercises();
  }

  Widget loadingExercises() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: SmallProgressIndicator(),
      ),
    );
  }

  Widget exerciseContainer(
      BuildContext context, int index, ExercisesListModel exercisesListModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              await goToExerciseIntroductionForAssigningPageWidget(
                  exercisesListModel);
            }
          },
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment(1, 0),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        index != this.exercisesListModel.length - 1
            ? Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE5E5E5),
              )
            : Container(),
      ],
    );
  }

  Future<Null> goToExerciseIntroductionForAssigningPageWidget(
      ExercisesListModel exercisesListModel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseIntroductionForAssigningPageWidget(
          exerciseVideoURL: exercisesListModel.exerciseVideoURL,
          exerciseName: exercisesListModel.exerciseName,
          exercisePatientTypes: exercisesListModel.exercisePatientTypes,
          exerciseNumberOfTimes: exercisesListModel.exerciseNumberOfTimes,
          exerciseNumberOfSets: exercisesListModel.exerciseNumberOfSets,
        ),
      ),
    ).then((value) {
      Map<String, dynamic> data = value;
      setState(() {
        exercisesListModel.exerciseNumberOfTimes = data['numberOfTimes'];
        exercisesListModel.exerciseNumberOfSets = data['numberOfSets'];
      });

      if (formOnSubmitted == true) {
        setState(() {
          emptyExercisesList = true;
        });
        for (var item in this.exercisesListModel) {
          if (item.exerciseNumberOfTimes != 0 &&
              item.exerciseNumberOfSets != 0) {
            setState(() {
              emptyExercisesList = false;
            });
          }
        }
      }
    });
  }

  Widget exerciseFrequencyFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 6, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ตารางการออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุตาราง)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: formOnSubmitted == true
                    ? exerciseFrequencyValue == null
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget exerciseFrequencyField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Container(
        width: double.infinity,
        height: 49,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(
            color: secondaryColor,
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(
              'เลือกตารางการออกกำลังกาย',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            value: exerciseFrequencyValue,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: Colors.black,
            ),
            items: DropdownLists.exerciseFrequencyValues
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String value) {
              setState(() {
                exerciseFrequencyValue = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget startDateFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'วันเริ่มการออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุวันเริ่ม)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: formOnSubmitted == true
                    ? startDate == null
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget startDateField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: GestureDetector(
        onTap: () {
          return DatePicker.showDatePicker(
            context,
            showTitleActions: true,
            currentTime: startDate == null ? DateTime.now() : chosenStartDate,
            minTime: DateTime.now(),
            locale: LocaleType.th,
            onConfirm: (dateTime) {
              DateFormat dateFormat = DateFormat.yMd('th');
              setState(() {
                chosenStartDate = dateTime;
                startDate = dateFormat.format(chosenStartDate);
              });
              if (chosenFinishDate != null) {
                if (chosenFinishDate.isBefore(chosenStartDate)) {
                  setState(() {
                    chosenFinishDate = null;
                    finishDate = null;
                  });
                }
              }
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: 49,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  startDate == null ? 'เลือกวันเริ่ม' : '$startDate',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.calendarAlt,
                  color: Colors.white,
                  size: 24,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget finishDateFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'วันสิ้นสุดการออกกำลังกาย',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '(โปรดระบุวันสิ้นสุด)',
              style: GoogleFonts.getFont(
                'Kanit',
                color: formOnSubmitted == true
                    ? finishDate == null
                        ? snackBarRed
                        : Colors.transparent
                    : Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget finishDateField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: GestureDetector(
        onTap: () {
          return DatePicker.showDatePicker(
            context,
            showTitleActions: true,
            currentTime: finishDate == null
                ? startDate == null
                    ? DateTime.now()
                    : chosenStartDate
                : chosenFinishDate,
            minTime: startDate == null ? DateTime.now() : chosenStartDate,
            locale: LocaleType.th,
            onConfirm: (dateTime) {
              DateFormat dateFormat = DateFormat.yMd('th');
              setState(() {
                chosenFinishDate = dateTime;
                finishDate = dateFormat.format(chosenFinishDate);
              });
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: 49,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  finishDate == null ? 'เลือกวันสิ้นสุด' : '$finishDate',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.calendarAlt,
                  color: Colors.white,
                  size: 24,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nextButton(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 25, 0, 40),
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
              await validateForm();
            }
          },
          text: 'ถัดไป',
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

  Future<Null> validateForm() async {
    for (var item in exercisesListModel) {
      if (item.exerciseNumberOfTimes != 0 && item.exerciseNumberOfSets != 0) {
        setState(() {
          emptyExercisesList = false;
        });
      }
    }

    setState(() {
      formOnSubmitted = true;
    });

    if (diseaseValue == null ||
        emptyExercisesList != false ||
        exerciseFrequencyValue == null ||
        startDate == null ||
        finishDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(emptyFieldSnackBar);
    } else {
      await goToNextPage();
    }
  }

  Future<Null> goToNextPage() async {
    List<ExercisesListModel> exercisesListModel = [];

    for (var item in this.exercisesListModel) {
      if (item.exerciseNumberOfTimes != 0 && item.exerciseNumberOfSets != 0) {
        exercisesListModel.add(item);
      }
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmExercisePageWidget(
          treatmentID: treatmentID,
          disease: diseaseValue,
          exercisesListModel: exercisesListModel,
          exerciseFrequency: exerciseFrequencyValue,
          chosenStartDate: chosenStartDate,
          startDate: startDate,
          chosenFinishDate: chosenFinishDate,
          finishDate: finishDate,
          patientID: patientID,
          patientUserID: patientUserID,
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
