import 'package:flutter/material.dart';

import '../models/word.dart';

class SwipeableCard extends StatefulWidget {
  final WordCard card;
  final bool isAnswerVisible;
  final Color? answerColor; // テキストの色を受け取るパラメータ
  final VoidCallback onTap;
  final void Function(bool) onSwiped;
  // 親（画面側）にドラッグ状態を伝えてヘッダーのハイライトを更新するためのコールバック
  final void Function(Offset)? onDragUpdate;
  final VoidCallback? onDragEnd;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.isAnswerVisible,
    this.answerColor,
    required this.onTap,
    required this.onSwiped,
    this.onDragUpdate,
    this.onDragEnd,
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
    if (widget.onDragUpdate != null) widget.onDragUpdate!(_dragOffset);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
    if (widget.onDragUpdate != null) widget.onDragUpdate!(_dragOffset);
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.onDragEnd != null) widget.onDragEnd!();

    final screenSize = MediaQuery.of(context).size;
    if (_dragOffset.dx > screenSize.width * 0.3) {
      widget.onSwiped(true);
    } else if (_dragOffset.dx < -screenSize.width * 0.3) {
      widget.onSwiped(false);
    } else {
      // 閾値に満たない場合は元に戻すアニメーション
      _animation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ),
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
    final screenSize = MediaQuery.of(context).size;

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

          // ドラッグ量に応じて枠線の色を変化させる
          Color borderColor = Colors.transparent;
          if (offset.dx < -50) {
            borderColor = const Color(
              0xFFD97061,
            ).withOpacity(0.5); // _dangerColor
          } else if (offset.dx > 50) {
            borderColor = const Color(
              0xFF8BA094,
            ).withOpacity(0.5); // _primaryColor
          }

          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: offset.dx / screenSize.width * 0.5,
              child: StaticCard(
                card: widget.card,
                isVisible: widget.isAnswerVisible,
                borderColor: borderColor,
                answerColor: widget.answerColor, // ここでStaticCardに色を渡す
              ),
            ),
          );
        },
      ),
    );
  }
}

class StaticCard extends StatelessWidget {
  final WordCard card;
  final bool isVisible;
  final Color borderColor;
  final Color? answerColor;

  const StaticCard({
    super.key,
    required this.card,
    required this.isVisible,
    this.borderColor = Colors.transparent,
    this.answerColor,
  });

  @override
  Widget build(BuildContext context) {
    const Color dangerColor = Color(0xFFD97061);
    const Color bgColor = Color(0xFFF4F5F6);
    const Color textColorDark = Color(0xFF2C3E50);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 英単語
          Text(
            card.text, // WordCardモデルのプロパティ
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColorDark,
            ),
          ),
          const SizedBox(height: 16),

          // 品詞チップ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              card.partOfSpeech, // WordCardモデルのプロパティ
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),

          // 音声アイコン
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade50,
            ),
            child: const Icon(Icons.volume_up, color: Colors.black45, size: 36),
          ),
          const SizedBox(height: 40),

          // 答え または ヒント
          if (isVisible) ...[
            Text(
              card.meaning, // WordCardモデルのプロパティ
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: answerColor ?? dangerColor, // 渡された色があればそれを適用
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.compare_arrows, color: Colors.black26, size: 20),
                SizedBox(width: 8),
                Text('左右にスワイプ', style: TextStyle(color: Colors.black38)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
