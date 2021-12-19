// ignore_for_file: prefer_is_empty, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/data/message.dart';
import 'package:practice/data/message_dao.dart';
import 'package:practice/data/user_dao.dart';
import 'package:provider/provider.dart';

import 'message_widget.dart';

class RayChat extends StatefulWidget {
  const RayChat({Key? key}) : super(key: key);

  @override
  State<RayChat> createState() => _RayChatState();
}

class _RayChatState extends State<RayChat> {
  FocusNode myFocusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? email;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
    final messageDao = Provider.of<MessageDao>(context, listen: false);
    final userDao = Provider.of<UserDao>(context, listen: false);
    email = userDao.email();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RayChat',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                userDao.logout();
              },
              icon: const Icon(Icons.logout))
        ],
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ignore: todo
            // TODO: Add Message DAO to _getMessageList
            _getMessageList(messageDao),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                      focusNode: myFocusNode,
                      controller: _messageController,
                      decoration: InputDecoration(
                          labelText: 'Entre new message',
                          labelStyle: TextStyle(
                              color: myFocusNode.hasFocus
                                  ? Colors.green
                                  : Colors.black))),
                ),
                IconButton(
                    onPressed: () {
                      _sendMessage(messageDao);
                    },
                    icon: Icon(_canSendMessage()
                        ? CupertinoIcons.arrow_right_circle_fill
                        : CupertinoIcons.arrow_right_circle))
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: todo
  // TODO: Replace _sendMessage
  void _sendMessage(MessageDao messageDao) {
    if (_canSendMessage()) {
      final message = Message(
        text: _messageController.text,
        date: DateTime.now(),
        email: email,
      );
      messageDao.saveMessage(message);
      _messageController.clear();
      setState(() {});
    }
  }

  // ignore: todo
  // TODO: Replace _getMessageList
  Widget _getMessageList(MessageDao messageDao) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: messageDao.getMessageStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: LinearProgressIndicator());
          }
          return _buildList(context, snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    // 1
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      // 2
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    // 1
    final message = Message.fromSnapshot(snapshot);
    // 2
    return MessageWidget(
      message.text,
      message.date,
      message.email,
    );
  }

  bool _canSendMessage() => _messageController.text.length > 0;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
