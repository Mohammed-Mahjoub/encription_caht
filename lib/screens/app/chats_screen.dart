import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encription_caht/screens/app/chat_messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:encription_caht/firebase/fb_auth_controller.dart';
import 'package:encription_caht/firebase/fb_firestore_chats_controller.dart';
import 'package:encription_caht/models/chat.dart';

import '../../firebase/fb_firestore_users_controller.dart';
import '../../models/chat_user.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
        actions: [
          IconButton(
            onPressed: () async {
              await FbAuthController().signOut();
              Navigator.pushReplacementNamed(context, "/login_screen");
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<ChatUser>>(
          stream: FbFireStoreUsersController().readUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(snapshot.data!.docs[index].data().name),
                    subtitle: Text(snapshot.data!.docs[index].data().name),
                    onTap: () async {
                      Chat chat = await FbFireStoreChatsController()
                          .manageChat(snapshot.data!.docs[index].id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatMessagesScreen(chat: chat),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return Center(child: Text("No Data"));
            }
          }),
    );
  }
}
