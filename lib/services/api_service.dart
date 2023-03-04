import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mapd722_patient_clinical_data_app/models/patient.dart';
import 'package:mapd722_patient_clinical_data_app/models/patient_record.dart';
import 'package:mapd722_patient_clinical_data_app/services/globals.dart';

class ApiService {
  final String url = "https://patient-data-api.herokuapp.com/api";
  final String patientPath = 'patient';
  final String recordPath = 'record';

  void showSnakeBar(String message, bool success) {
    final SnackBar snackBar = SnackBar(
      content: SizedBox(
        height: 40,
        child: Column(
          children: [
            Text(success ? 'Success' : 'Error',
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
            Text(message, style: const TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  Future<List<Patient>> getPatient(bool onlyCritical) async {
    try {
      String u = onlyCritical
          ? "$url/$patientPath?onlyCritical=true"
          : "$url/$patientPath?${DateTime.now()}";
      Response res = await get(Uri.parse(u));

      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        Map<String, dynamic> data = body["data"];
        List<dynamic> patientData = data["data"];
        List<Patient> patient =
            patientData.map((dynamic item) => Patient.fromJson(item)).toList();
        return patient;
      } else {
        throw "Failed to load patient list";
      }
    } catch (e) {
      showSnakeBar('Failed: Get Patient List', false);
      throw "Failed to load patient list";
    }
  }

  Future<bool> createPatient(Patient patient) async {
    try {
      Map data = {
        'first_name': patient.firstName,
        'last_name': patient.lastName,
        'gender': patient.gender,
        'age': patient.age,
        'address': patient.address,
        'mobile': patient.mobile,
        'email': patient.email,
      };
      final Response response = await post(
        Uri.parse('$url/$patientPath'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        showSnakeBar('Patient Addded succesfully!', true);
        return true;
      } else if (response.statusCode == 400) {
        Map<String, dynamic> body = jsonDecode(response.body);
        String message = body["message"] ?? "'Failed: Add Patient";
        showSnakeBar(message, false);
        return false;
      } else {
        showSnakeBar('Failed: Add Patient', false);
        return false;
      }
    } catch (e) {
      showSnakeBar('Failed: Add Patient', false);
      return false;
    }
  }

  Future<Object> updatePatient(String patientId, Patient patient) async {
    try {
      Map data = {
        'first_name': patient.firstName,
        'last_name': patient.lastName,
        'gender': patient.gender,
        'age': patient.age,
        'address': patient.address,
        'mobile': patient.mobile,
        'email': patient.email,
      };

      final Response response = await put(
        Uri.parse('$url/$patientPath/$patientId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        showSnakeBar('Patient Updated Succesfully!', true);
        return {"success": true};
      } else {
        showSnakeBar('Failed: Update Patient', false);
        return {"success": false};
      }
    } catch (e) {
      showSnakeBar('Failed: Update Patient', false);
      return {"success": false};
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      Response res = await delete(Uri.parse('$url/$patientPath/$patientId'));

      if (res.statusCode == 200) {
        showSnakeBar('Patient Deleted Successfully', true);
      } else {
        throw "Failed to delete a patient.";
      }
    } catch (e) {
      showSnakeBar('Failed: Delete Patient', false);
      throw "Failed to delete a patient.";
    }
  }

  Future<List<PatientRecord>> getPatientRecord(
    String patientId,
  ) async {
    try {
      Response res = await get(Uri.parse(
          '$url/$patientPath/$patientId/$recordPath?${DateTime.now()}'));

      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        List<dynamic> patientRecordData = body["data"];
        List<PatientRecord> patientRecord = patientRecordData
            .map((dynamic item) => PatientRecord.fromJson(item))
            .toList();
        // print('getPatientRecord api call');
        // print(patientRecord);
        return patientRecord;
      } else {
        throw "Failed to load patient record list";
      }
    } catch (e) {
      showSnakeBar('Failed: Get Patient Record List', false);
      throw "Failed to load patient record list";
    }
  }

  Future<Object> createPatientRecord(
      String patientId, PatientRecord patientRecord) async {
    try {
      Map data = {
        'reading': patientRecord.reading,
        'date_time': patientRecord.dateTime,
        'data_type': patientRecord.dataType,
        'patient_condition': patientRecord.condition,
      };
      final Response response = await post(
        Uri.parse('$url/$patientPath/$patientId/$recordPath'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        showSnakeBar('Patient Record Added Succesfully!', true);
        return {"success": true};
      } else if (response.statusCode == 400) {
        Map<String, dynamic> body = jsonDecode(response.body);
        String message = body["message"] ?? "'Failed: Add Patient Record";
        showSnakeBar(message, false);
        return {"success": false};
      } else {
        showSnakeBar('Failed: Add Patient Record', false);
        return {"success": false};
      }
    } catch (e) {
      showSnakeBar('Failed: Add Patient Record', false);
      return {"success": false};
    }
  }

  Future<Object> updatePatientRecord(
      String patientId, String recordId, PatientRecord patientRecord) async {
    try {
      Map data = {
        'reading': patientRecord.reading,
        'date_time': patientRecord.dateTime,
        'data_type': patientRecord.dataType,
        'patient_condition': patientRecord.condition,
      };

      final Response response = await put(
        Uri.parse('$url/$patientPath/$patientId/$recordPath/$recordId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        showSnakeBar('Patient Record Updated Succesfully!', true);
        return {"success": true};
      } else {
        showSnakeBar('Failed: Update Patient Record', false);
        return {"success": false};
      }
    } catch (e) {
      showSnakeBar('Failed: Update Patient Record', false);
      return {"success": false};
    }
  }

  Future<void> deletePatientRecord(String patientId, String recordId) async {
    try {
      Response res = await delete(
          Uri.parse('$url/$patientPath/$patientId/$recordPath/$recordId'));

      if (res.statusCode == 200) {
        showSnakeBar('Patient Record Deleted Successfully!', true);
      } else {
        throw "Failed to delete a patient.";
      }
    } catch (e) {
      showSnakeBar('Failed: Delete Patient Record', false);
      throw "Failed to delete a patient.";
    }
  }
}
