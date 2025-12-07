import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/database_service.dart';

class ChatScreen extends StatefulWidget {
  final String coupleId;
  final String userId;

  const ChatScreen({super.key, required this.coupleId, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isUploading)
            const LinearProgressIndicator(color: Colors.pinkAccent),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _dbService.getChatStream(widget.coupleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text("Chưa có tin nhắn nào."));
        }

        Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map;
        List<dynamic> messages = map.entries.toList();

        // Sort by timestamp
        messages.sort(
          (a, b) =>
              (a.value['timestamp'] ?? 0).compareTo(b.value['timestamp'] ?? 0),
        );
        messages = messages.reversed.toList();

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].value;
            final isMe = msg['senderId'] == widget.userId;
            return _buildMessageExact(msg, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageExact(Map msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.pinkAccent : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: !isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg['imageUrl'] != null) _buildSecureImage(msg['imageUrl']),
            if (msg['text'] != null && msg['text'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  msg['text'],
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureImage(String url) {
    return SecureImageItem(url: url);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Colors.pinkAccent),
              onPressed: _pickImage,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "Nhắn gì đó...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.pinkAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _dbService.sendMessage(widget.coupleId, widget.userId, text);
    _textController.clear();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _isUploading = true);
      String? url = await _dbService.uploadImage(File(image.path));
      setState(() => _isUploading = false);

      if (url != null) {
        _dbService.sendMessage(
          widget.coupleId,
          widget.userId,
          "",
          imageUrl: url,
        );
      }
    }
  }
}

class SecureImageItem extends StatefulWidget {
  final String url;
  const SecureImageItem({super.key, required this.url});

  @override
  State<SecureImageItem> createState() => _SecureImageItemState();
}

class _SecureImageItemState extends State<SecureImageItem> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isRevealed = true),
      onTapUp: (_) => setState(() => _isRevealed = false),
      onTapCancel: () => setState(() => _isRevealed = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 200,
          height: 200,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: _isRevealed ? 0 : 10,
              sigmaY: _isRevealed ? 0 : 10,
            ),
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
