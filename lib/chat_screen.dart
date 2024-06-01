import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bubbles/chat_bubbles.dart';
import 'message.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final snapshot =
        await _firestore.collection('chats').orderBy('timestamp').get();
    setState(() {
      msgs = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return Message(data['isSender'], data['msg']);
          })
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> saveMessage(String text, bool isSender) async {
    await _firestore.collection('chats').add({
      'msg': text,
      'isSender': isSender,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void sendMsg() async {
    String text = controller.text;
    controller.clear();
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        await saveMessage(text, true);

        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
        var response = await http.post(
            Uri.parse("https://frisbeechatbot-ulhjxrt7.b4a.run/chatbot"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"query": text}));
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          setState(() {
            isTyping = false;
            msgs.insert(0, Message(false, json['response_text']));
          });
          await saveMessage(json['response_text'], false);
          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred, please try again!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "City Gliders",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0060A6),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isTyping && index == 0
                        ? Column(
                            children: [
                              ChatBubble(
                                  text: msgs[0].msg,
                                  isSender: true,
                                  senderText: "User"),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Typing...")),
                              )
                            ],
                          )
                        : ChatBubble(
                            text: msgs[index].msg,
                            isSender: msgs[index].isSender,
                            senderText: msgs[index].isSender ? "User" : "Bot",
                          ),
                  );
                }),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          sendMsg();
                        },
                        textInputAction: TextInputAction.send,
                        showCursor: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Ask about frisbee",
                            hintStyle: TextStyle(fontWeight: FontWeight.w500),
                            contentPadding:
                                EdgeInsets.only(bottom: 8.0, left: 8.0)),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  sendMsg();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFF0060A6),
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final String senderText;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isSender,
    required this.senderText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            senderText,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF0060A6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        BubbleNormal(
          text: text,
          isSender: isSender,
          color: isSender ? const Color(0xFF0060A6) : Colors.white,
          textStyle: TextStyle(
            fontSize: 16,
            color: isSender ? Colors.white : const Color(0xFF0060A6),
          ),
        ),
      ],
    );
  }
}