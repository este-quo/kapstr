import 'package:flutter/material.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/models/notification.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/notifications/tile.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<MyNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    switch (context.read<NotificationController>().target) {
      case 'guest':
        await context.read<NotificationController>().fetchGuestNotifications();
        notifications = context.read<NotificationController>().guestNotifications;
        break;
      case 'organizer':
        await context.read<NotificationController>().fetchOrganizerNotifications();
        notifications = context.read<NotificationController>().organizerNotifications;
        break;
      default:
        notifications = [];
    }
    if (mounted) setState(() {});

    // 3s delay to add the user id to the seenBy list
    await Future.delayed(const Duration(seconds: 3));
    await context.read<NotificationController>().addUserIdToSeenBy();
  }

  @override
  Widget build(BuildContext context) {
    bool isGuestView = context.read<NotificationController>().target == 'guest';

    // sort notifications by date
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: Text('Notifications', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            RefreshIndicator(
              strokeWidth: 2,
              color: kBlack,
              onRefresh: () async {
                await loadNotifications();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications
                  notifications.isEmpty
                      ? Center(child: Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - 100), child: const Text('Aucune notification pour le moment', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: kGrey, fontWeight: FontWeight.w400))))
                      : SizedBox(
                        height: MediaQuery.of(context).size.height - 114,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Divider(color: kBlack.withOpacity(0.1), height: 1, thickness: 1),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  return NotificationTile(id: notifications[index].id, title: notifications[index].title, body: notifications[index].body, image: notifications[index].image, seen: notifications[index].seenBy.contains(isGuestView ? AppGuest.instance.id : AppOrganizer.instance.id));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
