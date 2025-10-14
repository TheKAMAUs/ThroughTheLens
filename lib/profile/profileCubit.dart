// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:memoriesweb/model/usermodel.dart';
// import 'package:memoriesweb/profile/profileState.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final UserRepository userRepo;

//   ProfileCubit(this.userRepo) : super(ProfileInitial());

//   Future<void> loadProfile(String userId) async {
//     emit(ProfileLoading());
//     try {
//       final user = await userRepo.getUserById(userId);
//       emit(ProfileLoaded(user));
//     } catch (e) {
//       emit(ProfileError("Failed to load profile: $e"));
//     }
//   }

//   Future<void> updateProfile(UserModel updatedUser) async {
//     emit(ProfileLoading());
//     try {
//       await userRepo.updateUser(updatedUser);
//       emit(ProfileLoaded(updatedUser));
//     } catch (e) {
//       emit(ProfileError("Failed to update profile: $e"));
//     }
//   }

//   void setProfile(UserModel user) {
//     emit(ProfileLoaded(user));
//   }

//   void clear() {
//     emit(ProfileInitial());
//   }
// }
