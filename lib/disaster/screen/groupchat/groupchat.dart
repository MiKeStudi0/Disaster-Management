import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class GroupChatPage extends StatefulWidget {
  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Map<String, String> userNames = {};
  bool isUserNamesLoaded = false;

  Future<String> _getCurrentUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user is currently logged in');
    }
  }

  Future<void> _sendMessage({String? text, File? file, String? fileType}) async {
    try {
      final userId = await _getCurrentUserId();
      final message = <String, dynamic>{
        'text': text ?? '',
        'senderId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'fileUrl': null,
        'fileType': fileType,
      };

      if (file != null) {
        final filePath = 'uploads/${DateTime.now().millisecondsSinceEpoch}';
        final uploadTask = _storage.ref(filePath).putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        message['fileUrl'] = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('group_chat').add(message);
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _sendMessage(file: File(pickedFile.path), fileType: 'image');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'mp3', 'mp4']);
    
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final extension = result.files.single.extension?.toLowerCase();

      if (extension == 'mp3') {
        _sendMessage(file: file, fileType: 'audio');
      } else if (extension == 'mp4') {
        _sendMessage(file: file, fileType: 'video');
      } else if (extension == 'jpg' || extension == 'png') {
        _sendMessage(file: file, fileType: 'image');
      }
    }
  }

  Future<void> _getUserNames() async {
    final snapshot = await _firestore.collection('users').get();
    for (var doc in snapshot.docs) {
      final userId = doc.id;
      final userName = doc.data()['name'] ?? 'Unknown User';
      userNames[userId] = userName;
    }
    setState(() {
      isUserNamesLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserNames();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Updates"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('group_chat').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final userId = data['senderId'] ?? '';
                    final userName = isUserNamesLoaded
                        ? userNames[userId] ?? 'Unknown User'
                        : 'Sending...';
                    final isSentByCurrentUser = userId == FirebaseAuth.instance.currentUser?.uid;

                    Widget fileWidget = Container();
                    if (data['fileType'] == 'image') {
                      fileWidget = Image.network(
                        data['fileUrl'],
                        width: 250,
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    } else if (data['fileType'] == 'audio') {
                      fileWidget = IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          AudioPlayer player = AudioPlayer();
                          player.play(data['fileUrl']);
                        },
                      );
                    } else if (data['fileType'] == 'video') {
                      fileWidget = VideoPlayerWidget(url: data['fileUrl']);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      child: Align(
                        alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser ? Colors.teal.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isSentByCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    child: Text(userName[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: 8),
                                  Text(userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              fileWidget,
                              SizedBox(height: 6),
                              Text(
                                data['text'] ?? 'No text',
                                style: TextStyle(
                                  color: isSentByCurrentUser ? Colors.black : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.teal),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.teal),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _sendMessage(text: _messageController.text.trim());
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

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          )
        : CircularProgressIndicator();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
