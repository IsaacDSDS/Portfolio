class Tag {
  final String identifier;
  final String name;
  const Tag({required this.identifier, this.name = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'Tag(name: $identifier, hashCode: $hashCode)';

  static Tag get finder => const Tag(identifier: 'Finder');
}
