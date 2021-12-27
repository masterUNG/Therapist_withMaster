import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:therapist_buddy/variables.dart';

class PatientTreatmentResultWithQuestionnairePageWidget extends StatefulWidget {
  const PatientTreatmentResultWithQuestionnairePageWidget({Key key})
      : super(key: key);

  @override
  _PatientTreatmentResultWithQuestionnairePageWidgetState createState() =>
      _PatientTreatmentResultWithQuestionnairePageWidgetState();
}

class _PatientTreatmentResultWithQuestionnairePageWidgetState
    extends State<PatientTreatmentResultWithQuestionnairePageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              treatmentResultContainer(),
              questionnairesContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(appbarHeight),
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
          '25 สิงหาคม 2564',
          style: GoogleFonts.getFont(
            'Kanit',
            color: primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 21,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget treatmentResultContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 18, 0, 18),
        child: Row(
          mainAxisSize: MainAxisSize.max,
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
                      'ปานกลาง',
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
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '25 สิงหาคม 2564',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget questionnairesContainer() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title(),
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Text(
        "คำตอบของคุณ",
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
    );
  }
}
