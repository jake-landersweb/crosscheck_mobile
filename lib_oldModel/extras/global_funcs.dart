import 'package:flutter/material.dart';

void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

String dateToString(DateTime date) {
  int month = date.month;
  String formattedMonth = month.toString();
  if (month < 10) {
    formattedMonth = "0" + formattedMonth;
  }
  late String formattedDay;
  if (date.day < 10) {
    formattedDay = "0" + date.day.toString();
  } else {
    formattedDay = date.day.toString();
  }
  late String formattedHour;
  if (date.hour < 10) {
    formattedHour = "0" + date.hour.toString();
  } else {
    formattedHour = date.hour.toString();
  }
  late String formattedMinute;
  if (date.minute < 10) {
    formattedMinute = "0" + date.minute.toString();
  } else {
    formattedMinute = date.minute.toString();
  }
  late String formattedSecond;
  if (date.second < 10) {
    formattedSecond = "0" + date.second.toString();
  } else {
    formattedSecond = date.second.toString();
  }
  return "${date.year}-$formattedMonth-$formattedDay $formattedHour:$formattedMinute:$formattedSecond";
}

DateTime stringToDate(String date) {
  return DateTime.parse(date);
}

bool generalSameDate(DateTime day1, DateTime day2) {
  if (day1.day == day2.day &&
      day1.month == day2.month &&
      day1.year == day2.year) {
    return true;
  } else {
    return false;
  }
}

int intFromString(String char) {
  switch (char) {
    case "a":
      return 0;
    case "b":
      return 1;
    case "c":
      return 2;
    case "d":
      return 3;
    case "e":
      return 4;
    case "f":
      return 5;
    case 'g':
      return 6;
    case "h":
      return 7;
    case "i":
      return 8;
    case 'j':
      return 9;
    case 'k':
      return 10;
    case "l":
      return 11;
    case "m":
      return 12;
    case 'n':
      return 13;
    case 'o':
      return 14;
    case 'p':
      return 15;
    case 'q':
      return 16;
    case 'r':
      return 17;
    case 's':
      return 18;
    case 't':
      return 19;
    case 'u':
      return 20;
    case 'v':
      return 21;
    case 'w':
      return 22;
    case 'x':
      return 23;
    case 'y':
      return 24;
    case 'z':
      return 25;
    case '1':
      return 26;
    case '2':
      return 27;
    case '3':
      return 28;
    case '4':
      return 29;
    case '5':
      return 30;
    case '6':
      return 31;
    case '7':
      return 32;
    case '8':
      return 33;
    case '9':
      return 34;
    case '0':
      return 35;
    case '@':
      return 36;
    case '-':
      return 37;
    case '_':
      return 38;
    case '.':
      return 39;
    default:
      return 100;
  }
}
