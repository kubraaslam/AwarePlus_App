// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:aware_plus/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  final bool showBackButton;

  const ProfileView({super.key, this.showBackButton = false});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _email = '';
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      _email = _user!.email ?? '';
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      final data = doc.data();
      if (data != null) {
        _username = data['username'] ?? '';
      }
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _changeUsernameDialog() async {
    final controller = TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Change Username"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'New Username'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  String newName = controller.text.trim();
                  if (newName.isEmpty || newName.length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Username must be at least 3 characters"),
                      ),
                    );
                    return;
                  }
                  await _firestore.collection('users').doc(_user!.uid).update({
                    'username': newName,
                  });
                  setState(() => _username = newName);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Username updated")),
                  );
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  Future<void> _changeEmailDialog() async {
    final controller = TextEditingController(text: _email);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Change Email"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'New Email'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    String newEmail = controller.text.trim();

                    if (!emailRegex.hasMatch(newEmail)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid email address"),
                        ),
                      );
                      return;
                    }
                    await _user!.verifyBeforeUpdateEmail(newEmail);
                    setState(() => _email = newEmail);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email updated")),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  Future<void> _changePasswordDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Change Password"),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  String newPass = controller.text.trim();
                  if (newPass.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password must be at least 6 characters"),
                      ),
                    );
                    return;
                  }
                  try {
                    await _user!.updatePassword(newPass);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password updated")),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 229, 117, 126),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('assets/img/default_avatar.png')
                                as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xB3000000),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              _username,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Divider(height: 40),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Change Username"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _changeUsernameDialog,
            ),

            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Change Email"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _changeEmailDialog,
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _changePasswordDialog,
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Confirm Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await _auth.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },

              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.showBackButton
              ? null
              : BottomNavBar(
                currentIndex: 3,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.pushReplacementNamed(context, '/home');
                      break;
                    case 1:
                      Navigator.pushReplacementNamed(context, '/knowledge');
                      break;
                    case 2:
                      Navigator.pushReplacementNamed(context, '/support');
                      break;
                    case 3:
                      break;
                  }
                },
              ),
    );
  }
}
