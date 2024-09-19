import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController userMessage = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  static const apiKey = 'AIzaSyCUpf8KF0f75DVrURx_pD5KbfxK8EKhmpg';

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = userMessage.text;
    userMessage.clear();

    setState(() {
      _messages
          .add(Message(isUser: true, date: DateTime.now(), message: message));
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
          isUser: false, date: DateTime.now(), message: response.text ?? ""));
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
            userMessage.text =
                _spokenText; // Set recognized text to input field
          });
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
      backgroundColor: const Color(0xFFF2F2F2), // Light background color
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
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(55),
                        borderSide: BorderSide.none,
                      ),
                      label: const Text("Enter your query"),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _listen,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          _isListening ? Colors.redAccent : Colors.blueAccent,
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
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(15),
                    iconSize: 30,
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(IconsaxPlusLinear.arrow_circle_right,
                        color: Colors.white),
                  ),
                ),
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
      margin: const EdgeInsets.symmetric(vertical: 10).copyWith(
        left: isUser ? 80 : 10,
        right: isUser ? 10 : 80,
      ),
      decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            topRight: const Radius.circular(15),
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
                color: isUser ? Colors.white : Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              color: isUser ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
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
