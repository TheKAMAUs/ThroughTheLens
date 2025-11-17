// class Routes {
//   Routes._();

//   // New routes
//   static const String splashScreen = '/splash';
//   static const String updateApp = 'update';
//   static const String nestedupdatePage = '/splash/update';

//   static const String authWrapper = '/auth'; // Set as the root route
//   // static const String nestedAuth = '/splash/auth';

//   static const String loginPageRIV = '/login';

//   static const String signupPageRIV = 'signup';
//   static const String nestedSignup = '/loginRIV/signup';
//   static const String forgetPass = 'forgetpass';
//   static const String nestedForget = '/loginRIV/forgetpass';

//   static const String home = '/home';
//   static const String explore = '/explore';
//   static const String upload = '/upload';
//   static const String uploadwitheditor = '/upload/:assignedEditorId';

//   static const String profile = '/profile';
//   static const String profilEdit = 'edit'; // relative to profile
//   static const String userDetailPage = 'details'; // relative to profile
//   static const String userHistory = 'history';

//   // Nested (relative to profile)
//   static const String nestedProfileEdit = '/profile/edit';
//   static const String nestedUserDetail = '/profile/details';
//   static const String nestedUserHistory = '/profile/details/history';

//   static const String support = '/support';
//   static const String videos = 'videos';
//   static const String nestednormalUpload = '/upload/videos';
//   static const String videoswithEditor = 'videos';
//   static const String nestedWithEditor = '/upload/:assignedEditorId/videos';
//   static const String videoEdited = '/videos/:edited';
//   static const String videoComplaint = '/videos-comp/:complaint';

//   static const String assignedOrders = 'assigned';
//   static const String acceptedOrders = 'accepted';
//   static const String nestedAccepted = '/explore/accepted';
//   static const String nestedAssigned = '/explore/assigned';

//   // 🎬 New FullScreenVideoPage route
//   static const String fullScreenVideo = 'video';
//   static const String nestedExPFullScreenVideo = '/explore/video';
//   static const String nestedhomeFullScreenVideo = '/home/video';

//   // 🖼️ Image routes
//   static const String fullScreenImage = 'image';
//   static const String nestedExPFullScreenImage = '/explore/image';
//   static const String nestedhomeFullScreenImage = '/home/image';
// }

enum RoutesEnum {
  // 🌊 Splash & Update
  splash(
    path: '/splash',
    name: 'Splash',
    title: 'Splash Screen',
    description: 'Initial loading screen of the app',
  ),
  updateApp(
    path: 'update',
    name: 'UpdateApp',
    title: 'Update Application',
    description: 'Check for the latest app updates',
  ),
  nestedUpdatePage(
    path: '/splash/update',
    name: 'NestedUpdate',
    title: 'Update Page (Nested)',
    description: 'Nested update page under Splash',
  ),

  // 🔐 Authentication
  authWrapper(
    path: '/auth',
    name: 'AuthWrapper',
    title: 'Authentication Wrapper',
    description: 'Main authentication entry point',
  ),
  loginPageRIV(
    path: '/login',
    name: 'LoginRIV',
    title: 'Login Page',
    description: 'Login page for registered users',
  ),
  signupPageRIV(
    path: 'signup',
    name: 'SignupRIV',
    title: 'Signup Page',
    description: 'User registration page',
  ),
  nestedSignup(
    path: '/loginRIV/signup',
    name: 'NestedSignup',
    title: 'Nested Signup',
    description: 'Signup nested under login route',
  ),
  forgetPass(
    path: 'forgetpass',
    name: 'ForgetPass',
    title: 'Forgot Password',
    description: 'Password recovery page',
  ),
  nestedForget(
    path: '/loginRIV/forgetpass',
    name: 'NestedForgetPass',
    title: 'Nested Forgot Password',
    description: 'Nested forgot password route under login',
  ),

  // 🏠 Home
  home(
    path: '/home',
    name: 'Home',
    title: 'Home | Through The Lens – Capture and Relive Memories',
    description:
        'Discover your personalized feed of shared moments and creative memories. Through The Lens connects you to stories, travel journeys, and videos that inspire emotion and creativity.',
    keywords:
        'memories, home, social media, photos, videos, storytelling, creativity, photography, Through The Lens, share memories',
    robots: 'index, follow',
    canonicalUrl: 'https://throughthelens.pages.dev/home',
    imageUrl: 'https://throughthelens.pages.dev/assets/meta/home.jpg',
    schemaType: 'WebPage',
  ),

  // 🔍 Explore
  explore(
    path: '/explore',
    name: 'Explore',
    title: 'Explore | Trending Memories & Creative Stories – Through The Lens',
    description:
        'Explore trending photos, videos, and heartfelt stories shared by creators around the world. Join Through The Lens to connect, discover, and celebrate creativity through authentic memories.',
    keywords:
        'explore, trending, social discovery, videos, photos, memories, creativity, global creators, Through The Lens, digital storytelling',
    robots: 'index, follow',
    canonicalUrl: 'https://throughthelens.pages.dev/explore',
    imageUrl: 'https://throughthelens.pages.dev/assets/meta/explore.jpg',
    schemaType: 'CollectionPage',
  ),

  // ⬆️ Upload
  upload(
    path: '/upload',
    name: 'Upload',
    title: 'Upload | Share Your Story and Memories – Through The Lens',
    description:
        'Upload your photos and videos to share your story with the world. Through The Lens empowers creators to express themselves, showcase moments, and inspire others with visual storytelling.',
    keywords:
        'upload, memories, share, videos, photos, creativity, storytelling, Through The Lens, digital creation, social sharing',
    robots: 'index, follow',
    canonicalUrl: 'https://throughthelens.pages.dev/upload',
    imageUrl: 'https://throughthelens.pages.dev/assets/meta/upload.jpg',
    schemaType: 'MediaGallery',
  ),
  uploadWithEditor(
    path: '/upload26/:assignedEditorId',
    name: 'UploadWithEditor',
    title: 'Upload With Editor',
    description: 'Upload page with editor assignment',
  ),
  // 🎥 Videos
  videos(
    path: '/videos',
    name: 'Videos',
    title: 'Watch Videos | Explore Shared Memories – Through The Lens',
    description:
        'Watch emotional, creative, and cinematic video memories shared by storytellers worldwide. Discover lifestyle clips, travel experiences, and inspiring moments all in one place on Through The Lens.',
    keywords:
        'videos, watch, memories, cinematic, storytelling, short films, lifestyle, travel, creative videos, Through The Lens, global stories',
    robots: 'index, follow',
    canonicalUrl: 'https://throughthelens.pages.dev/videos',
    imageUrl: 'https://throughthelens.pages.dev/assets/meta/videos.jpg',
    schemaType: 'VideoGallery',
  ),
  nestedNormalUpload(
    path: '/upload/videos',
    name: 'NestedNormalUpload',
    title: 'Nested Normal Upload',
    description: 'Video upload nested route',
  ),
  videosWithEditor(
    path: 'videos',
    name: 'VideosWithEditor',
    title: 'Videos With Editor',
    description: 'Videos assigned to specific editor',
  ),
  nestedWithEditor(
    path: '/upload/:assignedEditorId/videos',
    name: 'NestedWithEditor',
    title: 'Nested Editor Uploads',
    description: 'Videos uploaded under specific editor ID',
  ),
  videoEdited(
    path: '/videos/:edited',
    name: 'VideoEdited',
    title: 'Edited Video',
    description: 'View edited video content',
  ),
  videoComplaint(
    path: '/videos-comp/:complaint',
    name: 'VideoComplaint',
    title: 'Video Complaint',
    description: 'File or view a video complaint',
  ),

  // 👤 Profile
  profile(
    path: '/profile',
    name: 'Profile',
    title: 'Your Profile – Memories',
    description: 'View and manage your profile, uploads, and favorites.',
    keywords: 'profile, user, account, settings, favorites, uploads',
    robots: 'index, follow', // ✅ added
    canonicalUrl: 'https://throughthelens.pages.dev/profile',
    imageUrl: 'https://throughthelens.pages.dev/assets/meta/profile.jpg',
    schemaType: 'ProfilePage', // ✅ added structured data type
  ),

  profileEdit(
    path: 'edit',
    name: 'ProfileEdit',
    title: 'Edit Profile',
    description: 'Edit user profile information',
  ),
  userDetailPage(
    path: 'details',
    name: 'UserDetailPage',
    title: 'User Details',
    description: 'Detailed user information',
  ),
  userHistory(
    path: 'history',
    name: 'UserHistory',
    title: 'User History',
    description: 'User activity and history',
  ),
  nestedProfileEdit(
    path: '/profile/edit',
    name: 'NestedProfileEdit',
    title: 'Nested Profile Edit',
    description: 'Profile edit page under /profile',
  ),
  nestedUserDetail(
    path: '/profile/details',
    name: 'NestedUserDetail',
    title: 'Nested User Details',
    description: 'User details nested under profile',
  ),
  nestedUserHistory(
    path: '/profile/details/history',
    name: 'NestedUserHistory',
    title: 'Nested User History',
    description: 'History nested under user details',
  ),

  // 🆘 Support
  support(
    path: '/support',
    name: 'Support',
    title: 'Support Page',
    description: 'Help and support center',
  ),

  // 🧾 Orders
  assignedOrders(
    path: 'assigned',
    name: 'AssignedOrders',
    title: 'Assigned Orders',
    description: 'Orders assigned to the user/editor',
  ),
  acceptedOrders(
    path: 'accepted',
    name: 'AcceptedOrders',
    title: 'Accepted Orders',
    description: 'Orders accepted by the user',
  ),
  nestedAccepted(
    path: '/explore/accepted',
    name: 'NestedAcceptedOrders',
    title: 'Nested Accepted Orders',
    description: 'Nested accepted orders route',
  ),
  nestedAssigned(
    path: '/explore/assigned',
    name: 'NestedAssignedOrders',
    title: 'Nested Assigned Orders',
    description: 'Nested assigned orders route',
  ),

  // 🎬 Full Screen Video
  fullScreenVideo(
    path: 'video',
    name: 'FullScreenVideo',
    title: 'Full Screen Video',
    description: 'View videos in full screen mode',
  ),
  nestedExpFullScreenVideo(
    path: '/explore/video',
    name: 'NestedExploreFullScreenVideo',
    title: 'Nested Explore Full Screen Video',
    description: 'Full screen video under explore',
  ),
  nestedHomeFullScreenVideo(
    path: '/home/video',
    name: 'NestedHomeFullScreenVideo',
    title: 'Nested Home Full Screen Video',
    description: 'Full screen video under home',
  ),

  // 🖼️ Full Screen Image
  fullScreenImage(
    path: 'image',
    name: 'FullScreenImage',
    title: 'Full Screen Image',
    description: 'View images in full screen mode',
  ),
  nestedExpFullScreenImage(
    path: '/explore/image',
    name: 'NestedExploreFullScreenImage',
    title: 'Nested Explore Full Screen Image',
    description: 'Full screen image under explore',
  ),
  nestedHomeFullScreenImage(
    path: '/home/image',
    name: 'NestedHomeFullScreenImage',
    title: 'Nested Home Full Screen Image',
    description: 'Full screen image under home',
  );

  final String path;
  final String name;
  final String title;
  final String description;
  final String? keywords;
  final String? robots;
  final String? canonicalUrl;
  final String? imageUrl;
  final String? schemaType;

  const RoutesEnum({
    required this.path,
    required this.name,
    required this.title,
    required this.description,
    this.keywords,
    this.robots,
    this.canonicalUrl,
    this.imageUrl,
    this.schemaType,
  });
}
