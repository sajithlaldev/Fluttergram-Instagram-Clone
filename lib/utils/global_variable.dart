import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/activity_feed.dart';
import 'package:instagram_clone_flutter/screens/add_post_screen.dart';
import 'package:instagram_clone_flutter/screens/feed_screen.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const ActivityFeedPage(),
  Builder(builder: (context) {
    return ProfileScreen(
      uid: FirebaseAuth.instance.currentUser!.uid,
    );
  }),
];
