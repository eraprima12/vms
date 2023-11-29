bool isWithinCurrentDay(DateTime date) {
  // Get the current date
  DateTime currentDate = DateTime.now();

  DateTime startOfDay =
      DateTime(currentDate.year, currentDate.month, currentDate.day);

  DateTime endOfDay = DateTime(
      currentDate.year, currentDate.month, currentDate.day, 23, 59, 59, 999);

  return date.isAfter(startOfDay) && date.isBefore(endOfDay);
}
