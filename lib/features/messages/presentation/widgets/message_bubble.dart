import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message, required this.isMine, super.key,
    this.showTime = true,
  });

  final Message message;
  final bool isMine;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? AppColors.ink900 : AppColors.ink50;
    final fg = isMine ? AppColors.white : AppColors.ink900;
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMine ? 16 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: bg, borderRadius: radius),
                child: Text(
                  message.body,
                  style: TextStyle(color: fg, fontSize: 15, height: 1.35),
                ),
              ),
              if (showTime) ...[
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    Formatters.time(message.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.ink400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
