import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone_flutter/models/post.dart';
import 'package:instagram_clone_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage, String? location) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: Timestamp.now(),
        postUrl: photoUrl,
        profImage: profImage,
        location: location,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(Post post, String uid, String username,
      String photoUrl, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(post.postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
        FirebaseFirestore.instance
            .collection("insta_a_feed")
            .doc(post.uid)
            .collection("items")
            .doc(post.postId)
            .delete();
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(post.postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
        FirebaseFirestore.instance
            .collection("insta_a_feed")
            .doc(post.uid)
            .collection("items")
            .doc(post.postId)
            .set({
          "username": username,
          "userId": uid,
          "type": "like",
          "userProfileImg": photoUrl,
          "mediaUrl": post.postUrl,
          "timestamp": DateTime.now(),
          "postId": post.postId,
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String ownerId, String postId, String postMediaUrl,
      String text, String uid, String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });

        //adds to postOwner's activity feed
        _firestore
            .collection("insta_a_feed")
            .doc(ownerId)
            .collection("items")
            .add({
          "username": name,
          "userId": uid,
          "type": "comment",
          "userProfileImg": profilePic,
          "commentData": text,
          "timestamp": Timestamp.now(),
          "postId": postId,
          "mediaUrl": postMediaUrl,
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(
      String uid, String followId, String username, String pic) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });

        FirebaseFirestore.instance
            .collection("insta_a_feed")
            .doc(followId)
            .collection("items")
            .doc(uid)
            .delete();
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        //updates activity feed
        FirebaseFirestore.instance
            .collection("insta_a_feed")
            .doc(followId)
            .collection("items")
            .doc(uid)
            .set({
          "ownerId": followId,
          "username": username,
          "userId": uid,
          "type": "follow",
          "userProfileImg": pic,
          "timestamp": DateTime.now()
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
