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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'packageName': packageName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'localProfileName': localProfileName,
    };
  }

  static ApexGame fromJson(Map<String, dynamic> map) {
    return ApexGame(
      id: map['id'] as String,
      name: map['name'] as String,
      packageName: map['packageName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isFavorite: (map['isFavorite'] as bool?) ?? false,
      localProfileName: map['localProfileName'] as String?,
    );
  }

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
