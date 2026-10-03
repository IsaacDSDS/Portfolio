import 'package:equatable/equatable.dart';

abstract class Tag {
  final String identifier;

  const Tag({required this.identifier});
}

/// Identity of a window. Presentation data (title, icon, ...) lives in the
/// window catalog, not here.
class WindowTag extends Tag with Equatable {
  const WindowTag({required super.identifier});

  @override
  List<Object?> get props => [identifier];

  @override
  String toString() => 'WindowTag(identifier: $identifier)';

  static WindowTag get finder => const WindowTag(identifier: 'Finder');
}

class NotificationTag extends Tag {
  NotificationTag({required super.identifier});
}
