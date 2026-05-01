class Tag {
  final String name;
  const Tag({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Tag(name: $name, hashCode: $hashCode)';

  static Tag get finder => const Tag(name: 'Finder');
}
