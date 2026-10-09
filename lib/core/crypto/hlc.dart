import 'dart:math';

/// Hybrid Logical Clock (HLC) Implementation for Pindea
/// Combines physical wall-clock time with a logical counter and node/device identifier
/// to guarantee causally ordered timestamps across distributed offline devices.
class HLC implements Comparable<HLC> {
  final int millis;
  final int counter;
  final String nodeId;

  const HLC({
    required this.millis,
    required this.counter,
    required this.nodeId,
  });

  /// Generate a new HLC initialized to current local time
  factory HLC.now(String nodeId) {
    return HLC(
      millis: DateTime.now().millisecondsSinceEpoch,
      counter: 0,
      nodeId: nodeId,
    );
  }

  /// Create a new local HLC ticking forward from the last known state
  HLC tick([int? wallClock]) {
    final now = wallClock ?? DateTime.now().millisecondsSinceEpoch;
    if (now > millis) {
      return HLC(millis: now, counter: 0, nodeId: nodeId);
    } else {
      return HLC(millis: millis, counter: counter + 1, nodeId: nodeId);
    }
  }

  /// Receive a remote HLC from a peer and update the clock (causal merge)
  HLC receive(HLC remote, [int? wallClock]) {
    final now = wallClock ?? DateTime.now().millisecondsSinceEpoch;
    final maxMillis = max(now, max(millis, remote.millis));

    int newCounter;
    if (maxMillis == millis && maxMillis == remote.millis) {
      newCounter = max(counter, remote.counter) + 1;
    } else if (maxMillis == millis) {
      newCounter = counter + 1;
    } else if (maxMillis == remote.millis) {
      newCounter = remote.counter + 1;
    } else {
      newCounter = 0;
    }

    return HLC(
      millis: maxMillis,
      counter: newCounter,
      nodeId: nodeId,
    );
  }

  /// Standard serializable format: `millis:counter:nodeId`
  String pack() {
    return '$millis:$counter:$nodeId';
  }

  /// Parse from string representation
  static HLC unpack(String str) {
    final parts = str.split(':');
    if (parts.length < 3) {
      throw FormatException('Invalid HLC string: $str');
    }
    return HLC(
      millis: int.parse(parts[0]),
      counter: int.parse(parts[1]),
      nodeId: parts.sublist(2).join(':'),
    );
  }

  @override
  int compareTo(HLC other) {
    if (millis != other.millis) {
      return millis.compareTo(other.millis);
    }
    if (counter != other.counter) {
      return counter.compareTo(other.counter);
    }
    return nodeId.compareTo(other.nodeId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HLC &&
          runtimeType == other.runtimeType &&
          millis == other.millis &&
          counter == other.counter &&
          nodeId == other.nodeId;

  @override
  int get hashCode => millis.hashCode ^ counter.hashCode ^ nodeId.hashCode;

  @override
  String toString() => pack();
}
