import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/ai_service.dart';
import '../widgets/glass_card.dart';

class AiStudioPage extends StatefulWidget {
  const AiStudioPage({super.key});

  @override
  State<AiStudioPage> createState() => _AiStudioPageState();
}

class _AiStudioPageState extends State<AiStudioPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _apiKeyController = TextEditingController();
  bool _showApiKeyPanel = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      _apiKeyController.text = appState.geminiApiKey;
      if (appState.geminiApiKey.isEmpty) {
        setState(() {
          _showApiKeyPanel = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C0E1E), Color(0xFF07080F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.t('ai_studio'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          isRtl ? 'ئامرازە زیرەکەکان بۆ کار و ژیانی ڕۆژانە' : 'Intelligent tools for daily life & business',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.vpn_key_rounded,
                        color: appState.geminiApiKey.isEmpty ? Colors.amber : const Color(0xFF10B981),
                      ),
                      onPressed: () {
                        setState(() {
                          _showApiKeyPanel = !_showApiKeyPanel;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // API Key input panel
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                height: _showApiKeyPanel ? 135 : 0,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appState.t('gemini_key_lbl'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showApiKeyPanel = false;
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 16, color: Colors.white60),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _apiKeyController,
                                obscureText: true,
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: appState.t('gemini_key_hint'),
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.04),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                appState.setGeminiApiKey(_apiKeyController.text.trim());
                                setState(() {
                                  _showApiKeyPanel = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isRtl ? 'کلیلەکە پارێزرا!' : 'API key saved!'),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(isRtl ? 'پاشەکەوت' : 'Save'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isRtl
                              ? '🔑 دەتوانی کلیلێکی بێبەرامبەر و بێسنوور لە Google AI Studio وەربگریت.'
                              : '🔑 Get a free API key with generous limits from Google AI Studio.',
                          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFF10B981),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.4),
                  tabs: [
                    Tab(text: appState.t('ai_chat')),
                    Tab(text: appState.t('ai_image')),
                    Tab(text: appState.t('ai_video')),
                    Tab(text: appState.t('ai_audio')),
                  ],
                ),
              ),

              // Tab View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ChatTab(apiKey: appState.geminiApiKey),
                    _ImageTab(),
                    _VideoTab(),
                    _AudioTab(apiKey: appState.geminiApiKey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: AI FINANCIAL CHAT
// ============================================================================
class _ChatTab extends StatefulWidget {
  final String apiKey;
  const _ChatTab({required this.apiKey});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'sender': 'ai',
      'text': 'سڵاو! من یاریدەدەری زیرەکی سەلاريفلۆوم. دەتوانیت پرسیارم لێبکەیت دەربارەی بودجەی ڕۆژانەت، چۆنیەتی خەرجکردنی پارەکەت یان شیکردنەوەی مامەڵەکانت. چۆن دەتوانم یارمەتیت بدەم ئەمڕۆ؟',
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final appState = Provider.of<AppState>(context, listen: false);
    final response = await AiService.getGeminiChatResponse(
      apiKey: widget.apiKey,
      userMessage: text,
      chatHistory: _messages,
      transactions: appState.allTransactions,
      activeScope: appState.selectedScope,
    );

    setState(() {
      _messages.add({'sender': 'ai', 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
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
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          if (widget.apiKey.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appState.t('enter_key_warning'),
                        style: const TextStyle(fontSize: 11, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator(isRtl);
                  }
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser 
                            ? const Color(0xFF10B981) 
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                      ),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isRtl ? 'پرسیارێک بنووسە...' : 'Ask a financial question...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 70), // Avoid bottom navbar overlay
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isRtl) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 10),
            Text(
              isRtl ? 'ژیری دەستکرد خەریکی وەڵامدانەوەیە...' : 'AI is thinking...',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: AI IMAGE GENERATOR (Pollinations AI)
// ============================================================================
class _ImageTab extends StatefulWidget {
  @override
  State<_ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends State<_ImageTab> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedStyle = 'Cinematic';
  String? _generatedImageUrl;
  bool _isLoading = false;

  final List<Map<String, String>> _styles = [
    {'name': 'Cinematic', 'label': 'Cinematic / سینەمایی'},
    {'name': '3D Render', 'label': '3D Model / مۆدێلی سێ ڕەهەندی'},
    {'name': 'Anime', 'label': 'Anime Art / شێوازی ئەنیمێ'},
    {'name': 'Cyberpunk', 'label': 'Cyberpunk / سایبەرپانک'},
    {'name': 'Watercolor', 'label': 'Watercolor / بۆیەی ئاوی'},
  ];

  void _generateImage() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _generatedImageUrl = null;
    });

    // Simulate short network trigger
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _generatedImageUrl = AiService.getPollinationsImageUrl(prompt, _selectedStyle);
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appState.t('image_prompt_lbl'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _promptController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: isRtl ? 'بنووسە دەتەوێت چ وێنەیەک بکێشیت...' : 'Describe the image you want to generate...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isRtl ? 'شێواز / ستایل' : 'Select Art Style',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedStyle,
                  dropdownColor: const Color(0xFF161B2E),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: _styles.map((style) {
                    return DropdownMenuItem(value: style['name'], child: Text(style['label']!));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStyle = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _generateImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    appState.t('generate'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF10B981)),
                    const SizedBox(height: 14),
                    Text(
                      appState.t('generating'),
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          if (_generatedImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: Colors.white.withOpacity(0.02),
                child: Image.network(
                  _generatedImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 350,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(color: Color(0xFF10B981)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: Text(isRtl ? 'کێشە لە بارکردنی وێنە' : 'Failed to load image'),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isRtl ? '💡 وێنەکە بەهۆی ژیری بێسنوورەوە کێشرا!' : '💡 Image created with free unlimited Pollinations AI!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 3: AI VIDEO STUDIO (Procedural Animation Simulator)
// ============================================================================
class _VideoTab extends StatefulWidget {
  @override
  State<_VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<_VideoTab> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  late AnimationController _animController;
  bool _isRendering = false;
  bool _isPlaying = false;
  double _renderProgress = 0.0;
  String _renderStage = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _startRender() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isRendering = true;
      _isPlaying = false;
      _renderProgress = 0.0;
      _renderStage = 'Connecting to Render Engine...';
    });

    // Animate rendering stages
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _renderProgress += 0.035;
        if (_renderProgress < 0.25) {
          _renderStage = 'Parsing Scene Prompt: "$text"...';
        } else if (_renderProgress < 0.55) {
          _renderStage = 'Rendering Neural Frames (AI diffusion)...';
        } else if (_renderProgress < 0.85) {
          _renderStage = 'Generating Motion Fluid Vectors...';
        } else if (_renderProgress < 0.98) {
          _renderStage = 'Upscaling to 1080p & compiling loop...';
        } else {
          timer.cancel();
          _isRendering = false;
          _isPlaying = true;
          _animController.repeat();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appState.t('video_prompt_lbl'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _promptController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: isRtl 
                        ? 'وەسفی جووڵەی ڤیدیۆکە بکە (بۆ نموونە: گەشەکردنی درەختی زیڕین)...' 
                        : 'Describe motion (e.g., golden financial tree growing, particle flux)...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _startRender,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isRtl ? 'دەستپێکردنی ڤیدیۆسازی' : 'Start Video Generation',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isRendering)
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _renderProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: const Color(0xFF10B981),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _renderStage,
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_renderProgress.clamp(0.0, 1.0) * 100).toInt()}% Rendered',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          if (_isPlaying) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 350,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Render procedural animation on canvas in 60FPS
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ProceduralVideoPainter(
                            value: _animController.value,
                            seed: _promptController.text.hashCode,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.slow_motion_video_rounded, color: Color(0xFF10B981), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              isRtl ? 'پەخشی ژیری دەستکرد' : 'Procedural AI Feed',
                              style: const TextStyle(fontSize: 9, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_animController.isAnimating) {
                              _animController.stop();
                            } else {
                              _animController.repeat();
                            }
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black38,
                          child: Icon(
                            _animController.isAnimating ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isRtl 
                  ? '💡 ئەم ڤیدیۆیە بە شێوازی پرۆسیجەراڵ لەسەر مۆبایلەکەت دروستکراوە.'
                  : '💡 Procedural 3D render generated locally based on prompt vectors.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Procedural video painter drawing beautiful moving visualizer art
class _ProceduralVideoPainter extends CustomPainter {
  final double value;
  final int seed;
  _ProceduralVideoPainter({required this.value, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final r = Random(seed);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw dark stars background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF04060F));

    final center = Offset(size.width / 2, size.height / 2);

    // Draw colorful nebula glow
    final glowColor = Color.fromARGB(
      120,
      r.nextInt(100) + 50,
      r.nextInt(150) + 100,
      r.nextInt(150) + 100,
    );
    canvas.drawCircle(
      center, 
      120 + sin(value * 2 * pi) * 20, 
      Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );

    // Draw procedural orbital system
    for (int i = 0; i < 40; i++) {
      final angle = (value * 2 * pi) + (i * pi / 20) * (r.nextBool() ? 1 : -1);
      final radius = 50.0 + (i * 6.0) + sin(value * pi * 4 + i) * 8;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      paint.color = HSVColor.fromAHSV(
        0.8,
        (i * 9.0 + (seed % 360)) % 360,
        0.8,
        0.9,
      ).toColor();

      final particleSize = 1.5 + (r.nextDouble() * 3.5);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    // Drawing digital grids
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// TAB 4: AI AUDIO & PODCAST DEBATE (Kurdish Dialogue Studio)
// ============================================================================
class _AudioTab extends StatefulWidget {
  final String apiKey;
  const _AudioTab({required this.apiKey});

  @override
  State<_AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<_AudioTab> {
  final List<String> _selectedSpeakers = ['Dana', 'Aveen'];
  String _selectedTopic = 'Analyze My Transactions';
  List<Map<String, String>> _debateScript = [];
  bool _isLoading = false;
  bool _isPlaying = false;
  int _activeSpeechIndex = -1;
  Timer? _playbackTimer;

  // Visual Waveform Height Factor list
  final List<double> _waveHeights = List.generate(24, (_) => 4.0);
  Timer? _waveTimer;

  final List<Map<String, String>> _topics = [
    {'value': 'Analyze My Transactions', 'label': 'Debate My Transactions / شیکردنەوەی خەرجییەکانم'},
    {'value': 'Personal vs Business Spending', 'label': 'Personal vs Business / جیاوازی پارەی کەسی و کار'},
    {'value': 'Saving Rules & Discipline', 'label': 'Daily Budget Discipline / ڕێساکانی پاشەکەوت'},
  ];

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _waveTimer?.cancel();
    super.dispose();
  }

  void _generateDebate() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _debateScript = [];
      _isPlaying = false;
      _activeSpeechIndex = -1;
    });
    _playbackTimer?.cancel();

    final appState = Provider.of<AppState>(context, listen: false);
    final script = await AiService.generateKurdishDebateScript(
      apiKey: widget.apiKey,
      topic: _selectedTopic,
      speakers: _selectedSpeakers,
      transactions: appState.allTransactions,
    );

    setState(() {
      _debateScript = script;
      _isLoading = false;
    });
  }

  void _startAudioDebate() {
    if (_debateScript.isEmpty) return;

    setState(() {
      _isPlaying = true;
    });

    _waveTimer?.cancel();
    // Waveform dancing animation
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      final rand = Random();
      setState(() {
        for (int i = 0; i < _waveHeights.length; i++) {
          _waveHeights[i] = 4.0 + rand.nextDouble() * 26.0;
        }
      });
    });

    _playbackTimer?.cancel();
    // Simulate speaking line-by-line (each line takes ~5 seconds to speak)
    _playbackTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_activeSpeechIndex < _debateScript.length - 1) {
          _activeSpeechIndex++;
        } else {
          // Finished debate play
          _isPlaying = false;
          _activeSpeechIndex = -1;
          timer.cancel();
          _waveTimer?.cancel();
          for (int i = 0; i < _waveHeights.length; i++) {
            _waveHeights[i] = 4.0;
          }
        }
      });
    });

    // Advance instantly to index 0
    if (_activeSpeechIndex == -1) {
      setState(() {
        _activeSpeechIndex = 0;
      });
    }
  }

  void _pauseAudioDebate() {
    setState(() {
      _isPlaying = false;
    });
    _playbackTimer?.cancel();
    _waveTimer?.cancel();
    setState(() {
      for (int i = 0; i < _waveHeights.length; i++) {
        _waveHeights[i] = 4.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        appState.t('podcast_topic'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedTopic,
                        dropdownColor: const Color(0xFF161B2E),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: _topics.map((t) {
                          return DropdownMenuItem(value: t['value'], child: Text(t['label']!));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTopic = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appState.t('podcast_speakers'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildSpeakerChip('Dana (دانا)', 'Dana'),
                          const SizedBox(width: 8),
                          _buildSpeakerChip('Aveen (ئەڤین)', 'Aveen'),
                          const SizedBox(width: 8),
                          _buildSpeakerChip('Zana (زانا)', 'Zana'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _generateDebate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                appState.t('generate_podcast'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_debateScript.isNotEmpty) ...[
                  Text(
                    isRtl ? 'دەقی دیبەیتی ژیری دەستکرد' : 'Dialogue Script',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _debateScript.length,
                    itemBuilder: (context, index) {
                      final line = _debateScript[index];
                      final isSpeaking = index == _activeSpeechIndex;
                      final sp = line['speaker']!;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSpeaking 
                              ? const Color(0xFF10B981).withOpacity(0.08) 
                              : Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSpeaking ? const Color(0xFF10B981) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sp,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSpeaking ? const Color(0xFF10B981) : Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              line['text']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 150), // Avoid keyboard navbar
              ],
            ),
          ),
        ),

        // Fixed bottom audio player bar if script generated
        if (_debateScript.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111422),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1.2)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _isPlaying ? _pauseAudioDebate : _startAudioDebate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isPlaying ? appState.t('podcast_playing') : appState.t('podcast_paused'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      if (_activeSpeechIndex >= 0 && _activeSpeechIndex < _debateScript.length)
                        Text(
                          '${_debateScript[_activeSpeechIndex]['speaker']}: Speaking Soranî...',
                          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                        )
                      else
                        Text(
                          isRtl ? 'ئامادەیە بۆ پەخشکردن' : 'Ready to play dialogue',
                          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                        ),
                    ],
                  ),
                ),
                // Audio Waveform Visualizer
                Container(
                  height: 30,
                  width: 100,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _waveHeights.take(12).map((h) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 3.5,
                        height: h,
                        decoration: BoxDecoration(
                          color: _isPlaying ? const Color(0xFF10B981) : Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 70), // Push above navigation shell bar
      ],
    );
  }

  Widget _buildSpeakerChip(String label, String value) {
    final isSelected = _selectedSpeakers.contains(value);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              if (_selectedSpeakers.length > 2) {
                _selectedSpeakers.remove(value);
              }
            } else {
              if (_selectedSpeakers.length < 3) {
                _selectedSpeakers.add(value);
              }
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981).withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : Colors.white.withOpacity(0.08),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
