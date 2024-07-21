import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final List<String> _messages = []; // List to hold messages
  final TextEditingController _messageController =
      TextEditingController(); // Controller for message input
  final ScrollController _scrollController =
      ScrollController(); // ScrollController for scrolling to bottom

  @override
  void initState() {
    super.initState();
    // Ensure the ListView starts from the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add('You: $message'); // Add user message to the list
      });
      _messageController.clear();

      try {
        final responseData = await generateContent(message);
        final generatedText =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _messages.add('AI: $generatedText'); // Add AI response to the list
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _messages.add('AI: Sorry, I could not process your request.');
        });
      } finally {
        // Ensure scrolling to the bottom after new messages are added
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear(); // Clear the list of messages
    });
  }

  Future<Map<String, dynamic>> generateContent(String message) async {
    final apiKey =
        'AIzaSyBuQv3kGcyGW_JhDsh8dntQ9PHXjXRFg4w'; // Replace with your actual API key
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': message}
          ]
        }
      ]
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load content');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _clearChat();
              },
              icon: const Icon(
                Icons.clear_all,
                color: Colors.white,
              ))
        ],
        centerTitle: true,
        title: const Text(
          'Ask to Lumiconvo',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/13d7eb0ed317a25314a5bbb14e0d4ce8.jpg',
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
            child: Container(
              color: Colors.black.withOpacity(0), // Adjust opacity as needed
            ),
          ),
          // Main content
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Hi there',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "I'm Lumiconvo. How can I assist you today?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        // Keep this to ensure new messages appear at the bottom
                        controller:
                            _scrollController, // Set the scroll controller
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUserMessage = message
                              .startsWith('You:'); // Determine message type

                          return Align(
                            alignment: isUserMessage
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.75, // Max width of 70% of screen width
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: isUserMessage
                                        ? const Color.fromARGB(
                                            255, 101, 100, 100)
                                        : Colors.black,
                                    borderRadius: isUserMessage
                                        ? const BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            topLeft: Radius.circular(20))
                                        : const BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                child: Text(
                                  message,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: 10,
                        minLines: 1,
                        style: const TextStyle(color: Colors.white),
                        controller: _messageController,
                        decoration: InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          hintStyle: const TextStyle(color: Colors.white),
                          hintText: 'Type a message',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
