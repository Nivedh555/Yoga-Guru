String formatClock(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  final int minutes = safe ~/ 60;
  final int rest = safe % 60;
  return '$minutes:${rest.toString().padLeft(2, '0')}';
}

String formatDurationLabel(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  if (safe < 60) {
    return '${safe}s';
  }
  final int minutes = safe ~/ 60;
  final int rest = safe % 60;
  if (rest == 0) {
    return '$minutes min';
  }
  return '$minutes min $rest sec';
}

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String weekdayShort(DateTime date) => _weekdays[date.weekday - 1];

String formatDayLabel(DateTime date) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(date.year, date.month, date.day);
  final int diff = today.difference(day).inDays;
  if (diff == 0) {
    return 'Today';
  }
  if (diff == 1) {
    return 'Yesterday';
  }
  if (day.year == today.year) {
    return '${day.day} ${_months[day.month - 1]}';
  }
  return '${day.day} ${_months[day.month - 1]} ${day.year}';
}

String formatTimeOfDay(DateTime date) {
  final String hour = date.hour.toString().padLeft(2, '0');
  final String minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String greetingForHour(int hour) {
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 17) {
    return 'Good afternoon';
  }
  return 'Good evening';
}
