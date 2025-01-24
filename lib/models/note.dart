class Note {
  final String title;
  final String content;
  final String? password; 
  final DateTime? reminder; 

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
      password: json['password'], 
      reminder: json['reminder'] != null
          ? DateTime.parse(json['reminder'])
          : null, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'password': password, 
      'reminder': reminder?.toIso8601String(), 
    };
  }
}
