class Validator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un nombre';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Correo electrónico obligatorio';
    }
    if (!RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
            caseSensitive: false)
        .hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Es obligatorio confirmar la contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validateFechaNacimiento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    try {
      DateTime pickedDate = DateTime.parse(value);
      int ageDifference = DateTime.now().year - pickedDate.year;
      if (ageDifference < 12) {
        return 'Debes tener al menos 12 años para registrarte';
      }
    } catch (e) {
      return 'Fecha inválida';
    }
    return null;
  }
}
