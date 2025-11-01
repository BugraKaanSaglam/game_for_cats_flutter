enum Language {
  turkish(0, "Türkçe", "tr"),
  english(1, "English", "en");

  const Language(this.value, this.name, this.shortName);
  final int value;
  final String name;
  final String shortName;
}

enum Difficulty {
  easy(0, 'Easy'),
  medium(1, 'Medium'),
  hard(2, 'Hard'),
  sandbox(3, 'Sandbox');

  const Difficulty(this.value, this.name);
  final int value;
  final String name;
}

enum Time {
  fifty(50, '50'),
  hundered(100, '100'),
  twohundered(200, '200'),
  sandbox(100000, 'Sandbox');

  const Time(this.value, this.name);
  final int value;
  final String name;
}
