import 'package:flutter/material.dart';

import '../data_models.dart';

class SwipeableCard extends StatelessWidget {
  final WordCard card;
  final bool isAnswerVisible;
  final VoidCallback onTap;
  final Function(bool isRight) onSwiped;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.isAnswerVisible,
    required this.onTap,
    required this.onSwiped,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: Transform.rotate(
        angle: 0.1,
        child: Material(
          color: Colors.transparent,
          child: StaticCard(card: card, isVisible: isAnswerVisible),
        ),
      ),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        if (details.offset.dx > 100) {
          onSwiped(true);
        } else if (details.offset.dx < -100) {
          onSwiped(false);
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: StaticCard(card: card, isVisible: isAnswerVisible),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              card.category,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const Spacer(),
          Text(
            card.text,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!isVisible)
            Text("タップしてめくる", style: TextStyle(color: Colors.grey[400]))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("← 知らない", style: TextStyle(color: Colors.red[300])),
                Text("知ってる →", style: TextStyle(color: Colors.green[300])),
              ],
            ),
        ],
      ),
    );
  }
}
