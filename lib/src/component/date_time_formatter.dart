

import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTime _dateTime;
  String result;
  DateTime _previousDateTime;

  String bikeDateTime(String dateTime) {
    _dateTime  = DateTime.parse(dateTime);
    DateTime now = DateTime.now();

    Duration difference = now.difference(_dateTime);

    if(difference.inMinutes < 60) {
      result = difference.inMinutes.toString() + '분전';
      return result;
    }
    else if(difference.inHours < 24) {
      result = difference.inHours.toString() + '시간전';
      return result;
    }
    else if((difference.inHours >= 24) && (difference.inHours < 48)) {
      return '어제';
    }
    else if((difference.inHours >= 48) && (difference.inHours < 72)) {
      return '2일전';
    }
    else{
      result = _dateTime.month.toString()+'월 '+_dateTime.day.toString()+'일';
      return result;
    }
  }

  String chatRoomDateTime(String dateTime) {
    _dateTime = DateTime.parse(dateTime);
    //_dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime));
    DateTime now = DateTime.now();
    Duration difference = now.difference(_dateTime);
    NumberFormat formatter = new NumberFormat("00");

    if( (now.day - _dateTime.day) == 1){
      return '어제';
    }
    else if(difference.inHours <= 24) {
      if(_dateTime.hour < 12) {
        result = '오전 ' + _dateTime.hour.toString() + ':' + formatter.format(_dateTime.minute).toString();
        return result;
      }
      else if(_dateTime.hour == 12) {
        result = '오후 ' + _dateTime.hour.toString() + ':' + formatter.format(_dateTime.minute).toString();
        return result;
      }
      else {
        result = '오후 ' + (_dateTime.hour-12).toString() + ':' + formatter.format(_dateTime.minute).toString();
        return result;
      }
    }
    else {
      result = _dateTime.month.toString() + '월 ' + _dateTime.day.toString() + '일';
      return result;
    }
  }

  bool checkSameTime(DateTime val) {
    if(_previousDateTime == null)
      return false;

    if ((val.day == _previousDateTime.day) &&
        (val.hour == _previousDateTime.hour) &&
        (val.minute == _previousDateTime.minute))
      return true;
    else return false;
  }

  String chatDateTime(String dateTime) {
    int hour;
    String morningAfternoon;
    //DateTime value = DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime));
    DateTime value = DateTime.parse(dateTime);
    NumberFormat formatter = new NumberFormat("00");

    // if(checkSameTime(value))
    //   return '';

    if(value.hour < 12)
      morningAfternoon = '오전';
    else
      morningAfternoon = '오후';

    if(value.hour > 12)
      hour = value.hour-12;
    else
      hour = value.hour;

    _previousDateTime = value;
    return '$morningAfternoon ${hour.toString()}:${formatter.format(value.minute)}';
  }
}