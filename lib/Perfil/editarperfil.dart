import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final ImageProvider avatarImage;

  const EditProfileScreen({
    Key? key,
    this.userProfile,
    required this.avatarImage,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdateController;
  File? _image;
  ImageProvider? _imageProvider;
  final picker = ImagePicker();
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _nameController =
        TextEditingController(text: widget.userProfile?['Nombre']);
    _emailController =
        TextEditingController(text: widget.userProfile?['Email']);
    _birthdateController =
        TextEditingController(text: widget.userProfile?['Fecha_nacimiento']);
    _imageProvider = widget.avatarImage;
  }

  void _fetchUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageProvider = FileImage(_image!);
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      String? avatarUrl;
      if (_image != null && _image?.path != null) {
        avatarUrl = await _uploadImage();
      }
      _updateProfileData(avatarUrl);
    } catch (error) {
      print('Error al actualizar el perfil: $error');
    }
  }

  Future<String?> _uploadImage() async {
    File imageFile = File(_image!.path);
    if (await imageFile.exists()) {
      Reference ref =
          FirebaseStorage.instance.ref().child('profiles').child('$userId.jpg');
      UploadTask uploadTask = ref.putFile(_image!);
      await uploadTask;
      return ref.getDownloadURL();
    } else {
      print('El archivo de imagen no existe en la ruta especificada.');
      return null;
    }
  }

  void _updateProfileData(String? avatarUrl) {
    Map<String, dynamic> updates = {
      'Nombre': _nameController.text,
      'Email': _emailController.text,
      'Fecha_nacimiento': _birthdateController.text,
    };
    if (avatarUrl != null) {
      updates['Avatar'] = avatarUrl;
    }
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .update(updates)
        .then((_) {
      if (mounted) {
        Navigator.pop(context, updates);
      }
    }).catchError((error) {
      print('Error al actualizar el perfil: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: _getImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _imageProvider,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: _birthdateController,
              decoration: InputDecoration(labelText: 'Fecha de Nacimiento'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Color de fondo azul
                    ),
              child: Text('Guardar Cambios',style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
