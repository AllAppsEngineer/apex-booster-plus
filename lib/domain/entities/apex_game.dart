class ApexGame {
  final String id;
  final String name;
  final String? packageName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final String? localProfileName;

  const ApexGame({
    required this.id,
    required this.name,
    this.packageName,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.localProfileName,
  }) : assert(name != '', 'name cannot be empty');

  ApexGame copyWith({
    String? id,
    String? name,
    String? packageName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? localProfileName,
    bool clearPackageName = false,
    bool clearLocalProfileName = false,
  }) {
    return ApexGame(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: clearPackageName ? null : (packageName ?? this.packageName),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      localProfileName: clearLocalProfileName
          ? null
          : (localProfileName ?? this.localProfileName),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApexGame &&
        other.id == id &&
        other.name == name &&
        other.packageName == packageName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isFavorite == isFavorite &&
        other.localProfileName == localProfileName;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        packageName,
        createdAt,
        updatedAt,
        isFavorite,
        localProfileName,
      );

  @override
  String toString() {
    return 'ApexGame('
        'id: $id, '
        'name: $name, '
        'packageName: $packageName, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isFavorite: $isFavorite, '
        'localProfileName: $localProfileName'
        ')';
  }
}
