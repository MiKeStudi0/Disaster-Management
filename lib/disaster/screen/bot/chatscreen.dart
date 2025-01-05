import 'package:disaster_management/disaster/screen/rescue/const.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> with TickerProviderStateMixin {
  final TextEditingController userMessage = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  static const apiKey = map;

  final model = GenerativeModel(model: 'gemini-2.0-flash-exp', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = userMessage.text;
    userMessage.clear();

    setState(() {
      _messages.add(Message(isUser: true, date: DateTime.now(), message: message));
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(isUser: false, date: DateTime.now(), message: response.text ?? ""));
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          if (mounted) { // Ensure widget is still mounted before updating state
            setState(() {
              _spokenText = result.recognizedWords;
              userMessage.text = _spokenText; // Set recognized text to input field
            });
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with me"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(), // Smooth scrolling
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: userMessage,
                        decoration: const InputDecoration(
                          filled: true,
                          border: InputBorder.none,
                          hintText: "Enter your query",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _listen,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent : Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          _isListening
                              ? IconsaxPlusLinear.microphone_slash
                              : IconsaxPlusLinear.microphone,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(15),
                      iconSize: 30,
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(IconsaxPlusLinear.arrow_circle_right, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth transition
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 10).copyWith(
        left: message.isUser ? 80 : 10,
        right: message.isUser ? 10 : 80,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? Colors.blueAccent : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          bottomLeft: message.isUser ? const Radius.circular(15) : Radius.zero,
          topRight: const Radius.circular(15),
          bottomRight: message.isUser ? Radius.zero : const Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message,
            style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('HH:mm').format(message.date),
            style: TextStyle(
              color: message.isUser ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
          ),
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
