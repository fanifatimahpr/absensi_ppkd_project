// To parse this JSON data, do
//
//     final historyModel = historyModelFromJson(jsonString);

import 'dart:convert';

HistoryModel historyModelFromJson(String str) => HistoryModel.fromJson(json.decode(str));

String historyModelToJson(HistoryModel data) => json.encode(data.toJson());

class HistoryModel {
    String? message;
    List<Datum>? data;

    HistoryModel({
        this.message,
        this.data,
    });

    factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    int? id;
    DateTime? attendanceDate;
    CheckInTime? checkInTime;
    String? checkOutTime;
    double? checkInLat;
    double? checkInLng;
    double? checkOutLat;
    double? checkOutLng;
    CheckAddress? checkInAddress;
    CheckAddress? checkOutAddress;
    CheckLocation? checkInLocation;
    CheckLocation? checkOutLocation;
    Status? status;
    AlasanIzin? alasanIzin;

    Datum({
        this.id,
        this.attendanceDate,
        this.checkInTime,
        this.checkOutTime,
        this.checkInLat,
        this.checkInLng,
        this.checkOutLat,
        this.checkOutLng,
        this.checkInAddress,
        this.checkOutAddress,
        this.checkInLocation,
        this.checkOutLocation,
        this.status,
        this.alasanIzin,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        attendanceDate: json["attendance_date"] == null ? null : DateTime.parse(json["attendance_date"]),
        checkInTime: checkInTimeValues.map[json["check_in_time"]]!,
        checkOutTime: json["check_out_time"],
        checkInLat: json["check_in_lat"]?.toDouble(),
        checkInLng: json["check_in_lng"]?.toDouble(),
        checkOutLat: json["check_out_lat"]?.toDouble(),
        checkOutLng: json["check_out_lng"]?.toDouble(),
        checkInAddress: checkAddressValues.map[json["check_in_address"]]!,
        checkOutAddress: checkAddressValues.map[json["check_out_address"]]!,
        checkInLocation: checkLocationValues.map[json["check_in_location"]]!,
        checkOutLocation: checkLocationValues.map[json["check_out_location"]]!,
        status: statusValues.map[json["status"]]!,
        alasanIzin: alasanIzinValues.map[json["alasan_izin"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "attendance_date": "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
        "check_in_time": checkInTimeValues.reverse[checkInTime],
        "check_out_time": checkOutTime,
        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_out_lat": checkOutLat,
        "check_out_lng": checkOutLng,
        "check_in_address": checkAddressValues.reverse[checkInAddress],
        "check_out_address": checkAddressValues.reverse[checkOutAddress],
        "check_in_location": checkLocationValues.reverse[checkInLocation],
        "check_out_location": checkLocationValues.reverse[checkOutLocation],
        "status": statusValues.reverse[status],
        "alasan_izin": alasanIzinValues.reverse[alasanIzin],
    };
}

enum AlasanIzin {
    ALASAN_TIDAK_BISA_HADIR_KARENA_SAKIT
}

final alasanIzinValues = EnumValues({
    "Alasan tidak bisa hadir karena sakit": AlasanIzin.ALASAN_TIDAK_BISA_HADIR_KARENA_SAKIT
});

enum CheckAddress {
    JAKARTA
}

final checkAddressValues = EnumValues({
    "Jakarta": CheckAddress.JAKARTA
});

enum CheckLocation {
    THE_6123456106123456,
    THE_621068
}

final checkLocationValues = EnumValues({
    "-6.123456,106.123456": CheckLocation.THE_6123456106123456,
    "6.2,106.8": CheckLocation.THE_621068
});

enum CheckInTime {
    THE_0810,
    THE_1351,
    THE_1352
}

final checkInTimeValues = EnumValues({
    "08:10": CheckInTime.THE_0810,
    "13:51": CheckInTime.THE_1351,
    "13:52": CheckInTime.THE_1352
});

enum Status {
    IZIN,
    MASUK
}

final statusValues = EnumValues({
    "izin": Status.IZIN,
    "masuk": Status.MASUK
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
