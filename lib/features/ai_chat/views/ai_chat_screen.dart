import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';

class AiChatScreen extends StatefulWidget {
  final String? initialQuery;

  const AiChatScreen({super.key, this.initialQuery});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hello Sritan! 👋 I am your VistaCortex AI health assistant. I can help explain your lab test reports, track your medications, or answer recovery questions.',
      'time': 'Just now',
    },
    {
      'isUser': false,
      'text': 'Your recent CBC blood test from Apollo Hospitals looks great! All parameters are within the healthy normal range.',
      'time': 'Just now',
    },
  ];

  final List<String> _suggestions = [
    'Explain my CBC report',
    'Diet tips for hemoglobin',
    'When is my next dose?',
    'Recovery timeline for surgery',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _sendMessage(widget.initialQuery!);
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'isUser': true,
        'text': text.trim(),
        'time': 'Now',
      });
      _controller.clear();
    });

    // Simulate smart AI response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      String reply = 'Based on your health records, maintaining a balanced diet, staying hydrated, and adhering to your prescribed Vitamin D3 and Metformin will keep your parameters optimal.';
      if (text.toLowerCase().contains('cbc') || text.toLowerCase().contains('report') || text.toLowerCase().contains('blood')) {
        reply = 'Your CBC report from 12 Aug 2025 at Apollo Hospitals shows:\n• Hemoglobin: 13.8 g/dL (Optimal)\n• WBC: 6,200 /μL (Healthy)\n• Platelets: 2.5 lakh/μL (Normal)\nEverything is within safe clinical boundaries!';
      } else if (text.toLowerCase().contains('diet') || text.toLowerCase().contains('food')) {
        reply = 'Recommended for you today:\n• Breakfast: Oats with nuts & green tea\n• Lunch: Brown rice, grilled chicken & fresh salad\n• Tip: Include iron-rich foods like spinach and legumes.';
      } else if (text.toLowerCase().contains('dose') || text.toLowerCase().contains('med')) {
        reply = 'Your next scheduled dose is:\n• Vitamin D3 (1 Tablet) at 1:00 PM after lunch\n• Metformin (1 Tablet) scheduled for 8:00 AM tomorrow.';
      }

      setState(() {
        _messages.add({
          'isUser': false,
          'text': reply,
          'time': 'Now',
        });
      });

      _scrollToBottom();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VistaCortex AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border: isUser ? null : Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            color: isUser ? Colors.white : AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggestion chips
          Container(
            height: 42,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    label: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _sendMessage(suggestion),
                  ),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask anything about your health...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
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
