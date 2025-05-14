import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/chat_provider.dart';

import '../utils/type_writer_text.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatMessages = chatState.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ai Chat Bot"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    if (index == 0) return const SizedBox.shrink();
                    final message = chatMessages[index];
                    final isUser = message["role"] == 'user';

                    final isLastBotMessage = index == chatMessages.length - 1 && !isUser && chatState.isTyping == false;

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.deepPurple[800] : Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isUser
                            ? Text(
                          message["content"] ?? '',
                          style: const TextStyle(color: Colors.white),
                        )
                            : isLastBotMessage
                            ? TypeWriterText(
                          text: message["content"] ?? '',
                          textStyle: const TextStyle(color: Colors.white),
                          speed: const Duration(milliseconds: 30),
                        )
                            : Text(
                          message["content"] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.send, // Show send button on keyboard
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(chatProvider.notifier).sendMessage(value);
                    _controller.clear();
                    FocusScope.of(context).unfocus(); // Close keyboard
                  }
                },
                decoration: InputDecoration(
                  labelText: "Enter your prompt",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        ref.read(chatProvider.notifier).sendMessage(_controller.text);
                        _controller.clear();
                        FocusScope.of(context).unfocus(); // Also close keyboard on button press
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.lightGreen,
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}

