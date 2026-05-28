class InstalledApp {
  final String appName;
  final String packageName;
  final bool isGame;

  const InstalledApp({
    required this.appName,
    required this.packageName,
    this.isGame = false,
  });

  static InstalledApp fromMap(Map<String, dynamic> map) {
    return InstalledApp(
      appName: map['appName'] as String,
      packageName: map['packageName'] as String,
      isGame: map['isGame'] == true,
    );
  }
}
