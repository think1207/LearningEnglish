import 'package:flutter/material.dart';

import '../models/word.dart';

class SwipeableCard extends StatefulWidget {
  final WordCard card;
  final bool isAnswerVisible;
  final VoidCallback onTap;
  final void Function(bool) onSwiped;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.isAnswerVisible,
    required this.onTap,
    required this.onSwiped,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragOffset = Offset.zero;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
      // Trigger swipe completion
      widget.onSwiped(_dragOffset.dx > 0);
    } else {
      // Animate back to center if not a valid swipe
      _animation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.reset();
      _animationController.forward().then((_) {
        setState(() {
          _dragOffset = Offset.zero;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final offset = _animationController.isAnimating
              ? _animation.value
              : _dragOffset;
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: offset.dx / (MediaQuery.of(context).size.width / 2) * 0.4,
              child: child,
            ),
          );
        },
        child: StaticCard(card: widget.card, isVisible: widget.isAnswerVisible),
      ),
    );
  }
}

class StaticCard extends StatelessWidget {
  final WordCard card;
  final bool isVisible;

  const StaticCard({super.key, required this.card, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 480,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  card.category,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              Row(
                children: List.generate(
                  3,
                  (index) => Icon(
                    index < card.proficiency ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            card.text,
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                const Divider(height: 40),
                Text(
                  card.meaning,
                  style: const TextStyle(fontSize: 24, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!isVisible)
            Text("タップしてめくる", style: TextStyle(color: Colors.grey.shade400))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("← 知らない", style: TextStyle(color: Colors.red.shade300)),
                Text("知ってる →", style: TextStyle(color: Colors.green.shade300)),
              ],
            ),
        ],
      ),
    );
  }
}
