import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/blessing_message.dart';

class BlessingMessageState {
  final List<BlessingMessage> entries;
  final int featuredIndex;
  final int revision;

  const BlessingMessageState({
    required this.entries,
    required this.featuredIndex,
    required this.revision,
  });

  BlessingMessage get featured =>
      entries.isNotEmpty ? entries[featuredIndex % entries.length] : _fallback;

  List<BlessingMessage> get recent =>
      entries.length <= 6 ? entries : entries.sublist(0, 6);

  BlessingMessageState copyWith({
    List<BlessingMessage>? entries,
    int? featuredIndex,
    int? revision,
  }) {
    return BlessingMessageState(
      entries: entries ?? this.entries,
      featuredIndex: featuredIndex ?? this.featuredIndex,
      revision: revision ?? this.revision,
    );
  }

  static BlessingMessageState initial() => BlessingMessageState(
    entries: List<BlessingMessage>.unmodifiable(_defaultMessages),
    featuredIndex: 0,
    revision: 0,
  );
}

class BlessingMessageController extends StateNotifier<BlessingMessageState> {
  BlessingMessageController() : super(BlessingMessageState.initial());

  final Random _random = Random();

  void addMessage({
    required String content,
    String? sender,
    String? recipient,
  }) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final entry = BlessingMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: trimmed,
      sender: sender?.trim().isEmpty ?? true ? null : sender?.trim(),
      recipient: recipient?.trim().isEmpty ?? true ? null : recipient?.trim(),
    );
    final updated = [entry, ...state.entries];
    final limited = updated.length <= 12 ? updated : updated.sublist(0, 12);
    state = state.copyWith(
      entries: List<BlessingMessage>.unmodifiable(limited),
      featuredIndex: 0,
      revision: state.revision + 1,
    );
  }

  void setFeatured(String id) {
    final index = state.entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    state = state.copyWith(featuredIndex: index, revision: state.revision + 1);
  }

  void cycleFeatured() {
    if (state.entries.isEmpty) return;
    final nextIndex = (state.featuredIndex + 1) % state.entries.length;
    state = state.copyWith(featuredIndex: nextIndex, revision: state.revision + 1);
  }

  String randomSuggestion({String? recipient}) {
    final target =
        (recipient != null && recipient.trim().isNotEmpty)
            ? recipient.trim()
            : '你';
    final template = _suggestionPool[_random.nextInt(_suggestionPool.length)];
    return template.replaceAll('{recipient}', target);
  }
}

final blessingMessageProvider =
    StateNotifierProvider<BlessingMessageController, BlessingMessageState>(
      (ref) => BlessingMessageController(),
    );

const _fallback = BlessingMessage(
  id: 'fallback',
  content: '愿今晚的每一片雪花都替我拥抱你。',
  sender: 'Aurora Showcase',
  recipient: '你',
);

const _defaultMessages = <BlessingMessage>[
  BlessingMessage(
    id: 'msg-aurora',
    content: '愿你被灯光拥抱，被风雪温柔放过。',
    sender: '橙子',
    recipient: '小雪',
  ),
  BlessingMessage(
    id: 'msg-cookie',
    content: '今晚的肉桂香提前送到，愿所有焦虑被烘焙声掩盖。',
    sender: '面包星球',
    recipient: '熬夜的你',
  ),
  BlessingMessage(
    id: 'msg-fox',
    content: '雪狐正带着新的勇气向你奔来，接住它然后笑吧。',
    sender: '北极邮局',
  ),
  BlessingMessage(
    id: 'msg-firefly',
    content: '如果今天过得不顺，就把烦恼交给极光，明早醒来只剩轻盈。',
    sender: '灯火',
  ),
];

const _suggestionPool = <String>[
  '{recipient}，今晚的极光替我守夜，你负责好好睡。',
  '愿{recipient}所有的加班都换成热可可和长长的拥抱。',
  '{recipient}记得抬头，流星正排队听你的愿望。',
  '把不安写给北极邮局吧，{recipient}只需要等雪花回答。',
  '如果心里下雨，就来我这里借一场落雪吧，{recipient}。',
  '{recipient}，礼物不是盒子，是我们在平安夜互相惦记。',
];
