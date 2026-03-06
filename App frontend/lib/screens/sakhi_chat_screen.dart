import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SakhiChatScreen extends StatefulWidget {
  const SakhiChatScreen({super.key});

  @override
  State<SakhiChatScreen> createState() => _SakhiChatScreenState();
}

class _SakhiChatScreenState extends State<SakhiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  bool _isTyping = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  late AnimationController _dotController;

  String? _workerId;
  String? _workerName;

  final List<String> _suggestions = [
    '📊 My tasks today',
    '🤰 High-risk patients',
    '💊 Inventory status',
    '🏠 Household summary',
    '📈 District overview',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadUserContext();
    _addBotMessage(
      'Namaste! 🙏 I\'m SakhiAI, your healthcare companion.\n\n'
      'Ask me anything — about your patients, tasks, health topics, or just chat!\n\n'
      'Try tapping a suggestion below to get started.',
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => debugPrint('onError: $val'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _messageController.text = result.recognizedWords;
            _messageController.selection = TextSelection.fromPosition(TextPosition(offset: _messageController.text.length));
          });
        }
      },
    );
    if (mounted) setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() => _isListening = false);
  }

  Future<void> _loadUserContext() async {
    _workerId = await AuthService.getWorkerId();
    _workerName = await AuthService.getWorkerName();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'assistant', 'content': text, 'time': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text.trim(), 'time': DateTime.now()});
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await ApiService.post('/sakhi/chat', {
        'message': text.trim(),
        'conversationHistory': _conversationHistory,
        'workerId': _workerId ?? '',
        'workerName': _workerName ?? 'ASHA Worker',
        'role': 'worker',
      });

      // Update conversation history for context
      _conversationHistory.add({'role': 'user', 'content': text.trim()});

      if (response != null && response['reply'] != null) {
        _conversationHistory.add({'role': 'assistant', 'content': response['reply']});
        _addBotMessage(response['reply']);
      } else {
        _addBotMessage('Sorry, I couldn\'t get a response. Please try again. 🙏');
      }
    } catch (e) {
      _addBotMessage('Connection error. Please check your internet and try again. 📡');
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_messages.length <= 1) _buildSuggestions(),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyTheme.primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/SakhiAI.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SakhiAI', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Text(
                _isTyping ? 'Thinking...' : 'Your Health Companion',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 22),
          onPressed: () {
            setState(() {
              _messages.clear();
              _conversationHistory.clear();
            });
            _addBotMessage('Chat cleared! How can I help you? 🙏');
          },
          tooltip: 'Clear Chat',
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return _buildMessageBubble(msg['content'], isUser, msg['time']);
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, DateTime time) {
    return Padding(
      padding: EdgeInsets.only(
        top: 6,
        bottom: 6,
        left: isUser ? 50 : 0,
        right: isUser ? 0 : 50,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                ),
                child: ClipOval(
                  child: Image.asset('assets/images/SakhiAI.png', fit: BoxFit.cover),
                ),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? MyTheme.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isUser ? MyTheme.primaryBlue : Colors.black).withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}',
                      style: TextStyle(
                        color: isUser ? Colors.white60 : Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((s) {
          return InkWell(
            onTap: () => _sendMessage(s),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MyTheme.primaryBlue.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Text(s, style: TextStyle(fontSize: 13, color: MyTheme.primaryBlue, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: AnimatedBuilder(
            animation: _dotController,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.3;
                  final t = ((_dotController.value + delay) % 1.0);
                  final scale = 0.5 + 0.5 * (t < 0.5 ? t * 2 : (1.0 - t) * 2);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: MyTheme.primaryBlue.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 8, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask SakhiAI anything...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onSubmitted: (val) => _sendMessage(val),
            ),
          ),
          const SizedBox(width: 8),
          if (_speechEnabled)
            GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) => _stopListening(),
              onTapCancel: () => _stopListening(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : const Color(0xFFF5F7FA),
                  shape: BoxShape.circle,
                  boxShadow: _isListening 
                    ? [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] 
                    : [],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: _isListening ? Colors.white : MyTheme.primaryBlue,
                  size: 22,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [MyTheme.primaryBlue, MyTheme.primaryBlue.withOpacity(0.8)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: MyTheme.primaryBlue.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
