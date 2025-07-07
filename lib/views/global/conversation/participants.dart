import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/conversation/chat.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class ParticipantsPage extends StatefulWidget {
  const ParticipantsPage({super.key});

  @override
  _ParticipantsPageState createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _getGuestsWithUserInfo() async {
    // Fetch guests
    var guestsSnapshot = await FirebaseFirestore.instance.collection('events').doc(Event.instance.id).collection('guests').get();

    List<Map<String, dynamic>> guestsWithDetails = [];

    // Fetch detailed info for each guest
    for (var guest in guestsSnapshot.docs) {
      var userId = guest['user_id'];
      if (userId != null && userId.isNotEmpty) {
        var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          var userData = userSnapshot.data();
          if (userData != null) {
            guestsWithDetails.add({'user_id': userId, 'name': userData['name'], 'image_url': userData['image_url']});
          }
        }
      }
    }

    return guestsWithDetails;
  }

  Future<List<Map<String, dynamic>>> _getOrganizersWithUserInfo() async {
    // Fetch organizers
    var organizersSnapshot = await FirebaseFirestore.instance.collection('organizers').where('event_id', isEqualTo: Event.instance.id).get();

    List<Map<String, dynamic>> organizersWithDetails = [];

    // Fetch detailed info for each organizer
    for (var organizer in organizersSnapshot.docs) {
      var userId = organizer['user_id'];
      if (userId != null && userId.isNotEmpty) {
        var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          var userData = userSnapshot.data();
          if (userData != null) {
            organizersWithDetails.add({'user_id': userId, 'name': userData['name'], 'image_url': userData['image_url']});
          }
        }
      }
    }

    return organizersWithDetails;
  }

  Future<List<Map<String, dynamic>>> _getUniqueParticipants() async {
    // Get current user's ID to exclude them from the list
    var currentUserId = context.read<UsersController>().user!.id;

    // Fetch both guests and organizers
    var guests = await _getGuestsWithUserInfo();
    var organizers = await _getOrganizersWithUserInfo();

    // Create a combined list and remove duplicates based on user_id
    Map<String, Map<String, dynamic>> uniqueUsers = {};

    // Add guests to the unique users map
    for (var guest in guests) {
      if (guest['user_id'] != currentUserId) {
        // Exclude the current user
        uniqueUsers[guest['user_id']] = guest;
      }
    }

    // Add organizers, ensuring no duplicates by user_id
    for (var organizer in organizers) {
      if (organizer['user_id'] != currentUserId) {
        // Exclude the current user
        uniqueUsers[organizer['user_id']] = organizer;
      }
    }

    // Return the list of unique users
    return uniqueUsers.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants', style: TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w500)),
        centerTitle: true,
        leadingWidth: 75,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 36,
              child: TextField(
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(color: kDarkGrey, fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: 'Chercher un participant',
                  hintStyle: const TextStyle(color: kDarkGrey, fontSize: 14),
                  suffixIcon: const Icon(Icons.search, color: kDarkGrey, size: 20),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kLightGrey)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kDarkGrey)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getUniqueParticipants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur lors du chargement des participants."));
                }

                var participantsAndOrganizers = snapshot.data ?? [];

                // Filter the list based on search query
                var filteredList =
                    participantsAndOrganizers.where((user) {
                      var name = user['name'].toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                // Display a message if no participants or organizers found
                if (filteredList.isEmpty) {
                  return const Center(child: Text(textAlign: TextAlign.center, "Il n'y a pas encore de participant pour cet événement.", style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)));
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    var user = filteredList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(radius: 24, backgroundImage: NetworkImage(user['image_url']), backgroundColor: kLightGrey, child: user['image_url'] == "" ? const Icon(Icons.person, color: kWhite, size: 20) : null),
                        title: Text(user['name'], style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(userId: context.read<UsersController>().user!.id, otherUserId: user['user_id'])));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
