String formatTime(String timestamp, {DateTime? now}) {
  final dateTime = DateTime.parse(timestamp);
  final currentTime = now ?? DateTime.now();
  final difference = currentTime.difference(dateTime);

  if (difference.inMinutes <= 1) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}h';
  }

  if (difference.inHours < 48) {
    return 'Yesterday';
  }

  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');

  return '$month/$day/${dateTime.year}';
}