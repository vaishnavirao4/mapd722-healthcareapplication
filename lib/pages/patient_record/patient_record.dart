import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapd722_patient_clinical_data_app/models/patient.dart';
import 'package:mapd722_patient_clinical_data_app/models/patient_record.dart';
import 'package:mapd722_patient_clinical_data_app/pages/patient_record/add_patient_record_widget.dart';
import 'package:mapd722_patient_clinical_data_app/pages/patient_record/edit_patient_record_widget.dart';
import 'package:mapd722_patient_clinical_data_app/services/api_service.dart';

class PatientRecordHomePage extends StatefulWidget {
  final Patient patient;
  const PatientRecordHomePage(this.patient, {super.key});

  @override
  _PatientRecordHomePageState createState() => _PatientRecordHomePageState();
}

class _PatientRecordHomePageState extends State<PatientRecordHomePage> {
  final ApiService api = ApiService();
  List<PatientRecord> patientRecordList = [];
  Map dataTypeOption = {
    'blood_pressure': 'Blood Pressure',
    'respiratory_rate': 'Respiratory Rate',
    'blood_oxygen_level': 'Blood Oxygen Level',
    'heartbeat_rate': 'Heartbeat Rate',
  };
  Map<String, SizedBox> dataTypeImage = {
    'blood_pressure': const SizedBox(
      height: 50.0,
      width: 50.0,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.color),
        child: Image(image: AssetImage('assets/images/blood_pressure.png')),
      ),
    ),
    'respiratory_rate': const SizedBox(
      height: 50.0,
      width: 50.0,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.color),
        child: Image(image: AssetImage('assets/images/respiratory_rate.png')),
      ),
    ),
    'blood_oxygen_level': const SizedBox(
      height: 50.0,
      width: 50.0,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.color),
        child: Image(image: AssetImage('assets/images/blood_oxygen_level.png')),
      ),
    ),
    'heartbeat_rate': const SizedBox(
      height: 50.0,
      width: 50.0,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.color),
        child: Image(image: AssetImage('assets/images/heartbeat_rate.png')),
      ),
    )
  };

  Map readingUnits = {
    'blood_pressure': 'mmHg',
    'respiratory_rate': '/min',
    'blood_oxygen_level': '%',
    'heartbeat_rate': '/min',
  };

  @override
  void initState() {
    loadList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('----------build called---------');
    // loadList();
    patientRecordList ??= <PatientRecord>[];
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Patient Record List"),
      ),
      body: Center(child: FutureBuilder(
        // future: loadList(),
        builder: (context, snapshot) {
          return patientRecordList.length > 0
              ? ListView.builder(
                  itemCount:
                      patientRecordList == null ? 0 : patientRecordList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        child: InkWell(
                      onTap: () {},
                      child: ListTile(
                        leading:
                            dataTypeImage[patientRecordList[index].dataType],
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${dataTypeOption[patientRecordList[index].dataType]} ",
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(
                                "${patientRecordList[index].reading} ${readingUnits[patientRecordList[index].dataType]} ",
                                style: const TextStyle(
                                  fontSize: 14.0,
                                )),
                            const SizedBox(height: 5),
                            Text(
                                DateFormat.yMEd().add_jm().format(
                                    DateTime.parse(
                                            patientRecordList[index].dateTime)
                                        .toLocal()),
                                style: const TextStyle(
                                  fontSize: 10.0,
                                ))
                          ],
                        ),
                        trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  _navigateToEditScreen(
                                      context, patientRecordList[index]);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  _deletePatientRecord(
                                      context,
                                      widget.patient.id,
                                      patientRecordList[index].id);
                                },
                              ),
                            ]),
                      ),
                    ));
                  })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.warning,
                        size: 100.0,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "No data found, tap plus button to add!",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddScreen(context);
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future loadList() {
    Future<List<PatientRecord>> futurePatientRecords =
        api.getPatientRecord(widget.patient.id);
    futurePatientRecords.then((patientRecordList) {
      // print("PatientRecord loadList called");
      // print(patientRecordList.toList());
      setState(() {
        this.patientRecordList = patientRecordList;
      });
    });
    return futurePatientRecords;
  }

  _navigateToAddScreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddPatientRecordWidget(widget.patient)),
    ).then((value) {
      // print("Back from Add Record on list screen");
      Future.delayed(const Duration(milliseconds: 100), () {
        // Do something
        loadList();
      });
    });
  }

  _navigateToEditScreen(
      BuildContext context, PatientRecord patientRecord) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditPatientRecordWidget(widget.patient, patientRecord),
        )).then((value) {
      // print("Back from Edit Record on list screen");
      Future.delayed(const Duration(milliseconds: 100), () {
        // Do something
        loadList();
      });
    });
  }

  _deletePatientRecord(
      BuildContext context, String patientId, String recordId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure want delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                api.deletePatientRecord(patientId, recordId);
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  // Do something
                  loadList();
                });
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
