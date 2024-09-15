import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController userMessage = TextEditingController();

  static const apiKey = 'AIzaSyCUpf8KF0f75DVrURx_pD5KbfxK8EKhmpg';

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = userMessage.text;
    userMessage.clear();

    setState(() {
      //user messages to chat
      _messages
          .add(Message(isUser: true, date: DateTime.now(), message: message));
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      //user messages to chat
      _messages.add(Message(
          isUser: false, date: DateTime.now(), message: response.text ?? ""));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Messages(
                  isUser: message.isUser,
                  date: DateFormat('HH:mm').format(message.date),
                  message: message.message);
            },
          )),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: TextFormField(
                    controller: userMessage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(55),
                      ),
                      label: const Text("Enter your query"),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                    padding: const EdgeInsets.all(15),
                    iconSize: 30,
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(IconsaxPlusLinear.arrow_circle_right))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  const Messages(
      {super.key,
      required this.isUser,
      required this.date,
      required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
          color: isUser
              ? const Color.fromARGB(0, 0, 0, 0)
              : Color.fromARGB(0, 203, 203, 205),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            topRight: const Radius.circular(15),
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: isUser ? Colors.cyan : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(color: isUser ? Colors.cyan : Colors.black),
          )
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  Message({required this.isUser, required this.date, required this.message});
}
