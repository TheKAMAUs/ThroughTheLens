import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/data/transactions_service_repo.dart';
import 'package:memoriesweb/model/clientmodel.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenImagePage.dart';
import 'package:memoriesweb/screen/innerpgs/smallVideo.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final OrderServiceRepo order = OrderServiceRepo();
  final authService = AuthService();
  final transService = TransServiceRepo();
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => FullScreenImagePage(
                                                  imageUrl: img,
                                                  fordownload: 0,
                                                ),
                                          ),
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
                                        fordownload: 5,
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

    if (!isUserAuthenticated) {
      return Scaffold(body: noUser);
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
                  '🎬 Passionate video editor turning raw clips into cinematic stories!',
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
                  child: SmallVideo(url: sampleVideos[index], fordownload: 6),
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
