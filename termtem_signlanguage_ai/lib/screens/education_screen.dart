import 'package:flutter/material.dart';
import 'practice_modal.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final List<Map<String, String>> words = [
    {"word": "Hello",   "category": "GREETINGS"},
    {"word": "Thanks",  "category": "MANNERS"},
    {"word": "Love",    "category": "EMOTION"},
    {"word": "Help",    "category": "ASSISTANCE"},
    {"word": "Sorry",   "category": "MANNERS"},
    {"word": "Eat",     "category": "DAILY LIFE"},
    {"word": "Water",   "category": "DAILY LIFE"},
    {"word": "Family",  "category": "RELATIONSHIPS"},
  ];

  String query = '';
  int _challengeProgress = 2;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchBarKey = GlobalKey();
  bool _showStickySearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final ctx = _searchBarKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final topInViewport = box.localToGlobal(Offset.zero).dy;
    final isHidden = topInViewport < -(box.size.height);
    if (isHidden != _showStickySearch) {
      setState(() => _showStickySearch = isHidden);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _openPractice(String word, String category) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => PracticeModal(word: word, category: category),
    );
  }

  void _openChallenge() {
    if (_challengeProgress >= 5) return;
    final shuffled = List.of(words)..shuffle();
    final pick = shuffled.first;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => PracticeModal(
        word: pick['word']!,
        category: pick['category']!,
        isChallengeMode: true,
        challengeProgress: _challengeProgress,
        onWordDone: () =>
            setState(() => _challengeProgress = (_challengeProgress + 1).clamp(0, 5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = words
        .where((w) => w["word"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Stack(
      children: [
        // ── Main scroll ──────────────────────────────────────────────────────
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Education Library',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 24),
                    _buildSearchBar(key: _searchBarKey),
                    const SizedBox(height: 24),
                    _buildFilterChips(),
                    const SizedBox(height: 28),
                    _buildDailyChallengeCard(),
                    const SizedBox(height: 28),
                    const Text(
                      'All Signs',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GestureDetector(
                    onTap: () => _openPractice(
                        filtered[index]['word']!, filtered[index]['category']!),
                    child: _buildWordCard(filtered[index]),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),

        // ── Sticky search bar ────────────────────────────────────────────────
        AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          offset: _showStickySearch ? Offset.zero : const Offset(0, -1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _showStickySearch ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_showStickySearch,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildSearchBar(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar({Key? key}) {
    return TextField(
      key: key,
      onChanged: (v) => setState(() => query = v),
      decoration: InputDecoration(
        hintText: "Search sign language...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _HoverChip(label: "Daily",   isSelected: true),
        _HoverChip(label: "Animals", isSelected: false),
        _HoverChip(label: "Food",    isSelected: false),
        _HoverChip(label: "Travel",  isSelected: false),
      ]),
    );
  }

  // ── Daily Challenge card ───────────────────────────────────────────────────
  Widget _buildDailyChallengeCard() {
    final done = _challengeProgress >= 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Challenge',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PRACTICE MODE',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Master 5 New Words',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  5,
                  (i) => Container(
                    width: 28,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: i < _challengeProgress
                          ? Colors.white
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                done
                    ? '🎉 Completed today!'
                    : '$_challengeProgress / 5 words done today',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 20),
              _HoverStartButton(
                done: done,
                onTap: done ? null : _openChallenge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Word card ──────────────────────────────────────────────────────────────
  Widget _buildWordCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20)),
              child: const Center(
                child: Icon(Icons.play_circle_fill, size: 40, color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['category']!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  item['word']!,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hover filter chip ──────────────────────────────────────────────────────────
class _HoverChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  const _HoverChip({required this.label, required this.isSelected});

  @override
  State<_HoverChip> createState() => _HoverChipState();
}

class _HoverChipState extends State<_HoverChip> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;

    final Color bg = widget.isSelected
        ? (active ? Colors.grey[800]! : Colors.black)
        : (active ? Colors.grey[300]! : const Color(0xFFEEEEEE));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hover Start Learning button ────────────────────────────────────────────────
class _HoverStartButton extends StatefulWidget {
  final bool done;
  final VoidCallback? onTap;
  const _HoverStartButton({required this.done, required this.onTap});

  @override
  State<_HoverStartButton> createState() => _HoverStartButtonState();
}

class _HoverStartButtonState extends State<_HoverStartButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = (_hovered || _pressed) && !widget.done;

    final Color bg = widget.done
        ? Colors.white24
        : active
            ? Colors.grey[200]!
            : Colors.white;

    final Color textColor = widget.done
        ? Colors.white54
        : active
            ? Colors.black87
            : Colors.black;

    return MouseRegion(
      cursor: widget.done
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.done ? 'Come back tomorrow!' : 'Start Learning →',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}