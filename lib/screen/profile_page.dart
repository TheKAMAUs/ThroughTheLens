import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:memoriesweb/data/auth_service.dart';

import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenVideoPage.dart';
import 'package:memoriesweb/screen/innerpgs/profileEditPage.dart';
import 'package:memoriesweb/screen/innerpgs/smallVideo.dart';
import 'package:memoriesweb/screen/innerpgs/userDetailPage.dart';
import 'package:memoriesweb/style/style.dart';
import 'package:memoriesweb/views/topToolRow.dart';
import 'package:tapped/tapped.dart';
import 'package:video_player/video_player.dart';

class ProfilePage extends StatefulWidget {
  final bool canPop;
  final bool isSelfPage;
  final Function? onPop;
  final Function? onSwitch;

  const ProfilePage({
    Key? key,
    this.canPop = false,
    this.onPop,
    required this.isSelfPage,
    this.onSwitch,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  late bool isUserAvailable;

  @override
  Widget build(BuildContext context) {
    bool isUserAvailable = globalUserDoc != null;
    print('User available: $isUserAvailable');
    print('client in profile: $globalUserDoc');

    Widget likeButton = Container(
      color: ColorPlate.back1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (isUserAvailable)
            Tapped(
              child: _UserRightButton(
                title: globalUserDoc!.editor ? "editor" : "client",
              ),
              onTap: () {
                if (globalUserDoc!.editor) {
                  context.push(Routes.profilEdit);
                }
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Guest", style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );

    Widget avatar = Container(
      height: 120 + MediaQuery.of(context).padding.top,
      padding: const EdgeInsets.only(left: 18),
      alignment: Alignment.bottomLeft,
      child: OverflowBox(
        alignment: Alignment.bottomLeft,
        minHeight: 20,
        maxHeight: 300,
        child: Container(
          height: 74,
          width: 74,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(44),
            color: Colors.orange,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: ClipOval(
            child: Image.network(
              (globalUserDoc?.profileImageUrl != null &&
                      globalUserDoc!.profileImageUrl.isNotEmpty)
                  ? globalUserDoc!.profileImageUrl
                  : "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif",
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/user_icon.png', fit: BoxFit.cover);
              },
            ),
          ),
        ),
      ),
    );

    Widget body = ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: <Widget>[
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[likeButton, avatar],
        ),
        Container(
          color: ColorPlate.back1,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 18),
                color: ColorPlate.back1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (globalUserDoc?.bio != null &&
                              globalUserDoc!.bio.isNotEmpty)
                          ? globalUserDoc!.bio
                          : "💫 I love Creating memoriesweb 🌠🤩",
                      style: StandardTextStyle.smallWithOpacity.apply(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const <Widget>[
                        _UserTag(tag: 'Humorous'),
                        _UserTag(tag: 'Witty'),
                        _UserTag(tag: 'Dull'),
                        _UserTag(tag: 'Leo'),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                color: ColorPlate.back1,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                    TextGroup('356', 'Following'),
                    TextGroup('1.45M', 'Followers'),
                    TextGroup('14.23M', 'Likes'),
                  ],
                ),
              ),
              Container(
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
              _UserVideoTable(),
            ],
          ),
        ),
      ],
    );

    return isUserAvailable
        ? Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: <Color>[Colors.orange, Colors.red],
            ),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 400),
                height: double.infinity,
                width: double.infinity,
                color: ColorPlate.back1,
              ),
              body,
              Container(
                margin: const EdgeInsets.only(top: 20),
                height: 62,
                child: TopToolRow(
                  canPop: widget.canPop,
                  onPop: widget.onPop,
                  right: Tapped(
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.36),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.more_horiz, size: 24),
                    ),
                    onTap: () {
                      context.push(Routes.userDetailPage);
                    },
                  ),
                ),
              ),
            ],
          ),
        )
        : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'You are not logged in',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    Routes.loginPageRIV,
                  ); // 👈 navigate to your login screen
                },
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}

class _UserRightButton extends StatelessWidget {
  const _UserRightButton({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      margin: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(title, style: TextStyle(color: ColorPlate.orange)),
      decoration: BoxDecoration(
        border: Border.all(color: ColorPlate.orange),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _UserTag extends StatelessWidget {
  final String? tag;

  const _UserTag({Key? key, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(tag ?? '标签', style: StandardTextStyle.smallWithOpacity),
    );
  }
}

class _UserVideoTable extends StatefulWidget {
  @override
  State<_UserVideoTable> createState() => _UserVideoTableState();
}

class _UserVideoTableState extends State<_UserVideoTable>
    with TickerProviderStateMixin {
  final authService = AuthService();
  final OrderServiceRepo order = OrderServiceRepo();

  late TabController _tabController;

  final tabs = ['edited', 'orders', 'drafts'];

  List<String>? videoUrls;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Triggers rebuild on tab change
      }
    });

    loadVideoUrls();
  }

  Future<void> loadVideoUrls() async {
    print('Run');
    if (globalUserDoc!.editor) {
      setState(() {
        videoUrls = globalUserDoc?.sampleVideos;
      });
      print('${videoUrls}');
    } else {
      final urls =
          await order
              .fetchAllVideoUrlsFromOrders(); // make sure this returns List<String>
      setState(() {
        videoUrls = urls;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: tabs.map((label) => Tab(text: label)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
        ),
        SizedBox(height: 8),
        // This replaces TabBarView to allow flexible height
        IndexedStack(
          index: _tabController.index,
          children: [
            _GridOfVideos(
              label: 'edited',
              videoUrls:
                  globalUserDoc!.editor
                      ? videoUrls
                      : globalUserDoc?.editedVideos,
              emptyMessage: 'no edited videos',
              fordownload: 1,
            ),
            _GridOfVideos(
              label: 'orders',
              videoUrls: globalUserDoc!.editor ? [] : videoUrls,
              emptyMessage: 'no to be edited videos',
              fordownload: 2,
            ),
            _GridOfVideos(
              label: 'drafts',
              videoUrls: [],
              emptyMessage: 'empty drafts',
              fordownload: 3,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _GridOfVideos extends StatefulWidget {
  final String? label;
  final List<String>? videoUrls;
  final String? emptyMessage;
  final int fordownload;

  const _GridOfVideos({
    this.label,
    this.videoUrls,
    this.emptyMessage,
    required this.fordownload,
    Key? key,
  }) : super(key: key);

  @override
  State<_GridOfVideos> createState() => _GridOfVideosState();
}

class _GridOfVideosState extends State<_GridOfVideos> {
  @override
  Widget build(BuildContext context) {
    if (widget.videoUrls == null || widget.videoUrls!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            widget.emptyMessage ?? 'No videos available.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.videoUrls!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 0,
        crossAxisSpacing: 1,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder:
          (context, index) => SmallVideo(
            url: widget.videoUrls![index],
            fordownload: widget.fordownload,
            fromProfile: true,
          ),
    );
  }
}

class _SmallVideo extends StatefulWidget {
  final String url;
  final int fordownload; // 👈 added int parameter
  const _SmallVideo({Key? key, required this.url, required this.fordownload})
    : super(key: key);

  @override
  State<_SmallVideo> createState() => _SmallVideoState();
}

class _SmallVideoState extends State<_SmallVideo> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the first frame
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.black,
              ),
              child:
                  controller.value.isInitialized
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: VideoPlayer(controller),
                      )
                      : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FullScreenVideoPage(
                            url: widget.url,
                            fordownload: widget.fordownload,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointSelectTextButton extends StatelessWidget {
  final bool isSelect;
  final String title;
  final Function? onTap;

  const _PointSelectTextButton(
    this.isSelect,
    this.title, {
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isSelect
              ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: ColorPlate.orange,
                  borderRadius: BorderRadius.circular(3),
                ),
              )
              : Container(),
          Container(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              title,
              style:
                  isSelect
                      ? StandardTextStyle.small
                      : StandardTextStyle.smallWithOpacity,
            ),
          ),
        ],
      ),
    );
  }
}

// class _IconTextButton extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Function onTap;
//   const _IconTextButton(
//     this.icon,
//     this.title, {
//     Key key,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Icon(icon, color: ColorPlate.yellow),
//           Container(
//             padding: EdgeInsets.only(left: 2),
//             child: Text(
//               title,
//               style: TextStyle(color: ColorPlate.yellow),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

class TextGroup extends StatelessWidget {
  final String title, tag;
  final Color? color;

  const TextGroup(this.title, this.tag, {Key? key, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(title, style: StandardTextStyle.big.apply(color: color)),
          Container(width: 4),
          Text(
            tag,
            style: StandardTextStyle.smallWithOpacity.apply(
              color: color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
