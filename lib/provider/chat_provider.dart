import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/chat_state_model.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatStateModel>(
  (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<ChatStateModel> {
  ChatNotifier()
      : super(ChatStateModel(messages: [
          {"role": "system", "content": "You are a helpful assistant."},
        ]));

  Future<void> sendMessage(String prompt) async {
    final userMessage = {"role": "user", "content": prompt};
    final loadingMessage = {"role": "system", "content": "..."};

    state = state.copyWith(
      messages: [...state.messages, userMessage, loadingMessage],
      isTyping: true,
    );

    final data = {
      "model": "llama3.2",
      "messages":
          state.messages.where((msg) => msg["content"] != "...").toList(),
      "stream": false,
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:11434/api/chat"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final botMessage = {
          "role": "system",
          "content": (responseData["message"]["content"] ?? '').toString(),
        };

        state = state.copyWith(
          messages: [
            ...state.messages.where((msg) => msg["content"] != "..."),
            botMessage,
          ],
          isTyping: false,
        );
      } else {
        state = state.copyWith(
          messages: state.messages
            ..remove(userMessage)
            ..remove(loadingMessage),
          isTyping: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        messages: state.messages
          ..remove(userMessage)
          ..remove(loadingMessage),
        isTyping: false,
      );
    }
  }
}
