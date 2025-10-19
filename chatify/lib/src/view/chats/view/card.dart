import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/chat.dart';
import '../../../helpers/extensions.dart';
import '../../chat/view/chat.dart';

class ChatCard extends StatelessWidget {
  final GestureLongPressStartCallback? onLongPressStart;
  final VoidCallback? onTap;
  const ChatCard(this.chat, {super.key, this.builder, this.onLongPressStart, this.onTap});

  final Chat chat;
  final Widget Function(BuildContext context, Chat chat)? builder;

  String formatTime(DateTime time) {
    final dateWithoutTime = DateTime(time.year, time.month, time.day);
    final diff = DateTime.now().difference(dateWithoutTime).inDays;
    return switch (diff) {
      0 => DateFormat('h:mm a').format(time),
      1 => 'Yesterday',
      _ => DateFormat('dd MMM').format(time),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        Get.to(() => MessagesPage(chat: chat));
      },
      onLongPressStart: onLongPressStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 28,
          top: 16,
          bottom: 16,
          end: 16,
        ),
        child: builder != null
            ? builder!(context, chat)
            : Row(
                spacing: 16,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    alignment: Alignment.center,
                    child: _ImageByName(chat: chat),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat.receiver.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat.isLastMessageMine)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Image.asset(
                                  chat.isLastMessageSeen ? 'assets/seen.png' : 'assets/sent.png',
                                  package: 'chatify',
                                  height: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            if (chat.updatedAt != null)
                              Text(
                                formatTime(chat.updatedAt!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                        LastMessageUnseenCount(chat: chat)
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LastMessageUnseenCount extends StatelessWidget {
  const LastMessageUnseenCount({
    super.key,
    required this.chat,
  });

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          if (chat.lastMessage != null)
            Expanded(
              child: Text(
                chat.lastMessage ?? '',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: chat.isLastMessageSeen || chat.isLastMessageMine
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                textDirection: chat.lastMessage?.directionByLanguage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (chat.unseenMessages > 0)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryFixedDim,
              ),
              alignment: Alignment.center,
              child: Text(
                chat.unseenMessages.toString(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            )
        ],
      ),
    );
  }
}

class _ImageByName extends StatelessWidget {
  const _ImageByName({
    required this.chat,
  });

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Text(
      chat.receiver.name.substring(0, 1).toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
    );
  }
}
