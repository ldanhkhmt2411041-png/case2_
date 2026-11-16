class DateFormatter {
  static String format(DateTime? date) {
    if (date == null) return 'Không có hạn';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  static String formatFull(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  static bool isUpcoming(DateTime? dueDate) {
    if (dueDate == null) return false;
    final diff = dueDate.difference(DateTime.now());
    return diff.inHours >= 0 && diff.inHours <= 24;
  }
}
