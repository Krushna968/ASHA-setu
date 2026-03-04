import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _Message {
  final String text;
  final bool isSentByMe;
  final String time;

  _Message({
    required this.text,
    required this.isSentByMe,
    required this.time,
  });
}

class _MessengerScreenState extends State<MessengerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingController;
  
  // Dummy data for empty state testing.
  // Set to empty list `[]` to test empty state.
  List<_Message> messages = [];

  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        // If we scroll up by more than 100 pixels, show the button
        final offset = _scrollController.position.pixels;
        final maxOffset = _scrollController.position.maxScrollExtent;
        setState(() {
          _showScrollToBottom = maxOffset - offset > 100;
        });
      }
    });

    // Populate with some initial dummy data to show the UI
    messages = [
      _Message(
        text: 'Hello Dr. Anjali. I visited the Sharma household today.',
        isSentByMe: true,
        time: '10:05 AM',
      ),
      _Message(
        text: 'Hello Raj. How is the newborn baby doing?',
        isSentByMe: false,
        time: '10:12 AM',
      ),
      _Message(
        text: 'The baby is healthy. Weight is normal and vaccinations are up to date.',
        isSentByMe: true,
        time: '10:15 AM',
      ),
      _Message(
        text: 'Excellent. Please update the registry later today.',
        isSentByMe: false,
        time: '10:30 AM',
      ),
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    setState(() {
      messages.add(_Message(
        text: text,
        isSentByMe: true,
        time: timeStr,
      ));
      _msgController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Light grey, similar to WhatsApp
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
                if (_showScrollToBottom)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: _scrollToBottom,
                      backgroundColor: Colors.white,
                      foregroundColor: MyTheme.primaryBlue,
                      elevation: 2,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
              ],
            ),
          ),
          _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyTheme.primaryBlue,
      elevation: 1,
      automaticallyImplyLeading: false, // For testing context
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 20,
            child: Text(
              'DA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dr. Anjali',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_rounded,
              size: 64,
              color: MyTheme.primaryBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your supervisor.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool showAvatar = !msg.isSentByMe && 
            (index == messages.length - 1 || messages[index + 1].isSentByMe);

        return _buildChatBubble(msg, showAvatar);
      },
    );
  }

  Widget _buildChatBubble(_Message msg, bool showAvatar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            msg.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isSentByMe) ...[
            if (showAvatar)
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.purple,
                child: Text('DA', style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isSentByMe ? MyTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isSentByMe ? 16 : 4),
                  bottomRight: Radius.circular(msg.isSentByMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: msg.isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: msg.isSentByMe ? Colors.white : MyTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: msg.isSentByMe
                              ? Colors.white70
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (msg.isSentByMe) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A static UI element indicating the other person is typing...
  Widget _buildTypingIndicator() {
    // We'll show it based on a dummy condition or just leave it hidden by default 
    // unless simulating it. Here we make it static for demonstration as requested.
    bool isTyping = false; // toggle to true to see the effect while testing
    
    // ignore: dead_code
    if (!isTyping) return const SizedBox.shrink();

    // ignore: dead_code
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        // Create a staggered bounce effect
        final offset = index * 0.2;
        final progress = (_typingController.value - offset).clamp(0.0, 1.0);
        final sineValue = progress > 0.0 && progress < 0.6
            ? (progress * 3.14159 / 0.6) // Math.sin parameter
            : 0.0;
        
        // Simple manual implementation of sine wave
        double yPos = 0.0;
        if (sineValue > 0) {
           // Approximation of sine for the bounce
           yPos = -4.0 * (1 - ((sineValue - 1.57).abs() / 1.57)); 
        }

        return Transform.translate(
          offset: Offset(0, yPos < -4.0 ? -4.0 : yPos),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.attach_file_rounded, color: Colors.grey.shade600),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Scrollbar(
                  child: TextField(
                    controller: _msgController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                color: MyTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
