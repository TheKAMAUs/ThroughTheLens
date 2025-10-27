import 'package:memoriesweb/data/auth_service.dart';

import 'package:memoriesweb/navigation/router.dart';
import 'package:memoriesweb/network/bloc/network_bloc.dart';
import 'package:memoriesweb/network/bloc/network_state.dart';
import 'package:memoriesweb/photo/photo_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "memoriesweb",
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color.fromARGB(255, 3, 2, 2),
        scaffoldBackgroundColor: const Color.fromARGB(255, 120, 109, 109),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      builder: (context, child) {
        return BlocListener<NetworkCubit, NetworkState>(
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);

            if (state is NetworkDisconnected) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: const Text(
                      "⚠️ No internet connection detected.",
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(
                      days: 1,
                    ), // stays until reconnected
                  ),
                );
            } else if (state is NetworkConnected) {
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    "✅ Back online!",
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Scaffold(body: EasyLoading.init()(context, child)),
        );
      },
    );
  }
}
