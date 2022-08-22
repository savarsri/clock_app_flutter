class functions {
  int getYear(DateTime datetime) {
    int year;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(0, 4);
    year = int.parse(result);
    return year;
  }

  int getMonth(DateTime datetime) {
    int month;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(5, 7);
    month = int.parse(result);
    return month;
  }

  int getDay(DateTime datetime) {
    int day;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(8, 10);
    day = int.parse(result);
    return day;
  }

  int getHour(DateTime datetime) {
    int hour;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(11, 13);
    hour = int.parse(result);
    return hour;
  }

  int getMinute(DateTime datetime) {
    int minute;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(14, 16);
    minute = int.parse(result);
    return minute;
  }
}
