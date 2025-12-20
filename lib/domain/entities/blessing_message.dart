class BlessingMessage {
  final String id;
  final String content;
  final String? sender;
  final String? recipient;

  const BlessingMessage({
    required this.id,
    required this.content,
    this.sender,
    this.recipient,
  });

  String get headline =>
      (recipient != null && recipient!.trim().isNotEmpty)
          ? '致 ${recipient!.trim()}'
          : '致今晚的你';

  String get signatureLine =>
      (sender != null && sender!.trim().isNotEmpty)
          ? '—— ${sender!.trim()}'
          : '—— 来自极光舞台';

  String get preview {
    final trimmed = content.trim();
    if (trimmed.length <= 14) return trimmed;
    return '${trimmed.substring(0, 14)}…';
  }

  BlessingMessage copyWith({
    String? id,
    String? content,
    String? sender,
    String? recipient,
  }) {
    return BlessingMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
    );
  }
}
