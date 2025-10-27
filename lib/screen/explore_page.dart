import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/data/transactions_service_repo.dart';
import 'package:memoriesweb/model/clientmodel.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenImagePage.dart';
import 'package:memoriesweb/screen/innerpgs/smallVideo.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:memoriesweb/screen/innerpgs/videoplay_Item.dart';
import 'package:memoriesweb/videoBloc/videoState.dart';
import 'package:memoriesweb/videoBloc/videocubit.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final OrderServiceRepo order = OrderServiceRepo();
  final authService = AuthService();
  final transService = TransServiceRepo();

  final typewriterController = AnimatedTextController();
  @override
  Widget build(BuildContext context) {
    var editorHeader = AppBar(
      title: const Text("Explore Orders"),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.more_vert),
        //   onPressed: () {
        //     // Handle menu tap
        //   },
        // ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            // Handle selected menu item
            if (value == 'orders') {
              // Go to settings
              context.push(Routes.nestedAccepted);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'orders', child: Text('Orders')),
                const PopupMenuItem(value: 'help', child: Text('Help')),
              ],
        ),
      ],
    );

    final clientHeader = AppBar(
      title: const Text("Choose an Editor"),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            // Handle selected menu item
            if (value == 'edited') {
              context.push(Routes.nestedAssigned); // Go to settings
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edited', child: Text('Orders')),
                const PopupMenuItem(value: 'help', child: Text('Help')),
              ],
        ),
      ],
    );

    Widget editorBody = StreamBuilder<List<OrderModel>>(
      stream: order.streamOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        final orders = snapshot.data!;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return
            // ListTile(
            //   title: Text(order.title ?? 'No Title'),
            //   subtitle: Text("Order ID: ${order.orderId}"),
            // );
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        (order.title != null && order.title!.isNotEmpty)
                            ? '-Title: ${order.title}'
                            : '-Title: NOT ADDED',
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.orderedAt?.year}-${order.orderedAt?.month}-${order.orderedAt?.day} • Source: ${order.amount}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (order.description != null &&
                                    order.description!.isNotEmpty)
                                ? '-Description: ${order.description}'
                                : '-Description: NOT ADDED',
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                    if (order.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                order.imageUrls.map((img) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        context.push(
                                          Routes.nestedExPFullScreenImage,
                                          extra: {'url': img, 'fordownload': 0},
                                        );
                                        print(
                                          '📤 Navigating to video page with URL: ${img}',
                                        );
                                      },

                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FadeInImage(
                                          placeholder: AssetImage(
                                            'assets/user_icon.png',
                                          ), // Placeholder image
                                          image: NetworkImage(img),
                                          fit: BoxFit.cover,
                                          // Set a default placeholder in case the image fails to load
                                          imageErrorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.asset(
                                              'assets/user_icon.png', // Fallback image
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],

                    if (order.videoUrls!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                order.videoUrls!.map((vid) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SmallVideo(
                                        url: vid,
                                        fordownload: 6,
                                        fromProfile: false,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        showOrderAcceptanceDialog(
                          context,
                          order: order, // optional
                        );
                      },
                      child: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    Widget clientBody = FutureBuilder<List<Client>>(
      future: authService.getEditors(), // 👈 Replace with your Future method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        final editors = snapshot.data!;

        return ListView.builder(
          itemCount: editors.length,
          itemBuilder: (context, index) {
            final editor = editors[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(editor.name ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Total Edits - ${editor.totalEdits}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Rating - ${editor.rating?[0]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- ${editor.bio}',
                            style: const TextStyle(
                              color: Color.fromARGB(221, 239, 237, 237),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),

                    if (editor.sampleVideos?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                editor.sampleVideos!.map((vid) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SmallVideo(
                                        url: vid,
                                        fordownload: 6,
                                        fromProfile: false,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12), // optional spacing
                    GestureDetector(
                      onTap: () {
                        showOrderAcceptanceDialog(
                          context,
                          client: editor, // optional
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'choose the editor',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    bool isUserAuthenticated = globalUserDoc != null;
    final mediaQuery = MediaQuery.of(context);
    final fem = mediaQuery.size.width / 428;
    if (!isUserAuthenticated) {
      return Scaffold(
        body: BlocBuilder<VideoCubit, VideoState>(
          builder: (context, state) {
            if (state.isLoading) {
              print('Loading videos...');
              return const Center(child: CircularProgressIndicator());
            } else if (state.hasError) {
              print('Error loading videos');
              return const Center(child: Text('Error loading videos 😕'));
            } else if (state.downloadedVideos.isEmpty) {
              print('No downloaded videos found.');
              return const Center(child: Text('No videos available yet 🚧'));
            }

            // ✅ Shuffle and take only 3 videos
            final List<Map<String, String>> videos = List.from(
              state.downloadedVideos,
            )..shuffle();
            final List<Map<String, String>> limitedVideos =
                videos.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),

                  // 👤 User placeholder
                  Center(child: noUser),

                  const SizedBox(height: 15),

                  // 🌈 Animated Welcome Text Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1E2C), Color(0xFF2E2E48)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            '🌟 Welcome! 👋\n\n'
                            'You’re about to start your creative journey 🎬✨\n\n'
                            '🎨 Choose your favorite editor — someone who’ll turn your photos and videos into stunning masterpieces.\n\n'
                            '📸 Tip: Watch the short clips below to learn how to take perfect shots —\n'
                            '💡 focus on good lighting, 📐 great angles, and 🔍 crystal clarity!',
                            cursor: '💡',
                            speed: Duration(milliseconds: 60),
                          ),
                        ],
                        totalRepeatCount: 3,
                        pause: Duration(seconds: 60),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                        controller: typewriterController,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🎥 Videos Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.play_circle_fill,
                        color: Colors.amber,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Watch sample videos below 👇",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 🎬 List of Sample Videos
                  ListView.builder(
                    itemCount: limitedVideos.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final videoData = limitedVideos[index];
                      final videoUrl = videoData['videoUrl']!;
                      final productName = videoData['firstName']!;
                      final description = videoData['description']!;

                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: VideoPlayerItem(
                          videoUrl: videoUrl,
                          fem: fem,
                          productName: productName,
                          description: description,
                          index: index,
                          onPageChanged: (_) {},
                          isPreloaded: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // ✅ If authenticated → show appropriate UI
    return Scaffold(
      appBar: globalUserDoc!.editor ? editorHeader : clientHeader,
      body: globalUserDoc!.editor ? editorBody : clientBody,
    );
  }

  void showOrderAcceptanceDialog(
    BuildContext context, {
    Client? client,
    OrderModel? order,
  }) {
    // 🔁 Dynamic title based on which object is passed
    final titleText = client != null ? 'Chosen Editor' : 'Order Accepted';
    final message =
        order != null
            ? '👋 Hey ${globalUserDoc?.name ?? 'Editor'}! 🎬 You’ve been *handpicked* to work on this project. Please turn the provided videos into ✨ engaging TikTok & Instagram Reels. Bring your creativity 💡 and speed ⚡ — deadline is *within 2 hours*! ⏱️'
            : '✅ Hi ${globalUserDoc?.name}, you’ve *successfully assigned* this order to an editor. 🧑‍💻 Keep an eye on their progress and ensure the final videos meet the highest standards ⭐. You can monitor everything from your dashboard 📊.';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(titleText),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Optional: Add logic using order or client if needed
                  if (client != null) {
                    // context.push(Routes.uploadwitheditor, extra: client.userId);

                    final replacedRoute = Routes.uploadwitheditor.replaceFirst(
                      ':assignedEditorId',
                      client.userId,
                    );

                    print('✅ Navigating to: $replacedRoute');

                    context.push(replacedRoute);
                  }

                  if (order != null) {
                    // 🛑 If already assigned, show a message and stop
                    if (order.assignedEditorId != null &&
                        order.assignedEditorId!.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order already taken')),
                      );
                      return;
                    } else {
                      // ✅ Safe to proceed — call your method here
                      transService.acceptOrder(
                        order.orderId,
                      ); // 👈 your custom method here
                    }
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget noUser = Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Elon Musk',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.video_call,
                      size: 18,
                      color: Colors.lightBlue,
                    ),
                    const SizedBox(width: 6),
                    const Text('Edits: 105'),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Color.fromARGB(255, 64, 225, 78),
                    ),
                    const SizedBox(width: 6),
                    const Text('Rating: 4.5'),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '🎬 Passion drives my edits, vision shapes my frame.\n'
                  'From rough cuts to cinematic brilliance.\n'
                  'I bring stories to life, one scene at a time.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            isThreeLine: true,
          ),

          // 🎥 Default sample videos
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                // Example default video thumbnails
                final sampleVideos = [
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                ];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SmallVideo(
                    url: sampleVideos[index],
                    fordownload: 6,
                    fromProfile: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 💬 Action Button
          GestureDetector(
            onTap: () {
              // For now, just print
              print('Select this Editor tapped');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Select this Editor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
