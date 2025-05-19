import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _profilePicUrl;
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserService.getProfile();
    if (!mounted) return;
    setState(() {
      _name = profile?['username'];
      _email = profile?['email'];
      _profilePicUrl = profile?['profilePic'];
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final success = await UserService.updateProfile(
      username: _name!,
      email: _email!,
      imageFile: _imageFile,
      removeImage: _profilePicUrl == null && _imageFile == null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Profile updated' : 'Failed to update profile'),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _imageFile = File(picked.path);
        _profilePicUrl = null;
      });
    }
  }

  Future<void> _deleteImage() async {
    setState(() {
      _imageFile = null;
      _profilePicUrl = null;
      _isLoading = true;
    });

    final success = await UserService.updateProfile(
      username: _name ?? '',
      email: _email ?? '',
      imageFile: null,
      removeImage: true,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Profile picture removed' : 'Failed to remove picture'),
      ),
    );
  }

  Widget _buildProfileImage() {
    ImageProvider imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_profilePicUrl!);
    } else {
      return const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60));
    }

    return CircleAvatar(radius: 60, backgroundImage: imageProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor:  Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _buildProfileImage(),
                    Positioned(
                      right: 78,
                      child: GestureDetector(
                        onTap: _deleteImage,
                        child: Tooltip(
                          message: 'Remove Profile Picture',
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.delete, size: 20, color: Colors.red[700]),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Tooltip(
                          message: 'Change Profile Picture',
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, size: 20, color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                  return null;
                },
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
