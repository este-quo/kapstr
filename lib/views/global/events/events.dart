import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/components/dialogs/pending_auth.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/format_date.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/user.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/joining/enter_code.dart';
import 'package:kapstr/views/global/profile/modify_profile.dart';
import 'package:kapstr/views/global/tuto/tutorial.dart';

import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/views/global/events/card.dart';
import 'package:kapstr/views/global/events/card_skeleton.dart';
import 'package:kapstr/views/global/events/create/type/event_type.dart';
import 'package:kapstr/views/global/events/joined_card.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key, this.isPendingVerif});

  final bool? isPendingVerif;

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  bool isLoading = false;
  bool _isRedirected = false;

  @override
  void initState() {
    super.initState();
    fetchEvents();

    if (context.read<AuthenticationController>().isPendingConnection) {
      Future.delayed(Duration.zero, () {
        showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))), builder: (context) => const PendingAuthentificationDialog());
      });
    }
  }

  void _navigateTo(Widget page) {
    setState(() {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  void _handleOnboarding(User user) {
    if (!user.onboardingComplete && !_isRedirected) {
      _isRedirected = true; // Mark as redirected
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Tutorial()));
    }
  }

  void fetchEvents() async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
  }

  DateTime parseEventDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').parse(dateString);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime.now();
    }
  }

  Future<List<EventData>> fetchAndSortEvents() async {
    var user = context.watch<UsersController>().user;
    var userEvents = context.watch<UsersController>().user!.createdEvents;

    if (userEvents.isNotEmpty) {
      List<EventData> events = [];

      for (var userEvent in userEvents) {
        var organisersData = await context.read<EventsController>().getEventOrganiser(userEvent);

        print(organisersData.data());

        var eventData = await context.read<EventsController>().getEvent(organisersData["event_id"]);

        var organizersAdded = eventData["organizer_added"] as List;
        var organizersToAdd = eventData["organizer_to_add"] as List;

        if (organizersToAdd.contains(user!.phone)) {
          if (!organizersAdded.contains(user!.phone)) {
            context.read<EventsController>().createdToJoinedEvent(organisersData["event_id"]);
          } else {
            if (eventData["plan_end_at"] == null || parseEventDate(eventData["plan_end_at"]).isAfter(DateTime.now())) {
              events.add(EventData(eventId: organisersData["event_id"], eventDate: eventData["date"], eventData: eventData));
            }
          }
        } else {
          // Organisateur principal
          if (eventData["plan_end_at"] == null || parseEventDate(eventData["plan_end_at"]).isAfter(DateTime.now())) {
            events.add(EventData(eventId: organisersData["event_id"], eventDate: eventData["date"], eventData: eventData));
          }
        }
      }

      DateTime now = DateTime.now();

      // Separate future and past events
      List<EventData> futureEvents = events.where((event) => parseEventDate(event.eventDate).isAfter(now)).toList();
      List<EventData> pastEvents = events.where((event) => parseEventDate(event.eventDate).isBefore(now)).toList();

      // Sort future events by date (closest first)
      futureEvents.sort((a, b) => parseEventDate(a.eventDate).difference(now).compareTo(parseEventDate(b.eventDate).difference(now)));

      // Sort past events by date (most recent first)
      pastEvents.sort((a, b) => parseEventDate(b.eventDate).difference(parseEventDate(a.eventDate)).compareTo(Duration.zero));

      // Combine the lists, with future events first
      events = [...futureEvents, ...pastEvents];

      // Print sorted events
      for (var event in events) {
        print('Event: ${event.eventId}, Date: ${event.eventDate}');
      }

      return events;
    } else {
      return [];
    }
  }

  Future<List<EventData>> fetchAndSortJoinedEvents() async {
    var userEvents = context.watch<UsersController>().user!.joinedEvents;

    var user = context.watch<UsersController>().user;
    if (userEvents.isNotEmpty) {
      List<EventData> events = [];

      for (var userEvent in userEvents) {
        var organisersData = await context.read<EventsController>().getJoinedEventOrganiser(userEvent);
        var eventData = await context.read<EventsController>().getEvent(organisersData["event_id"]);

        // Check if the event's planEndAt date has not passed or is null
        if (eventData["plan_end_at"] == null || parseEventDate(eventData["plan_end_at"]).isAfter(DateTime.now())) {
          events.add(EventData(eventId: organisersData["event_id"], eventDate: eventData["date"], eventData: eventData));
        }
      }

      var createdEvents = context.read<UsersController>().user!.createdEvents; //CAUTION: Solution temporaire pour basculer un event qui viendrait juste d'etre repassé dans cette liste
      print("Events qui viennent d'être passés");
      for (var userEvent in createdEvents) {
        var organisersData = await context.read<EventsController>().getEventOrganiser(userEvent);
        var eventData = await context.read<EventsController>().getEvent(organisersData["event_id"]);

        var organizersAdded = eventData["organizer_added"] as List;
        var organizersToAdd = eventData["organizer_to_add"] as List;

        if (organizersToAdd.contains(user!.phone)) {
          if (organizersAdded.contains(user!.phone)) {
            context.read<EventsController>().joinedToCreatedEvent(organisersData["event_id"]);
          } else {
            if (eventData["plan_end_at"] == null || parseEventDate(eventData["plan_end_at"]).isAfter(DateTime.now())) {
              events.add(EventData(eventId: organisersData["event_id"], eventDate: eventData["date"], eventData: eventData));
            }
          }
        }
      }

      DateTime now = DateTime.now();

      // Separate future and past events
      List<EventData> futureEvents = events.where((event) => parseEventDate(event.eventDate).isAfter(now)).toList();
      List<EventData> pastEvents = events.where((event) => parseEventDate(event.eventDate).isBefore(now)).toList();

      // Sort future events by date (closest first)
      futureEvents.sort((a, b) => parseEventDate(a.eventDate).difference(now).compareTo(parseEventDate(b.eventDate).difference(now)));

      // Sort past events by date (most recent first)
      pastEvents.sort((a, b) => parseEventDate(b.eventDate).difference(parseEventDate(a.eventDate)).compareTo(Duration.zero));

      // Combine the lists, with future events first
      events = [...futureEvents, ...pastEvents];

      // Print sorted events
      for (var event in events) {
        print('Event: ${event.eventId}, Date: ${event.eventDate}');
      }

      return events;
    } else {
      return [];
    }
  }

  void callBack() async {
    printOnDebug('Callback called');
    setState(() {
      fetchEvents();
    });
    printOnDebug('Callback done');
  }

  @override
  Widget build(BuildContext context) {
    var userEvents = context.watch<UsersController>().user!.createdEvents;
    context.read<EventsController>().disableGuestPreview();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: kWhite,
          backgroundColor: kWhite,
          elevation: 0,
          toolbarHeight: 64,
          centerTitle: false,
          leading: const SizedBox(),
          leadingWidth: 0,
          title: const Text('Événements', style: TextStyle(color: kBlack, fontSize: 24, fontFamily: "Inter", fontWeight: FontWeight.w600)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModifyProfile()));
                },
                child:
                    context.watch<UsersController>().user!.imageUrl == ""
                        ? const CircleAvatar(radius: 20, backgroundColor: kLightGrey, child: Icon(Icons.person, color: kWhite))
                        : CircleAvatar(radius: 20, backgroundColor: kLightGrey, backgroundImage: CachedNetworkImageProvider(context.watch<UsersController>().user!.imageUrl)),
              ),
            ),
          ],
          bottom:
              userEvents.isNotEmpty
                  ? const TabBar(dividerColor: kWhite, indicatorSize: TabBarIndicatorSize.label, indicatorColor: kYellow, labelColor: kBlack, unselectedLabelColor: Colors.grey, labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400), tabs: [Tab(text: 'Créés'), Tab(text: 'Rejoins')])
                  : null,
        ),
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        floatingActionButton: Container(
          decoration: const BoxDecoration(color: kWhite, border: Border(top: BorderSide(color: Color.fromARGB(30, 0, 0, 0), width: 1))),
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MainButton(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                onPressed: () {
                  triggerShortVibration();

                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const EventType(), // Assurez-vous d'importer cette page
                        ),
                      )
                      .then((value) => callBack());
                },
                child: const Text('Créer', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)),
              ),
              MainButton(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                onPressed: () {
                  triggerShortVibration();

                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const EnterGuestCode(), // Assurez-vous d'importer cette page
                        ),
                      )
                      .then((value) => callBack());
                },
                backgroundColor: kPrimary,
                child: const Text('Rejoindre', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child:
              isLoading
                  ? const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))
                  : userEvents.isNotEmpty
                  ? TabBarView(children: [_buildCreatedEventsTab(), _buildJoinedEventsTab()])
                  : _buildJoinedEventsTab(),
        ),
      ),
    );
  }

  Widget _buildCreatedEventsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 16), _buildCards(), const SizedBox(height: 92)]))),
    );
  }

  Widget _buildJoinedEventsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 16), _buildJoinedEventCards(), const SizedBox(height: 92)]))),
    );
  }

  FutureBuilder<List<EventData>> _buildCards() {
    return FutureBuilder<List<EventData>>(
      future: fetchAndSortEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var events = snapshot.data!;
          if (events.isNotEmpty) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return EventCard(eventId: event.eventId, eventCode: event.eventData["code"], eventDate: event.eventDate == kDefaultDate ? "Date non définie" : formatDate(event.eventDate), eventData: event.eventData, callBack: callBack);
              },
            );
          } else {
            return Container(height: MediaQuery.of(context).size.height * 0.5, child: const Center(child: Text('Vous n\'avez pas d\'évènements', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400))));
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching events'));
        } else {
          return CardSkeleton(count: context.watch<UsersController>().user!.createdEvents.length);
        }
      },
    );
  }

  FutureBuilder<List<EventData>> _buildJoinedEventCards() {
    return FutureBuilder<List<EventData>>(
      future: fetchAndSortJoinedEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var events = snapshot.data!;
          if (events.isNotEmpty) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                // Here, build your card with the sorted event data
                return JoinedEventCard(eventCode: event.eventData["code"], eventDate: event.eventDate == kDefaultDate ? "Date non définie" : formatDate(event.eventDate), eventData: event.eventData, eventId: event.eventId, callBack: callBack);
              },
            );
          } else {
            return Container(height: MediaQuery.of(context).size.height * 0.5, child: const Center(child: Text('Vous n\'avez pas d\'évènements', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400))));
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching events'));
        } else {
          return CardSkeleton(count: context.watch<UsersController>().user!.joinedEvents.length);
        }
      },
    );
  }

  void _showCreateOrJoinDialog() {
    triggerShortVibration();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
          title: const Text('Que voulez-vous faire?', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w400)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IcButton(
                  onPressed: () {
                    triggerShortVibration();

                    Navigator.of(context).pop(); // Ferme le popup
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const EventType(), // Assurez-vous d'importer cette page
                          ),
                        )
                        .then((value) => callBack());
                  },
                  backgroundColor: kYellow,
                  borderColor: const Color.fromARGB(30, 0, 0, 0),
                  borderWidth: 1,
                  radius: 8.0,
                  child: const Text('Créer mon événement', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)),
                ),
                const SizedBox(height: 8),
                const Text('ou', style: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400)),
                const SizedBox(height: 8),
                IcButton(
                  onPressed: () {
                    triggerShortVibration();

                    Navigator.of(context).pop(); // Ferme le popup
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const EnterGuestCode(), // Assurez-vous d'importer cette page
                          ),
                        )
                        .then((value) => callBack());
                  },
                  borderColor: const Color.fromARGB(30, 0, 0, 0),
                  borderWidth: 1,
                  backgroundColor: Colors.white,
                  radius: 8,
                  child: const Text('Rejoindre un événement', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EventData {
  final String eventId;
  final String eventDate;
  final Map<String, dynamic> eventData;

  EventData({required this.eventId, required this.eventDate, required this.eventData});

  // Factory method to create EventData from a Map, if needed
  factory EventData.fromMap(Map<String, dynamic> map) {
    return EventData(eventId: map['eventId'], eventDate: map['eventDate'], eventData: map['eventData']);
  }

  // Method to convert EventData to a Map, useful for serialization
  Map<String, dynamic> toMap() {
    return {'eventId': eventId, 'eventDate': eventDate, 'eventData': eventData};
  }
}
