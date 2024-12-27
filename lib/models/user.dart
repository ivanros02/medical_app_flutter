class User {
  final int id;
  final String usuario;

  User({required this.id, required this.usuario});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      usuario: json['usuario'],
    );
  }
}
