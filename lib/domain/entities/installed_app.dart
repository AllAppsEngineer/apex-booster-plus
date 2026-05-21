class InstalledApp {
  final String appName;
  final String packageName;

  const InstalledApp({required this.appName, required this.packageName});

  static InstalledApp fromMap(Map<String, dynamic> map) {
    return InstalledApp(
      appName: map['appName'] as String,
      packageName: map['packageName'] as String,
    );
  }
}
