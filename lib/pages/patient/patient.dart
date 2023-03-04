import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapd722_patient_clinical_data_app/models/patient.dart';
import 'package:mapd722_patient_clinical_data_app/pages/patient/add_patient_widget.dart';
import 'package:mapd722_patient_clinical_data_app/pages/patient/detail_patient_widget.dart';
import 'package:mapd722_patient_clinical_data_app/pages/patient/edit_patient_widget.dart';
import 'package:mapd722_patient_clinical_data_app/services/api_service.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({Key? key}) : super(key: key);

  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();
  List<Patient> patientList = [];

  late TabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // print("initState called");
    loadList(false);

    _controller = TabController(length: 2, vsync: this);

    _controller.addListener(() {
      // print('Controller Listener');
      setState(() {
        _selectedIndex = _controller.index;
      });
      _controller.index == 0 ? loadList(false) : loadList(true);
      // print("Selected Index: ${_controller.index}");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (patientList == null) {
      patientList = <Patient>[];
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _controller,
            tabs: const [
              Tab(
                text: 'All',
              ),
              Tab(
                text: 'Critical',
              ),
            ],
          ),
          title: const Text("Patient List"),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            Center(child: FutureBuilder(
              // future: loadList(),
              builder: (context, snapshot) {
                return patientList.length > 0
                    ? PatientListView(context, patientList)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              Icons.warning,
                              size: 100.0,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
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
            Center(child: FutureBuilder(
              // future: loadList(),
              builder: (context, snapshot) {
                return patientList.length > 0
                    ? PatientListView(context, patientList)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              Icons.warning,
                              size: 100.0,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToAddScreen(context);
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  PatientListView(BuildContext context, List<Patient> patient) {
    return ListView.builder(
        itemCount: patient == null ? 0 : patient.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              child: InkWell(
            onTap: () {
              _navigateToDetailScreen(context, patient[index]);
            },
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                  "${patient[index].firstName} ${patient[index].lastName}"),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 20.0,
                  ),
                  onPressed: () {
                    _navigateToEditScreen(context, patient[index]);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 20.0,
                  ),
                  onPressed: () {
                    _deletePatient(context, patient[index]);
                  },
                ),
              ]),
            ),
          ));
        });
  }

  _deletePatient(BuildContext context, Patient patient) async {
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
                api.deletePatient(patient.id);
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  // Do something
                  reloadList();
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

  Future loadList(onlyCritical) {
    patientList = [];
    Future<List<Patient>> futurePatient = api.getPatient(onlyCritical);
    futurePatient.then((patientList) {
      setState(() {
        this.patientList = patientList;
      });
    });
    return futurePatient;
  }

  _navigateToDetailScreen(BuildContext context, Patient patient) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailWidget(patient)),
    ).then((value) {
      // print("Back from Detail on list screen");
      Future.delayed(const Duration(milliseconds: 100), () {
        // Do something
        reloadList();
      });
    });
  }

  _navigateToAddScreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPatientWidget()),
    ).then((value) {
      // print("Back from Add on list screen");
      Future.delayed(const Duration(milliseconds: 100), () {
        // Do something
        reloadList();
      });
    });
  }

  _navigateToEditScreen(BuildContext context, Patient patient) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPatientWidget(patient)),
    ).then((value) {
      // print("Back from Edit on list screen");
      Future.delayed(const Duration(milliseconds: 100), () {
        // Do something
        reloadList();
      });
    });
  }

  reloadList() {
    // print('reloadList called');
    _controller.index == 0 ? loadList(false) : _controller.animateTo(0);
  }
}
