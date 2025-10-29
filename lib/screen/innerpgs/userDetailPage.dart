import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/preferences_service.dart';

import 'package:memoriesweb/screen/editorApplicationPage.dart';

import 'package:memoriesweb/theme/themebloc.dart';
import 'package:tapped/tapped.dart';

class UserDetailPage extends StatelessWidget {
  UserDetailPage({Key? key}) : super(key: key);

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    late bool isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 18,
                ),

                title: Text(
                  'Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: CupertinoSwitch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeCubit.toggleTheme();
                  },
                ),
              ),
              SizedBox(height: 5),
              // ✅ Conditional: Become Editor (shown only if NOT an editor)
              if (!(globalUserDoc?.editor ?? false))
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () async {
                      final shouldBecomeEditor = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Become an Editor?'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'As an editor, you will be responsible for:',
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '• Receiving and editing client videos.',
                                  ),
                                  Text(
                                    '• Uploading the final edited versions.',
                                  ),
                                  Text(
                                    '• Meeting deadlines and maintaining quality.',
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "🎉 Congratulations on taking the first step!",
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (shouldBecomeEditor == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditorApplicationPage(),
                          ),
                        );
                      }
                    },
                    child: ListTile(
                      title: const Text(
                        'Become an editor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.push(Routes.nestedUserHistory);
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history),
                        const SizedBox(width: 8),
                        const Text(
                          "History",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirm Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (shouldSignOut == true) {
                      await PreferencesService.clearUid();
                      await authService.signOut();
                      Future.microtask(() => context.go(Routes.loginPageRIV));
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 7,
                    ),
                    title: Text('Sign out'),
                    tileColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





    // child: ClipOval(
    //         child: Image.network(
    //           (globalUserDoc?.profileImageUrl != null &&
    //                   globalUserDoc!.profileImageUrl.isNotEmpty)
    //               ? globalUserDoc!.profileImageUrl
    //               : "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif",
    //           fit: BoxFit.cover,
    //         ),
    //       ),




              // Text(
              //         (globalUserDoc?.bio != null &&
              //                 globalUserDoc!.bio.isNotEmpty)
              //             ? globalUserDoc!.bio
              //             : "my bio",
              //         style: StandardTextStyle.smallWithOpacity.apply(
              //           color: Colors.white,
              //         ),
              //       ),