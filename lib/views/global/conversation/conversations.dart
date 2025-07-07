import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/conversation/chat.dart';
import 'package:kapstr/views/global/conversation/participants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  Stream<DocumentSnapshot> _getUserDetailsStream(String userId) {
    return configuration.getCollectionPath('users').doc(userId).snapshots();
  }

  Stream<DocumentSnapshot> _getLastMessageStream(String chatId) {
    return configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).limit(1).snapshots().map((snapshot) => snapshot.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations', style: TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w500)),
        centerTitle: true,
        leadingWidth: 75,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParticipantsPage()));
              },
              child: const Text('Participants', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').where('participants', arrayContains: context.read<UsersController>().user!.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParticipantsPage()));
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Vous n\'avez pas de conversation en cours. Voir la liste des ',
                    style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                    children: [TextSpan(text: 'participants.', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.w400))],
                  ),
                ),
              ),
            );
          }

          var chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              String otherUserId = chat['participants'][0] == context.read<UsersController>().user!.id ? chat['participants'][1] : chat['participants'][0];

              return StreamBuilder<DocumentSnapshot>(
                stream: _getUserDetailsStream(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('Chargement des détails de l\'utilisateur...'));
                  }

                  var userDetails = userSnapshot.data!.data() as Map<String, dynamic>;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: _getLastMessageStream(chat.id),
                    builder: (context, messageSnapshot) {
                      if (!messageSnapshot.hasData) {
                        return const ListTile(title: Text('Chargement du dernier message...'));
                      }

                      var lastMessage = messageSnapshot.data!;

                      String subtitleText;
                      if (lastMessage['text'] != null && lastMessage['text'].isNotEmpty) {
                        subtitleText = lastMessage['text'];
                      } else if (lastMessage['image_url'] != null && lastMessage['image_url'].isNotEmpty) {
                        subtitleText = 'Photo';
                      } else if (lastMessage['audio_url'] != null && lastMessage['audio_url'].isNotEmpty) {
                        subtitleText = 'Audio';
                      } else {
                        subtitleText = '';
                      }

                      bool hasUnreadMessages = lastMessage['status'] == 'sent' && lastMessage['sender'] != context.read<UsersController>().user!.id;

                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(userDetails['image_url']), backgroundColor: kLightGrey, child: userDetails['image_url'] == "" ? const Icon(Icons.person, color: kWhite, size: 24) : null),
                        title: Text(userDetails['name'], style: TextStyle(color: kBlack, fontSize: 16, fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.w500)),
                        subtitle: Text(subtitleText, overflow: TextOverflow.ellipsis, style: TextStyle(color: hasUnreadMessages ? kPrimary : kGrey, fontSize: 14, fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.w400)),
                        trailing: hasUnreadMessages ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)) : null,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(userId: context.read<UsersController>().user!.id, otherUserId: otherUserId)));
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
