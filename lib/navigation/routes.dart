class Routes {
  Routes._();

  // New routes
  static const String splashScreen = '/splash';
  static const String updateApp = 'update';
  static const String nestedupdatePage = '/splash/update';

  static const String authWrapper = '/auth'; // Set as the root route
  // static const String nestedAuth = '/splash/auth';

  static const String loginPageRIV = '/login';

  static const String signupPageRIV = 'signup';
  static const String nestedSignup = '/loginRIV/signup';
  static const String forgetPass = 'forgetpass';
  static const String nestedForget = '/loginRIV/forgetpass';

  static const String home = '/home';
  static const String explore = '/explore';
  static const String upload = '/upload';
  static const String uploadwitheditor = '/upload/:assignedEditorId';
  static const String profile = '/profileSettings';

  static const String userDetailPage = '/details';
  static const String profilEdit = '/profilEdit';
  static const String support = '/support';
  static const String videos = '/videos';
  static const String videoswithEditor = 'videos';
  static const String nestedWithEditor = '/upload/:assignedEditorId/videos';
  static const String videoEdited = '/videos/:edited';
  static const String videoComplaint = '/videos-comp/:complaint';

  static const String assignedOrders = 'assigned';
  static const String acceptedOrders = 'accepted';
  static const String nestedAccepted = '/explore/accepted';
  static const String nestedAssigned = '/explore/assigned';

  // 🎬 New FullScreenVideoPage route
  static const String fullScreenVideo = 'video';
  static const String nestedExPFullScreenVideo = '/explore/video';
  static const String nestedhomeFullScreenVideo = '/home/video';

  // 🖼️ Image routes
  static const String fullScreenImage = 'image';
  static const String nestedExPFullScreenImage = '/explore/image';
  static const String nestedhomeFullScreenImage = '/home/image';
}
