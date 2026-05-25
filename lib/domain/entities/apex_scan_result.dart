enum ScanCheckStatus { ok, warn, fail, info }

enum ScanScore { pronto, incompleto }

class ScanCheck {
  final String id;
  final String label;
  final ScanCheckStatus status;
  final String message;

  const ScanCheck({
    required this.id,
    required this.label,
    required this.status,
    required this.message,
  });
}

class ApexScanResult {
  final List<ScanCheck> checks;
  final ScanScore score;

  const ApexScanResult({
    required this.checks,
    required this.score,
  });
}
