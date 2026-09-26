import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_profile.dart';
import '../../providers/current_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _birthdateController;

  String? _gender;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(text: widget.profile.fullName);

    _usernameController = TextEditingController(text: widget.profile.username);

    _bioController = TextEditingController(text: widget.profile.bio);

    _birthdateController = TextEditingController(
      text: widget.profile.birthdate,
    );

    _gender = widget.profile.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      String? avatarUrl = widget.profile.avatarUrl;

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();

        final extension = _selectedImage!.name.split('.').last;

        avatarUrl = await ref
            .read(profileServiceProvider)
            .uploadProfilePhoto(bytes: bytes, fileExtension: extension);
      }

      await ref
          .read(profileServiceProvider)
          .updateUserProfile(
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
            gender: _gender!,
            birthdate: _birthdateController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: avatarUrl,
          );

      ref.invalidate(currentProfileProvider);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $error')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path))
                        : widget.profile.avatarUrl != null
                        ? NetworkImage(widget.profile.avatarUrl!)
                        : null,
                    child:
                        _selectedImage == null &&
                            widget.profile.avatarUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Change Photo'),
                  ),
                ],
              ),
            ),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixText: '@',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a username';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthdateController,
              decoration: const InputDecoration(
                labelText: 'Birthdate',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your birthdate';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 500,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Bio must be less than 500 characters';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell people about yourself',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
