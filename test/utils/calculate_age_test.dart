import 'package:flutter_test/flutter_test.dart';
import 'package:datingappflutter/utils/calculate_age.dart';

void main() {
  final now = DateTime(2026, 8, 30);

  test('birthday already passed this year', () {
    expect(
      calculateAge('2000-01-15', now: now),
      26,
    );
  });

  test('birthday has not happened yet this year', () {
    expect(
      calculateAge('2000-12-15', now: now),
      25,
    );
  });

  test('birthday is today', () {
    expect(
      calculateAge('2000-08-30', now: now),
      26,
    );
  });

  test('baby born earlier this year', () {
    expect(
      calculateAge('2026-01-01', now: now),
      0,
    );
  });
}