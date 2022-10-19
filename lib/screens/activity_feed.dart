import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';

class ActivityFeedPage extends StatefulWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage>
    with AutomaticKeepAliveClientMixin<ActivityFeedPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notfications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: buildActivityFeed(),
    );
  }

  buildActivityFeed() {
    return Container(
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('insta_a_feed')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("items")
              .orderBy("timestamp")
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: const CircularProgressIndicator());
            } else {
              if (snapshot.data == null) {
                List<ActivityFeedItem> nots =
                    ((snapshot.data as QuerySnapshot).docs)
                        .map((e) => ActivityFeedItem.fromDocument(e))
                        .toList();
                if (nots.isEmpty) {}
                return const Center(
                  child: Text(
                    "No notifications!",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              List<ActivityFeedItem> nots =
                  ((snapshot.data as QuerySnapshot).docs)
                      .map((e) => ActivityFeedItem.fromDocument(e))
                      .toList();
              return ListView(
                children: nots,
              );
            }
          }),
    );
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}

class ActivityFeedItem extends StatelessWidget {
  String? username;
  String? userId;
  String? type; // types include liked photo, follow user, comment on photo
  String? mediaUrl;
  String? mediaId;
  String? userProfileImg;
  String? commentData;

  ActivityFeedItem(
      {Key? key,
      this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.mediaId,
      this.userProfileImg,
      this.commentData})
      : super(key: key);

  factory ActivityFeedItem.fromDocument(DocumentSnapshot document) {
    var data = document.data() as Map;
    return ActivityFeedItem(
      username: data['username'],
      userId: data['userId'],
      type: data['type'],
      mediaUrl: data['mediaUrl'],
      mediaId: data['postId'],
      userProfileImg: data['userProfileImg'],
      commentData: data["commentData"],
    );
  }

  Widget mediaPreview = Container();
  String actionText = "";

  void configureItem(BuildContext context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () {},
        child: SizedBox(
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fill,
                alignment: FractionalOffset.topCenter,
                image: NetworkImage(mediaUrl ?? ""),
              )),
            ),
          ),
        ),
      );
    }

    if (type == "like") {
      actionText = " liked your post.";
    } else if (type == "follow") {
      actionText = " starting following you.";
    } else if (type == "comment") {
      actionText = " commented: $commentData";
    } else {
      actionText = "Error - invalid activityFeed type: $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 15.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: userId!,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                  userProfileImg != null && userProfileImg!.isEmpty
                      ? "https://bugreader.com/i/avatar.jpg"
                      : userProfileImg!),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  username ?? "Unknown",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {},
              ),
              Flexible(
                child: Container(
                  child: Text(
                    actionText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          child: Align(
            child: Padding(
              child: mediaPreview,
              padding: const EdgeInsets.all(15.0),
            ),
            alignment: AlignmentDirectional.bottomEnd,
          ),
        )
      ],
    );
  }
}

// openImage(BuildContext context, String imageId) {
//   print("the image id is $imageId");
//   Navigator.of(context)
//       .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
//     return Center(
//       child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Photo',
//                 style: TextStyle(
//                     color: Colors.black, fontWeight: FontWeight.bold)),
//             backgroundColor: Colors.white,
//           ),
//           body: ListView(
//             children: const <Widget>[
//               // Container(
//               //   child: ImagePostFromId(id: imageId),
//               // ),
//             ],
//           )),
//     );
//   }));
// }
