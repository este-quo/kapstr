import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/feed/post.dart';
import 'package:kapstr/views/global/feed/save_the_date.dart';
import 'package:kapstr/views/global/feed/save_the_date_page.dart';
import 'package:kapstr/views/global/feed/send_post.dart';
import 'package:kapstr/views/global/feed/send_post_quick.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  late Module module;
  late DateTime moduleDate;
  @override
  void initState() {
    super.initState();
    module = Event.instance.modules.firstWhere((module) => module.type == 'wedding');
    moduleDate = module.date!;

    loadFeed();
  }

  Future<void> loadFeed() async {
    await context.read<FeedController>().fetchPosts();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kLighterGrey,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: kWhite,
          elevation: 0,
          surfaceTintColor: kWhite,
          leadingWidth: 0,
          leading: const SizedBox(),
          title: const Text('Feed', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  triggerShortVibration();
                  if (context.read<UsersController>().user != null) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.3),
                      useSafeArea: true,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          initialChildSize: 1,
                          minChildSize: 0.8,
                          maxChildSize: 1,
                          expand: false,
                          builder: (context, scrollController) {
                            return SendPost(scrollController: scrollController);
                          },
                        );
                      },
                    );
                  } else {
                    context.read<AuthenticationController>().setPendingConnection(true);
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.3),
                      useSafeArea: true,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          initialChildSize: 1,
                          minChildSize: 0.8,
                          maxChildSize: 1,
                          expand: false,
                          builder: (context, scrollController) {
                            return const LogIn();
                          },
                        );
                      },
                    );
                  }
                },
                child: const CircleAvatar(backgroundColor: kWhite, radius: 18, child: Icon(Icons.add, color: kBlack, size: 26)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SaveTheDatePage(module: module, moduleDate: moduleDate)));
                },
                child: const CircleAvatar(backgroundColor: kWhite, radius: 18, child: Icon(Icons.event_rounded, color: kBlack, size: 26)),
              ),
            ),
          ],
        ),

        // Body
        body: SafeArea(
          child: Column(
            children: [
              // Send a post shortcut
              const SendPostQuick(),
              Expanded(
                child: RefreshIndicator(
                  strokeWidth: 2,
                  color: kBlack,
                  onRefresh: () async {
                    await loadFeed();
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Save the date
                        const SaveTheDate(),

                        context.watch<FeedController>().posts.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: SizedBox(width: MediaQuery.of(context).size.width - 40, child: const Text('Aucun message pour le moment, soyez le premier à publier !', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400))),
                            )
                            : const SizedBox(),

                        // Posts
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: context.watch<FeedController>().posts.length,
                          itemBuilder: (context, index) {
                            return Post(
                              id: context.watch<FeedController>().posts[index].id,
                              name: context.watch<FeedController>().posts[index].name,
                              content: context.watch<FeedController>().posts[index].content,
                              profilePictureUrl: context.watch<FeedController>().posts[index].profilePictureUrl,
                              imagesUrl: context.watch<FeedController>().posts[index].imagesUrl,
                              postedAt: context.watch<FeedController>().posts[index].postedAt,
                              userId: context.watch<FeedController>().posts[index].userId,
                            );
                          },
                        ),

                        const SizedBox(height: 96),
                      ],
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
