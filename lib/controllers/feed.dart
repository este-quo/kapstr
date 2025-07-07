import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/post.dart';
import 'package:kapstr/models/user.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class FeedController extends ChangeNotifier {
  bool _isLoading = false;
  bool isGuestView = false;
  List<Post> _posts = [];

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  set posts(List<Post> value) {
    _posts = value;
    notifyListeners();
  }

  CollectionReference get _postCollection => configuration.getCollectionPath('events').doc(Event.instance.id).collection('posts');

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      printOnDebug('Fetching posts');

      QuerySnapshot snapshot = await _postCollection.get();
      List<Post> fetchedPosts = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;

        User? user = await getUserDetails(postData['user_id']);

        if (user != null) {
          // Update post data with user details
          postData['name'] = user.name;
          postData['profile_picture_url'] = user.imageUrl;
        }

        Post post = Post.fromMap(doc.id, postData);
        fetchedPosts.add(post);
      }

      _posts = fetchedPosts;
      _posts.sort((a, b) => b.postedAt.compareTo(a.postedAt)); // sort from newest to oldest

      printOnDebug('Posts fetched');
    } catch (e) {
      printOnDebug('Une erreur est survenue: $e');
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }

  Future<User?> getUserDetails(String userId) async {
    // Fetch user details by userId
    var userDoc = await configuration.getCollectionPath('users').doc(userId).get();
    if (userDoc.exists) {
      return User.fromMap(userDoc.data()! as Map<String, dynamic>, userDoc.id);
    }
    return null;
  }

  Future<void> addPost(Map<String, dynamic> postMap, BuildContext context) async {
    try {
      // Attempt to add the post to Firebase
      DocumentReference docRef = await _postCollection.add(postMap);

      // Retrieve the Firestore-generated ID
      String firebaseId = docRef.id;

      postMap['name'] = context.read<UsersController>().user!.name;
      postMap['profile_picture_url'] = context.read<UsersController>().user!.imageUrl;

      // Create a new post using the Firestore-generated ID
      Post post = Post.fromMap(firebaseId, postMap);

      // Add the updated post to the local list
      _posts.add(post);

      // Sort the local list
      _posts.sort((a, b) => b.postedAt.compareTo(a.postedAt));

      notifyListeners();
    } catch (e) {
      // Handle errors here
      printOnDebug('Error addAAAAing post: $e');
    }
  }

  void removePost(String id) async {
    // Remove posts from local list
    _posts.removeWhere((element) => element.id == id);
    notifyListeners();

    // Remove posts from firebase
    await _postCollection.doc(id).delete();
  }

  Future<void> reportPost(String postId, String warn) async {
    try {
      // Update the post with the new warns list
      await _postCollection.doc(postId).update({
        'warns': FieldValue.arrayUnion([warn]),
      });
    } catch (e) {
      // Handle errors here
      printOnDebug('Error reporting post: $e');
    }
  }
}
