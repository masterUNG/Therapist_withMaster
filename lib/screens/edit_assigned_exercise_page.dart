import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/dropdown_lists.dart';
import 'package:therapist_buddy/models/exercises_model.dart';
import 'package:therapist_buddy/models/exercises_list_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/models/exercises_in_assigned_exercises_list_model.dart';
import 'package:therapist_buddy/models/patient_exercises_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'package:therapist_buddy/screens/exercise_introduction_for_editing_assigned_exercise_page.dart';
import 'package:therapist_buddy/screens/patient_page.dart';
import 'confirm_edit_assigned_exercise_page.dart';
import 'no_internet_connection_page.dart';

class EditAssignedExercisePageWidget extends StatefulWidget {
  final String treatmentID;
  final String assignedExercisesListID;
  final String patientDisease;
  final List<ExercisesInAssignedExercisesListModel>
      exercisesInAssignedExercisesListModel;
  final String exerciseFrequency;
  final DateTime exerciseStartDate;
  final DateTime exerciseFinishDate;
  final String patientID;
  final String patientUserID;

  EditAssignedExercisePageWidget(
      {Key key,
      @required this.treatmentID,
      @required this.assignedExercisesListID,
      @required this.patientDisease,
      @required this.exercisesInAssignedExercisesListModel,
      @required this.exerciseFrequency,
      @required this.exerciseStartDate,
      @required this.exerciseFinishDate,
      @required this.patientID,
      @required this.patientUserID})
      : super(key: key);

  @override
  _EditAssignedExercisePageWidgetState createState() =>
      _EditAssignedExercisePageWidgetState();
}

class _EditAssignedExercisePageWidgetState
    extends State<EditAssignedExercisePageWidget> {
  double confirmAreaHeight = 160;
  var subscription;
  bool internetIsConnected;
  String treatmentID;
  String assignedExercisesListID;
  String patientDisease;
  List<ExercisesInAssignedExercisesListModel>
      exercisesInAssignedExercisesListModel;
  String exerciseFrequency;
  DateTime exerciseStartDate;
  DateTime exerciseFinishDate;
  String patientID;
  String patientUserID;
  String exerciseFrequencyValue;
  DateTime chosenStartDate;
  String startDate;
  DateTime chosenFinishDate;
  String finishDate;
  bool formOnSubmitted;
  bool exercisesListIsChanged;
  bool exerciseFrequencyIsChanged;
  bool exerciseStartDateIsChanged;
  bool exerciseFinishDateIsChanged;
  bool emptyExercisesList;
  List<ExercisesListModel> exercisesListModel = [];
  bool readExercisesIsFinished;
  String userDocumentID;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    treatmentID = widget.treatmentID;
    assignedExercisesListID = widget.assignedExercisesListID;
    patientDisease = widget.patientDisease;
    exercisesInAssignedExercisesListModel =
        widget.exercisesInAssignedExercisesListModel;
    exerciseFrequency = widget.exerciseFrequency;
    exerciseStartDate = widget.exerciseStartDate;
    exerciseFinishDate = widget.exerciseFinishDate;
    patientID = widget.patientID;
    patientUserID = widget.patientUserID;
    exerciseFrequencyValue = exerciseFrequency;
    chosenStartDate = widget.exerciseStartDate;
    startDate = DateFormat.yMd('th').format(chosenStartDate);
    chosenFinishDate = widget.exerciseFinishDate;
    finishDate = DateFormat.yMd('th').format(chosenFinishDate);
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    readExercises();
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
          .where('patientTypes', arrayContains: patientDisease)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          ExercisesModel exercisesModel = ExercisesModel.fromMap(item.data());

          String exerciseID = item.id;
          String exerciseImage = exercisesModel.imagePath;
          String exerciseName = exercisesModel.name;
          List<String> exercisePatientTypes = exercisesModel.patientTypes;
          String exerciseVideoURL = exercisesModel.videoURL;
          int exerciseNumberOfTimes = 0;
          int exerciseNumberOfSets = 0;

          for (var item in exercisesInAssignedExercisesListModel) {
            if (item.exerciseID == exerciseID) {
              setState(() {
                exerciseNumberOfTimes = item.numberOfTimes;
                exerciseNumberOfSets = item.numberOfSets;
              });
            }
          }

          ExercisesListModel model = ExercisesListModel(
              exerciseID: exerciseID,
              exerciseImage: exerciseImage,
              exerciseName: exerciseName,
              exercisePatientTypes: exercisePatientTypes,
              exerciseVideoURL: exerciseVideoURL,
              exerciseNumberOfTimes: exerciseNumberOfTimes,
              exerciseNumberOfSets: exerciseNumberOfSets);

          exercisesListModel.add(model);
        }
        setState(() {
          readExercisesIsFinished = true;
        });
      });
    });
  }

  final emptyExercisesListSnackBar = SnackBar(
    content: Text(
      'กรุณาระบุท่าออกกำลังกาย',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: snackBarRed,
  );

  final canceledAssignedExercisesListSuccessfullySnackBar = SnackBar(
    content: Text(
      'ยกเลิกรายการออกกำลังกายเรียบร้อยแล้ว',
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
              nextButton(context),
              deleteExercisesListTextButton(context)
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
            if (exercisesListIsChanged == true ||
                exerciseFrequencyIsChanged == true ||
                exerciseStartDateIsChanged == true ||
                exerciseFinishDateIsChanged == true) {
              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return leaveEditingAssignedExercisePageConfirmationAlertDialog();
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: primaryColor,
            size: 24,
          ),
          iconSize: 24,
        ),
        title: Text(
          'แก้ไขรายการออกกำลังกาย',
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

  Widget leaveEditingAssignedExercisePageConfirmationAlertDialog() {
    return AlertDialog(
      title: Text(
        'ละทิ้งการแก้ไขรายการออกกำลังกาย',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องการละทิ้งการแก้ไขรายการออกกำลังกายนี้',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pop(context);
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

  Widget diseaseFieldTitle() {
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

  Widget diseaseField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 49,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                patientDisease,
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Color(0xFFA7A8AF),
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

  Widget exercisesListFieldTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 18, 0, 0),
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
              await goToConfirmEditAssignedExercisePageWidget(
                  exercisesListModel);
            }
          },
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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

  Future<Null> goToConfirmEditAssignedExercisePageWidget(
      ExercisesListModel exercisesListModel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseIntroductionForEditingAssignedExercisePageWidget(
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

      bool exercisesListIsChanged;
      for (var item in this.exercisesListModel) {
        for (var itemDB in exercisesInAssignedExercisesListModel) {
          if (itemDB.exerciseID == item.exerciseID) {
            if (itemDB.numberOfTimes != item.exerciseNumberOfTimes ||
                itemDB.numberOfSets != item.exerciseNumberOfSets) {
              setState(() {
                exercisesListIsChanged = true;
              });
            }
          }
        }
      }
      if (exercisesListIsChanged == true) {
        setState(() {
          this.exercisesListIsChanged = true;
        });
      } else {
        setState(() {
          this.exercisesListIsChanged = false;
        });
      }

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

  Widget exerciseFrequencyField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
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
              if (exerciseFrequencyValue == exerciseFrequency) {
                setState(() {
                  exerciseFrequencyIsChanged = false;
                });
              } else {
                setState(() {
                  exerciseFrequencyIsChanged = true;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget startDateFieldTitle() {
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

  Widget startDateField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
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

              if (chosenStartDate == exerciseStartDate) {
                setState(() {
                  exerciseStartDateIsChanged = false;
                });
              } else {
                setState(() {
                  exerciseStartDateIsChanged = true;
                });
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

  Widget finishDateField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: () {
          return DatePicker.showDatePicker(
            context,
            showTitleActions: true,
            currentTime: finishDate == null ? DateTime.now() : chosenFinishDate,
            minTime: DateTime.now(),
            locale: LocaleType.th,
            onConfirm: (dateTime) {
              DateFormat dateFormat = DateFormat.yMd('th');
              setState(() {
                chosenFinishDate = dateTime;
                finishDate = dateFormat.format(chosenFinishDate);
              });

              if (chosenFinishDate == exerciseFinishDate) {
                setState(() {
                  exerciseFinishDateIsChanged = false;
                });
              } else {
                setState(() {
                  exerciseFinishDateIsChanged = true;
                });
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
        padding: EdgeInsets.only(top: 25),
        child: FFButtonWidget(
          onPressed: () async {
            if (exercisesListIsChanged == true ||
                exerciseFrequencyIsChanged == true ||
                exerciseStartDateIsChanged == true ||
                exerciseFinishDateIsChanged == true) {
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
            }
          },
          text: 'ถัดไป',
          options: FFButtonOptions(
            width: 190,
            height: 49,
            color: exercisesListIsChanged == true ||
                    exerciseFrequencyIsChanged == true ||
                    exerciseStartDateIsChanged == true ||
                    exerciseFinishDateIsChanged == true
                ? primaryColor
                : secondaryColor,
            textStyle: GoogleFonts.getFont(
              'Kanit',
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 24,
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

    if (emptyExercisesList != false) {
      ScaffoldMessenger.of(context).showSnackBar(emptyExercisesListSnackBar);
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmEditAssignedExercisePageWidget(
          treatmentID: treatmentID,
          assignedExercisesListID: assignedExercisesListID,
          disease: patientDisease,
          exercisesListModel: exercisesListModel,
          exerciseFrequency: exerciseFrequencyValue,
          chosenStartDate: chosenStartDate,
          startDate: startDate,
          chosenFinishDate: chosenFinishDate,
          finishDate: finishDate,
          exerciseStartDateIsChanged: exerciseStartDateIsChanged,
          patientID: patientID,
          patientUserID: patientUserID,
        ),
      ),
    );
  }

  Widget deleteExercisesListTextButton(BuildContext context) {
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
              return deleteAssignedExercisesListConfirmationAlertDialog();
            },
          );
        }
      },
      child: Align(
        alignment: Alignment(-1, 0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 25, 0, 25),
          child: Text(
            'ยกเลิกรายการออกกำลังกายนี้',
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteAssignedExercisesListConfirmationAlertDialog() {
    return AlertDialog(
      title: Text(
        'ยืนยันการลบรายการออกกำลังกาย',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกรายการออกกำลังกายนี้',
        style: GoogleFonts.getFont(
          'Kanit',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.getFont(
              'Kanit',
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await cancelAssignedExercisesList();
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

  Future<Null> cancelAssignedExercisesList() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังยกเลิก'),
    );

    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['canceledAt'] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc(treatmentID)
          .collection('assignedExercisesList')
          .doc(assignedExercisesListID)
          .update(data)
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('treatments')
            .doc(treatmentID)
            .collection('patientExercises')
            .where('assignedExercisesListID',
                isEqualTo: assignedExercisesListID)
            .get()
            .then((value) async {
          for (var item in value.docs) {
            PatientExercisesModel patientExercisesModel =
                PatientExercisesModel.fromMap(item.data());

            if (patientExercisesModel.date
                .toDate()
                .isAfter(todayDate.subtract(Duration(days: 1)))) {
              await FirebaseFirestore.instance
                  .collection('treatments')
                  .doc(treatmentID)
                  .collection('patientExercises')
                  .doc(item.id)
                  .delete();
            }
          }
        });
      });
    });
    await findUserDocumentID();
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
                title: 'รายการออกกำลังกายถูกยกเลิก',
                body: '$therapistName ได้ยกเลิกรายการออกกำลังกาย',
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
          String title = 'รายการออกกำลังกายถูกยกเลิก';
          String body = '$therapistName ได้ยกเลิกรายการออกกำลังกาย';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(canceledAssignedExercisesListSuccessfullySnackBar);
    await backToPatientPageWidget();
  }

  Future<Null> backToPatientPageWidget() async {
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
