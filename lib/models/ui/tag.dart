abstract class Tag {
  final String identifier;

  const Tag({required this.identifier});
}

class WindowTag extends Tag {
  final String title;
  const WindowTag({required super.identifier, this.title = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowTag &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'Tag(identifier: $identifier, hashCode: $hashCode)';

  static WindowTag get finder => const WindowTag(identifier: 'Finder');
}

class NotificationTag extends Tag {
  NotificationTag({required super.identifier});
}
