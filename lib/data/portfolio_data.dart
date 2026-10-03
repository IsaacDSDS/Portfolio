import 'package:so_portfolio/models/info.dart';

abstract final class PortfolioData {
  static final Info info = Info(
    name: '',
    subTitle: '',
    profilePicture: '',
    skills: const [],
    country: '',
    city: '',
    isAvailableForWork: false,
  );

  static const List<Project> projects = [];

  static const List<Contact> contacts = [];
}
