// ignore_for_file: public_member_api_docs, sort_constructors_first
class Hiccup {
  final DateTime startTimestamp;
  final DateTime? endTimestamp;
  final int missedPings;

  Hiccup({
    required this.startTimestamp,
    required this.endTimestamp,
    required this.missedPings,
  });

  Hiccup withMissedPing() {
    return copyWith(missedPings: missedPings + 1);
  }

  Hiccup copyWith({
    DateTime? startTimestamp,
    DateTime? endTimestamp,
    int? missedPings,
  }) {
    return Hiccup(
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      missedPings: missedPings ?? this.missedPings,
    );
  }
}
