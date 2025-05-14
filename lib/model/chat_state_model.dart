class ChatStateModel {
  final List<Map<String, String>> messages;
  final bool isTyping;

  ChatStateModel({required this.messages, this.isTyping = false});

  ChatStateModel copyWith({
    List<Map<String, String>>? messages,
    bool? isTyping,
  }) {
    return ChatStateModel(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}