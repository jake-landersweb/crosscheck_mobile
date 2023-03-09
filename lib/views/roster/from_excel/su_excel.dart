import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/extensions.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:excel/excel.dart';

class SUExcel {
  late String email;
  late String name;
  late String phone;
  late String nickname;
  late String position;
  late String jerseySize;
  late String jerseyNumber;
  late bool isManager;
  late bool isSub;
  late String note;

  SUExcel({
    required this.email,
    required this.name,
    required this.phone,
    required this.nickname,
    required this.position,
    required this.jerseySize,
    required this.jerseyNumber,
    required this.isManager,
    required this.isSub,
    required this.note,
  });

  SUExcel.fromExcelData(List<Data?> data) {
    email = (data[0]?.value.toString() ?? "").capitalize();
    if (email == "") {
      throw "'Email' is a required field";
    }
    if (!emailIsValid(email)) {
      throw "Please enter a valid email: '$email'";
    }
    name = (data[1]?.value.toString() ?? "").capitalize();
    if (name == "") {
      throw "'Name' is a required field";
    }
    phone = data[2]?.value.toString() ?? "";
    nickname = (data[3]?.value.toString() ?? "").capitalize();
    position = (data[4]?.value.toString() ?? "").toLowerCase();
    jerseySize = (data[5]?.value.toString() ?? "").toUpperCase();
    jerseyNumber = (data[6]?.value.toString() ?? "");

    if (data[7]?.value.toString().toUpperCase() == "TRUE") {
      isManager = true;
    } else if (data[7]?.value.toString().toUpperCase() == "FALSE") {
      isManager = false;
    } else if (data[7]?.value == "") {
      isManager = false;
    } else {
      throw "Invalid parameter for 'Is a Manager': ${data[7]?.value}";
    }
    if (data[8]?.value.toString().toUpperCase() == "TRUE") {
      isSub = true;
    } else if (data[8]?.value.toString().toUpperCase() == "FALSE") {
      isSub = false;
    } else if (data[8]?.value == "") {
      isSub = false;
    } else {
      throw "Invalid parameter for 'Is a Sub': ${data[8]?.value}";
    }

    note = data[9]?.value.toString() ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "phone": phone,
      "nickname": nickname,
      "pos": position,
      "jerseySize": jerseySize,
      "jerseyNumber": jerseyNumber,
      "isManager": isManager,
      "isSub": isSub,
      "note": note,
    };
  }

  @override
  String toString() => toMap().toString();
}
