class UserModel {
  final String name;
  final String email;
  final String birthDate;

  UserModel({
    required this.name,
    required this.email,
    required this.birthDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nombre': name,
      'Email': email,
      'Fecha_nacimiento': birthDate,
      'id_rol': 1,
    };
  }
}
