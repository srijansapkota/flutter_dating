String generateStreamId(String prefix, List<String> userIds) {
  final sortedIds = [...userIds]..sort();
  final combined = sortedIds.join('_');

  var hash = 0;

  for (final code in combined.codeUnits) {
    hash = ((hash << 5).toSigned(32) - hash + code).toSigned(32);
  }

  return '${prefix}_${hash.abs().toRadixString(36)}';
}