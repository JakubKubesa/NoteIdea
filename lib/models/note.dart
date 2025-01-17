class Note {
  final String title;
  final String content;
  final String? password; // Přidané pole pro heslo (nepovinné)

  Note({
    required this.title,
    required this.content,
    this.password,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      password: json['password'], // Načítání hesla z JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'password': password, // Ukládání hesla do JSON
    };
  }
}
