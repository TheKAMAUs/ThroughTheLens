import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoriesweb/app/app.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/data/payment_Repo.dart';

import 'package:memoriesweb/firebase_options.dart';
import 'package:memoriesweb/navigation/router.dart';
import 'package:memoriesweb/network/bloc/network_bloc.dart';
import 'package:memoriesweb/network/bloc/network_state.dart';
import 'package:memoriesweb/orderBloc/order_cubit.dart';
import 'package:memoriesweb/photo/photo_picker.dart';
import 'package:memoriesweb/theme/themebloc.dart';
import 'package:memoriesweb/videoBloc/videocubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configLoading();
  // Pass initialized objects to your App widget

  // Initialize dependencies
  final dio = Dio();
  final authService = AuthService();
  // ✅ Make sure we wait for the client to be fetched
  await authService.fetchClient();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final photoPicker = PhotoPicker(imagePicker: ImagePicker());
  final FirebaseStorageRepo _storage = FirebaseStorageRepo();

  final OrderServiceRepo fire = OrderServiceRepo();

  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: photoPicker),

        BlocProvider<OrderCubit>(create: (_) => OrderCubit(_storage, fire)),
        BlocProvider(create: (_) => NetworkCubit()),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<VideoCubit>(create: (_) => VideoCubit()..fetchVideos()),
      ],
      child: const MyApp(), // <- just build App here
    ),
  );
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorWidget = Image.network(
      "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif",
      fit: BoxFit.cover,
      width: 60,
      height: 60,
    )
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

// flutter pub run flutter_launcher_icons:main
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder:
          (context, currentTheme) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: "memoriesweb",
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            themeMode: ThemeMode.system,
            theme: currentTheme,
            builder: (context, child) {
              return BlocConsumer<NetworkCubit, NetworkState>(
                listener: (context, state) {
                  final messenger = ScaffoldMessenger.of(context);

                  if (state is NetworkDisconnected) {
                    final materialBanner = MaterialBanner(
                      elevation: 0,
                      actions: const [SizedBox.shrink()],
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: "⚠️ No Connection",
                        message: "No internet connection detected.",
                        contentType: ContentType.failure,
                      ),
                    );

                    messenger
                      ..hideCurrentMaterialBanner()
                      ..showMaterialBanner(materialBanner);
                  } else if (state is NetworkConnected) {
                    messenger.clearMaterialBanners();
                  }
                },
                builder: (context, state) {
                  return EasyLoading.init()(context, child);
                },
              );
            },
          ),
    );
  }
}
