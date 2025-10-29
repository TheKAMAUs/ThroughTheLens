import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/model/clientmodel.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/preferences_service.dart';
import 'package:nanoid/nanoid.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Duration loginTime = Duration(milliseconds: 2250);
  final authService = AuthService();
  // ✅ Make sure we wait for the client to be fetched

  // Email/Password Sign Up Logic
  Future<String?> _signup(SignupData data) async {
    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: data.name!.trim(),
            password: data.password!.trim(),
          );

      final user = userCredential.user;
      if (user == null) return "User creation failed.";

      // 2. Extract additional fields
      final additional = data.additionalSignupData ?? {};
      final firstName = additional['first_name'] ?? '';
      final lastName = additional['last_name'] ?? '';
      final fullName = '$firstName $lastName';

      final role = additional['role'] ?? 'user';

      // 3. Create UserModel object
      final newUser = Client(
        userId: _generateUserId(),
        userUId: user.uid,
        name: fullName,
        email: user.email ?? '',
        profileImageUrl: '', // 👈 leave profile image empty
        role: role,
        editor: false, // 👈 default editor to false
        bio: '', // 👈 leave bio empty
        phoneNumber: 0, // 👈 keep phone number empty
        sampleVideos: [],
        rating: null,
        totalEdits: null,
        createdAt: DateTime.now(),
      );

      // 4. Save to Firestore
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .set(newUser.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    }
  }

  String _generateUserId() {
    return customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);
  }

  // Email/Password Sign In Logic
  Future<String?> _login(LoginData data) async {
    try {
      // 1️⃣ Sign in the user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: data.name.trim(),
        password: data.password.trim(),
      );

      // 2️⃣ Fetch and cache the client info from Firestore
      await authService.fetchClient();

      // 3️⃣ Save UID securely after successful login
      final user = userCredential.user;
      if (user != null) {
        await PreferencesService.saveUid(user.uid);
        print('🔐 UID saved securely: ${user.uid}');
      }

      // 4️⃣ Return null means success
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific auth errors
      return _handleAuthError(e.code);
    } catch (e) {
      print('❌ Unexpected login error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Password Recovery
  Future<String?> _recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    }
  }

  // Friendly FirebaseAuth errors
  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'The email or password you entered is incorrect. Please try again.';

      case 'wrong-password':
        return 'Wrong password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Something went wrong. [$code]';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      // ✅ Title, logo & theme
      title: 'memoriesweb',
      onLogin: _login, // LoginData → Future<String?>
      onSignup: _signup,
      onSubmitAnimationCompleted: () {
        // Navigate to dashboard or home after success
        Future.microtask(
          () => context.go(
            Routes.home, // Pass the productData as an argument
          ),
        );
      },

      logo: AssetImage('assets/IMG_20250929_080615.jpg'),
      theme: LoginTheme(
        primaryColor: Colors.teal.shade700,
        accentColor: Colors.orange,
        titleStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        bodyStyle: TextStyle(color: Colors.black87),
        cardTheme: CardTheme(
          color: const Color.fromARGB(255, 232, 215, 215),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        buttonTheme: LoginButtonTheme(
          backgroundColor: Colors.orangeAccent,
          highlightColor: Colors.white,
          splashColor: Colors.deepOrange,
        ),
        // Add this to customize the typed text color
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          // This controls the color of the text being typed
          hintStyle: TextStyle(color: Colors.grey.shade600),
          // This styles the actual typed text
          labelStyle: TextStyle(color: Colors.black),
          floatingLabelStyle: TextStyle(color: Colors.teal.shade700),
          // This is for the text the user types
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ),
        // Alternative: You can also use textFieldStyle
        textFieldStyle: TextStyle(
          color: Colors.black, // This changes the typed text color
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),

      // ✅ Enable multi-step sign up with extra fields
      additionalSignupFields: const [
        UserFormField(
          keyName: 'first_name',
          displayName: 'First Name',
          icon: Icon(Icons.person_outline),
        ),
        UserFormField(
          keyName: 'last_name',
          displayName: 'Last Name',
          icon: Icon(Icons.person),
        ),
      ],

      // ✅ TOS + Privacy
      termsOfService: [
        TermOfService(
          id: 'privacy-policy',
          mandatory: true,
          text: 'Privacy Policy',
          linkUrl: 'https://memoriesprivacy.pages.dev/',
        ),
      ],

      // ✅ Forgot password UX
      onRecoverPassword: _recoverPassword,
      navigateBackAfterRecovery: true,
      hideForgotPasswordButton: false,

      // // ✅ Social (if applicable)
      // loginProviders: [
      //   LoginProvider(
      //     icon: Icons.g_mobiledata,
      //     label: 'Sign in with Google',
      //     callback: () async {
      //       // TODO: Add Google sign in
      //       return null;
      //     },
      //   ),
      // ],

      // ✅ Initial mode & transitions
      initialAuthMode: AuthMode.login,
      disableCustomPageTransformer: false,
      scrollable: true,

      // ✅ Advanced callbacks (if needed)
      onSwitchToAdditionalFields: (_) {
        print("Switched to additional signup fields");
      },
      // onSwitchAuthMode: () {
      //   print("Switched login/signup mode");
      // },
      // onConfirmRecover: (email, code) async {
      //   print("Code confirmed: $code for $email");
      //   return null;
      // },
      // onResendCode: (email) async {
      //   print("Resending code to $email");
      //   return null;
      // },
      // onConfirmSignup: (SignupData data, String code) async {
      //   print("Confirming signup for ${data.name} with code $code");
      //   return null;
      // },
      // confirmSignupRequired: false,

      // ✅ UX polish
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      autofocus: true,
      // savedEmail: 'johndoe89@gmail.com', // for pre-filling
      // savedPassword: 'Blu3T!ger#9Two',

      // 👇 Customizes the hint texts
      messages: LoginMessages(
        userHint: 'Your Email', // Placeholder for username/email field
        passwordHint: 'Your Password', // Placeholder for password field
        confirmPasswordHint: 'Confirm Key', // Sign up confirmation
        loginButton: 'Login', // Login button text
        signupButton: 'Sign Up', // Sign up button text
        forgotPasswordButton: 'Forgot your password?', // link text
        recoverPasswordButton: 'Send Reset Link', // reset button
        goBackButton: '← Back',
        confirmPasswordError: 'Passwords don’t match!',
        recoverPasswordIntro: 'Enter your email to reset your password.',
        recoverPasswordDescription: 'We’ll send a reset link to your inbox.',
        flushbarTitleError: 'Oh no!',
        flushbarTitleSuccess: 'Success!',
        providersTitleFirst: 'Sign in using',
        // // Here’s what you’re asking about ⤵
        // loginAfterSignUp: true,
        // additionalSignupFields: [],
        // // Custom side messages:
        // signupTerms: 'By signing up, you agree to our Terms & Conditions.',
        // signupSuccess: 'Welcome aboard! 🎉',
      ),
    );
  }
}
