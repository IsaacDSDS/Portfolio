class Tag {
  final String identifier;
  final String title;
  const Tag({required this.identifier, this.title = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'Tag(identifier: $identifier, hashCode: $hashCode)';

  static Tag get finder => const Tag(identifier: 'Finder');
}
