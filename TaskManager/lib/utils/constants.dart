class AppConstants {
  static const String appName = 'Task Manager';
  static const String apiBaseUrl = 'http://localhost:5000/api';

  // Task statuses
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  // Task priorities
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';

  // Permissions
  static const String permViewer = 'viewer';
  static const String permEditor = 'editor';
}
