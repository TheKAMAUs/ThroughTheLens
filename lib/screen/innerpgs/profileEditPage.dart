import 'package:flutter/material.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/responsive/constrained_scaffold.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _bioController = TextEditingController();
  final authService = AuthService();

  @override
  void dispose() {
    _bioController.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Edit Bio",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final bio = _bioController.text.trim();
                print("Saved bio: $bio");

                // Show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your bio has been updated'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Optionally close the page after showing the snackbar
                Future.delayed(Duration(milliseconds: 500), () {
                  Navigator.pop(context);

                  authService.updateClient(
                    client: globalUserDoc?.copyWith(bio: bio),
                  );
                });
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
