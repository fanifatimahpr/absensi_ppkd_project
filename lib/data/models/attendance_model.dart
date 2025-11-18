// To parse this JSON data:
// final attendanceTodayModel = attendanceTodayModelFromJson(jsonString);

import 'dart:convert';

AttendanceTodayModel attendanceTodayModelFromJson(String str) =>
    AttendanceTodayModel.fromJson(json.decode(str));

class AttendanceTodayModel {
  String? message;
  AttendanceData? data;

  AttendanceTodayModel({this.message, this.data});

  factory AttendanceTodayModel.fromJson(Map<String, dynamic> json) =>
      AttendanceTodayModel(
        message: json["message"],
        data: json["data"] == null
            ? null
            : AttendanceData.fromJson(json["data"]),
      );
}

class AttendanceData {
  String? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? checkInAddress;
  String? checkOutAddress;
  String? status;
  String? alasanIzin;

  AttendanceData({
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
        attendanceDate: json["attendance_date"],
        checkInTime: json["check_in_time"],
        checkOutTime: json["check_out_time"],
        checkInAddress: json["check_in_address"],
        checkOutAddress: json["check_out_address"],
        status: json["status"],
        alasanIzin: json["alasan_izin"],
      );
}
