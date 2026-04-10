import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ecommerce_app/services/auth_service.dart';
import 'package:ecommerce_app/Screens/Login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    setState(() {
      _user = currentUser;
      _nameController.text = currentUser?.displayName ?? '';
      _phoneController.text = currentUser?.phoneNumber ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Image Pick Error: $e');
      _showSnackBar('Could not select image.', Colors.redAccent);
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Name cannot be empty', Colors.redAccent);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnackBar('No authenticated user found.', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl = currentUser.photoURL;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profiles')
            .child('${currentUser.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        photoUrl = await storageRef.getDownloadURL();
      }
      await currentUser.updateDisplayName(_nameController.text);
      await currentUser.updatePhotoURL(photoUrl);
      await currentUser.reload();
      if (!mounted) return;
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _isLoading = false;
      });
      _showSnackBar('Profile updated successfully!', Colors.green);
    } catch (e) {
      debugPrint('Update Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Failed to update profile', Colors.redAccent);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _user?.email;
    if (email == null || email.isEmpty) {
      _showSnackBar('No email is available for reset.', Colors.redAccent);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar('Password reset email sent to $email', Colors.green);
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      _showSnackBar('Could not send reset email.', Colors.redAccent);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (_user == null) {
      _showSnackBar('No account available to delete.', Colors.redAccent);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await currentUser.delete();
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Delete Account Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      final message = e.code == 'requires-recent-login'
          ? 'Please sign in again to delete your account.'
          : 'Failed to delete account.';
      _showSnackBar(message, Colors.redAccent);
    } catch (e) {
      debugPrint('Delete Account Error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Failed to delete account.', Colors.redAccent);
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? 'No email connected';
    final memberSince = _user?.metadata.creationTime == null
        ? 'Unknown'
        : '${_user!.metadata.creationTime!.year}-${_user!.metadata.creationTime!.month.toString().padLeft(2, '0')}-${_user!.metadata.creationTime!.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 66,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_user?.photoURL != null
                                  ? NetworkImage(_user!.photoURL!)
                                  : const AssetImage(
                                      'assets/images/default_user.png',
                                    ))
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Profile Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Full Name',
                      _nameController,
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Phone Number',
                      _phoneController,
                      Icons.phone_android_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Email', email, Icons.email_outlined),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Member since'),
                        Text(
                          memberSince,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  )
                : ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepOrange,
                      child: Icon(Icons.lock_reset, color: Colors.white),
                    ),
                    title: const Text('Change Password'),
                    subtitle: const Text('Reset your password via email'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _sendPasswordReset,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.delete_forever, color: Colors.white),
                    ),
                    title: const Text('Delete Account'),
                    subtitle: const Text('Permanently remove your account'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _confirmDeleteAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.deepOrange),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: value,
          enabled: false,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.deepOrange),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
