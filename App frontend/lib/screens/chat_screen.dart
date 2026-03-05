import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String initials;
  final Color avatarColor;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.initials,
    required this.avatarColor,
    this.isOnline = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _Message {
  final String text;
  final bool isSentByMe;
  final String time;
  final String? attachment;
  final bool isAcknowledged;

  _Message({
    required this.text,
    required this.isSentByMe,
    required this.time,
    this.attachment,
    this.isAcknowledged = false,
  });
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingController;
  final ImagePicker _picker = ImagePicker();
  
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
        final offset = _scrollController.position.pixels;
        final maxOffset = _scrollController.position.maxScrollExtent;
        setState(() {
          _showScrollToBottom = maxOffset - offset > 100;
        });
      }
    });

    messages = [
      _Message(
        text: 'Hello ${widget.contactName}. I visited the Sharma household today.',
        isSentByMe: true,
        time: '10:05 AM',
        isAcknowledged: true,
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
        isAcknowledged: true,
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
    final timeStr = DateFormat('h:mm a').format(now);

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final now = DateTime.now();
        final timeStr = DateFormat('h:mm a').format(now);
        setState(() {
          messages.add(_Message(
            text: 'Shared a photo',
            isSentByMe: true,
            time: timeStr,
            attachment: 'image',
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 20,
            child: Text(
              widget.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contactName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.isOnline)
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
                      'Monitoring Active',
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
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyTheme.textDark,
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
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.avatarColor,
                child: Text(widget.initials, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                  if (msg.attachment != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(msg.attachment == 'image' ? Icons.image : Icons.insert_drive_file, color: msg.isSentByMe ? Colors.white70 : Colors.grey),
                          const SizedBox(width: 8),
                          Text(msg.attachment == 'image' ? 'Image Attached' : 'Document Attached', style: TextStyle(color: msg.isSentByMe ? Colors.white : MyTheme.textDark, fontSize: 12)),
                        ],
                      ),
                    ),
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
                        Icon(
                          msg.isAcknowledged ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 14,
                          color: msg.isAcknowledged ? Colors.greenAccent : Colors.white70,
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

  Widget _buildTypingIndicator() {
    return const SizedBox.shrink();
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
              onPressed: _showAttachmentMenu,
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
                      hintText: 'Acknowledge or respond...',
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

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(Icons.insert_drive_file, Colors.indigo, 'Document', () {
                    Navigator.pop(context);
                    setState(() {
                      messages.add(_Message(
                        text: 'Shared a document',
                        isSentByMe: true,
                        time: DateFormat('h:mm a').format(DateTime.now()),
                        attachment: 'doc',
                      ));
                    });
                    _scrollToBottom();
                  }),
                  _buildAttachmentOption(Icons.camera_alt, Colors.pink, 'Camera', () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
                  _buildAttachmentOption(Icons.photo, Colors.purple, 'Gallery', () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
