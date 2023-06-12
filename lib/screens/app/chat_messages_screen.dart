import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:encription_caht/firebase/fb_firestore_messages_controller.dart';
import 'package:encription_caht/models/chat.dart';
import 'package:encription_caht/models/chat_message.dart';

import '../../encrypt_aes.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChatMessagesScreen extends StatefulWidget {
  const ChatMessagesScreen({Key? key, required this.chat}) : super(key: key);

  final Chat chat;

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  late TextEditingController _messageTextController;
  late ScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messageTextController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                reverse: true,
                controller: _scrollController,
                child: StreamBuilder<QuerySnapshot<ChatMessage>>(
                  stream: FbFireStoreMessagesController()
                      .fetchChatMessages(widget.chat.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData &&
                        snapshot.data!.docs.isNotEmpty) {
                      return Column(
                        children: snapshot.data!.docs.reversed
                            .map(
                              (chatMessageDocument) => Align(
                                alignment: chatMessageDocument.data().sentByMe
                                    ? AlignmentDirectional.centerEnd
                                    : AlignmentDirectional.centerStart,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: chatMessageDocument.data().sentByMe
                                        ? Colors.blue.shade100
                                        : Colors.pink.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    EncryptData().decryptAES(
                                      EncryptData().decryptSalsa(
                                        chatMessageDocument.data().message,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'NO MESSAGES',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.black45,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                const BoxShadow(
                  offset: Offset(0, 0),
                  color: Colors.black45,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageTextController,
                    keyboardType: TextInputType.text,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter message here..',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black26,
                  ),
                ),
                IconButton(
                  onPressed: () => _performSend(),
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _performSend() {
    if (_checkData()) {
      _send();
    }
  }

  bool _checkData() {
    return _messageTextController.text.isNotEmpty;
  }

  void _send() async {
    //TODO: call send message from firebase store controller
    bool sent = await FbFireStoreMessagesController().sendMessage(message);
    if (sent) {
      clear();
      print('Message has been sent successfully');
    }
  }

  ChatMessage get message {
    ChatMessage message = ChatMessage();
    message.chatId = widget.chat.id;
    message.message = EncryptData()
        .encryptSalsa(EncryptData().encryptAES(_messageTextController.text));
    message.type = MessageType.text.name;
    message.senderId = widget.chat.getId(me: true);
    message.receiverId = widget.chat.getId(me: false);
    message.sentAt = DateTime.now().microsecondsSinceEpoch.toString();
    return message;
  }

  void clear() {
    _messageTextController.clear();
  }
}
