// support_chat_page.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late final Dio _dio;

  String _ticketId = '';
  int _myUserId = 0;
  String _myName = 'Jij';

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  int _lastId = 0;
  Timer? _pollTimer;

  final String _jwtSecret = 'rma-app-secret-2024';

  @override
  void initState() {
    super.initState();
    _dio = _buildDio();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ticketId.isNotEmpty) return;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) {
      _ticketId = arg;
    }

    _init();
  }

  Future<void> _init() async {
    await _loadUser();
    await _loadMessages();

    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _pollNew(),
    );
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    _myName = prefs.getString('user_name') ?? 'Jij';
    _myUserId = prefs.getInt('user_id') ?? 0;

    if (_myUserId == 0) {
      final token = prefs.getString('auth_token');
      final tokenUserId = _extractUserIdFromJwt(token);
      if (tokenUserId != null) {
        _myUserId = tokenUserId;
      }
    }
  }

  int? _extractUserIdFromJwt(String? token) {
    try {
      if (token == null || token.isEmpty) return null;

      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = jsonDecode(decoded);

      final sub = data['sub'];
      if (sub == null) return null;

      return int.tryParse(sub.toString());
    } catch (_) {
      return null;
    }
  }

  Dio _buildDio() {
    String baseUrl = 'http://127.0.0.1:8000';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8000';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'jwt-secret': _jwtSecret,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['user-token'] = token;
            options.headers['usertoken'] = token;
          }

          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);

    try {
      final cleanTicketId = _ticketId.replaceAll('#', '').trim();
      final res = await _dio.get('/api/message/since/$cleanTicketId/0');

      final raw = (res.data['messages'] is List)
          ? res.data['messages'] as List
          : <dynamic>[];

      final msgs = raw
          .map((e) => ChatMessage.fromJson(
        Map<String, dynamic>.from(e),
        myUserId: _myUserId,
        myName: _myName,
      ))
          .toList();

      msgs.sort((a, b) => a.id.compareTo(b.id));

      setState(() {
        _messages = msgs;
        _lastId = msgs.isNotEmpty ? msgs.last.id : 0;
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pollNew() async {
    try {
      final cleanTicketId = _ticketId.replaceAll('#', '').trim();
      final res = await _dio.get('/api/message/since/$cleanTicketId/$_lastId');

      final raw = (res.data['messages'] is List)
          ? res.data['messages'] as List
          : <dynamic>[];

      if (raw.isEmpty) return;

      final msgs = raw
          .map((e) => ChatMessage.fromJson(
        Map<String, dynamic>.from(e),
        myUserId: _myUserId,
        myName: _myName,
      ))
          .toList();

      setState(() {
        for (final msg in msgs) {
          final exists = _messages.any((m) => m.id == msg.id);
          if (!exists) _messages.add(msg);
        }
        _messages.sort((a, b) => a.id.compareTo(b.id));
        _lastId = _messages.last.id;
      });

      _scrollToBottom();
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final temp = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      senderName: _myName,
      text: text,
      isMe: true,
      time: _now(),
    );

    setState(() {
      _messages.add(temp);
      _sending = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final cleanTicketId = _ticketId.replaceAll('#', '').trim();

      final res = await _dio.post(
        '/api/message',
        data: {
          'ticket_id': int.parse(cleanTicketId),
          'message': text,
        },
      );

      if (res.data['success'] == true) {
        setState(() {
          _messages.removeWhere((m) => m.id == temp.id);
          _sending = false;
        });

        await _pollNew();
      } else {
        setState(() => _sending = false);
      }
    } catch (_) {
      setState(() => _sending = false);
    }
  }

  String _now() {
    final t = TimeOfDay.now();
    return "${t.hour}:${t.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Support Chat",
            style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) =>
                  ChatBubble(message: _messages[i]),
            ),
          ),
          _input(),
        ],
      ),
    );
  }

  Widget _input() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(message.senderName,
                    style: const TextStyle(fontSize: 12)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color:
                      message.isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final int id;
  final String senderName;
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.isMe,
    required this.time,
  });

  factory ChatMessage.fromJson(
      Map<String, dynamic> json, {
        required int myUserId,
        required String myName,
      }) {
    final user = json['user'];
    final senderId = user?['id'];

    final isMe = senderId == myUserId;

    return ChatMessage(
      id: json['id'],
      senderName: isMe ? myName : 'DMG Service Team',
      text: json['message'],
      isMe: isMe,
      time: json['created_at'] ?? '',
    );
  }
}