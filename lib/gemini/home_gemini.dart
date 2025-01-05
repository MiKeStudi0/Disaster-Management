// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// const apiEndpoint = 'https://api.openai.com/v1/completions'; 
// const apiKey = 'AIzaSyCCuGo-96L5CV31aTiAWpzJm0vUWTZm0MI'; // Temporarily hardcoded for testing

// Future<String> sendMessage(String message) async {
//   final headers = {
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer $apiKey',
//   };

//   final body = jsonEncode({
//     'model': 'text-davinci-003', // Confirm model name
//     'prompt': message,
//     'max_tokens': 1024,
//     'temperature': 0.5,
//   });

//   try {
//     final response = await http.post(Uri.parse(apiEndpoint), headers: headers, body: body);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['choices'][0]['text'].trim();
//     } else {
//       // Capture more information about the error response
//       print('Failed response: ${response.body}');
//       return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
//     }
//   } catch (e) {
//     print('Error: $e');
//     return 'Error: Could not send the message. Please try again later.';
//   }
// }

// class ChatWidget extends StatefulWidget {
//   const ChatWidget({super.key});

//   @override
//   _ChatWidgetState createState() => _ChatWidgetState();
// }

// class _ChatWidgetState extends State<ChatWidget> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<Map<String, String>> _messages = [];

//   void _sendMessage() async {
//     final message = _messageController.text;
//     if (message.isNotEmpty) {
//       setState(() {
//         _messages.add({'role': 'user', 'content': message});
//       });

//       final response = await sendMessage(message);
//       setState(() {
//         _messages.add({'role': 'assistant', 'content': response});
//       });

//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat with AI'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isUser = message['role'] == 'user';
//                 return ListTile(
//                   title: Text(
//                     message['content']!,
//                     style: TextStyle(color: isUser ? Colors.blue : Colors.grey),
//                   ),
//                   trailing: isUser ? const Icon(Icons.check, color: Colors.blue) : null,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your message',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _sendMessage,
//                   icon: const Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini AI Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatWidget(),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final String apiKey = 'AIzaSyCCuGo-96L5CV31aTiAWpzJm0vUWTZm0MI'; // Replace with your API key
  
  bool isLoading = false;

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add('You: $message');
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'), // Replace with actual Gemini AI endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages.add('Gemini: ${data['response']}');
        isLoading = false;
      });
    } else {
      setState(() {
        _messages.add('Error: Failed to get response');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_messages[index]),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
