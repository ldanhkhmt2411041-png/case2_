class DateFormatter {
  static String formatDate(DateTime? date) {
    if (date == null) return 'Khong co';
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return 'Khong co';
    final dateStr = formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $dateStr';
  }
}
