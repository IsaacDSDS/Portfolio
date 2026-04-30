class Info {
  final String name;
  final String subTitle;
  final String profilePicture;
  final List<Skill> skills;
  final String country;
  final String city;
  final bool isAvailableForWork;

  Info({
    required this.name,
    required this.subTitle,
    required this.profilePicture,
    required this.skills,
    required this.country,
    required this.city,
    required this.isAvailableForWork,
  });
}

class Skill {
  final String name;
  final int value;
  final int color;

  const Skill({required this.name, required this.value, required this.color});
}

class Project {
  final String name;
  final List<String> technologies;
  final String description;
  final String url;

  const Project({
    required this.name,
    required this.technologies,
    required this.description,
    required this.url,
  });
}

class Contact {
  final String name;
  final String icon;
  final String url;

  const Contact({required this.name, required this.icon, required this.url});
}
