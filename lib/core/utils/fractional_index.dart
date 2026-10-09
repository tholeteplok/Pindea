/// Lexicographical Fractional Indexing implementation for Pindea
/// Generates strings that sort alphabetically to order blocks without precision exhaustion.
/// Guarantees that you can always insert a new item between any two existing items.
class FractionalIndex {
  FractionalIndex._();

  static const String base62 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  static const String midChar = 'V'; // Approx midpoint in base62

  /// Generate the initial starting index for the first block
  static String initialPosition() {
    return 'a0';
  }

  /// Generate an index that sorts strictly between [prev] and [next]
  static String between(String prev, String next) {
    if (prev.compareTo(next) >= 0) {
      throw ArgumentError('prev ("$prev") must be strictly less than next ("$next")');
    }

    final pLen = prev.length;
    final nLen = next.length;
    final maxLen = pLen > nLen ? pLen : nLen;

    final buffer = StringBuffer();

    for (int i = 0; i <= maxLen; i++) {
      final pChar = i < pLen ? prev[i] : '0';
      final nChar = i < nLen ? next[i] : 'z';

      if (pChar == nChar) {
        buffer.write(pChar);
      } else {
        final pIndex = base62.indexOf(pChar);
        final nIndex = base62.indexOf(nChar);

        if (nIndex - pIndex > 1) {
          final midIndex = (pIndex + nIndex) ~/ 2;
          buffer.write(base62[midIndex]);
          return buffer.toString();
        } else {
          buffer.write(pChar);
          // Append midpoint if no character fits between
          if (i == maxLen) {
            buffer.write(midChar);
            return buffer.toString();
          }
        }
      }
    }

    buffer.write(midChar);
    return buffer.toString();
  }

  /// Generate an index strictly before [first]
  static String before(String first) {
    if (first.isEmpty) return 'a0';
    final firstChar = first[0];
    final idx = base62.indexOf(firstChar);
    if (idx > 0) {
      return base62[idx ~/ 2] + first.substring(1);
    }
    return '0$first';
  }

  /// Generate an index strictly after [last]
  static String after(String last) {
    if (last.isEmpty) return 'a0';
    return '${last}V';
  }
}
