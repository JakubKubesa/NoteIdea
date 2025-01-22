class Note {
  final String title;
  final String content;
  final String? password; // Přidané pole pro heslo (nepovinné)
  final DateTime? reminder; // Přidané pole pro upozornění (nepovinné)

  Note({
    required this.title,
    required this.content,
    this.password,
    this.reminder,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      password: json['password'], // Načítání hesla z JSON
      reminder: json['reminder'] != null
          ? DateTime.parse(json['reminder'])
          : null, // Načítání upozornění z JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'password': password, // Ukládání hesla do JSON
      'reminder': reminder?.toIso8601String(), // Ukládání upozornění do JSON
    };
  }
}
