import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/core/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('formatTime', () {
      test('formats midnight correctly', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 0, 0));
        expect(time, '12:00 AM');
      });

      test('formats noon correctly', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 12, 0));
        expect(time, '12:00 PM');
      });

      test('formats morning hour correctly', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 9, 30));
        expect(time, '09:30 AM');
      });

      test('formats afternoon hour correctly', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 14, 5));
        expect(time, '02:05 PM');
      });

      test('formats late night hour correctly', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 23, 59));
        expect(time, '11:59 PM');
      });

      test('pads single-digit minutes', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 8, 3));
        expect(time, '08:03 AM');
      });

      test('pads single-digit hours in 12-hour format', () {
        final time = AppDateUtils.formatTime(DateTime(2026, 5, 8, 1, 15));
        expect(time, '01:15 AM');
      });
    });

    group('formatDate', () {
      test('formats a known date correctly', () {
        final date = AppDateUtils.formatDate(DateTime(2026, 5, 8));
        expect(date, 'Fri 8 May 2026');
      });

      test('formats first day of year correctly', () {
        final date = AppDateUtils.formatDate(DateTime(2026, 1, 1));
        expect(date, 'Thu 1 Jan 2026');
      });

      test('formats end of year correctly', () {
        final date = AppDateUtils.formatDate(DateTime(2026, 12, 31));
        expect(date, 'Thu 31 Dec 2026');
      });

      test('uses abbreviated day and month names', () {
        final date = AppDateUtils.formatDate(DateTime(2026, 3, 15));
        expect(date, contains('Sun'));
        expect(date, contains('Mar'));
        expect(date, contains('2026'));
      });
    });
  });
}
