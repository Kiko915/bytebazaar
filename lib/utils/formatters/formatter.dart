import 'package:intl/intl.dart';

class BFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  static String formatCurrency(double amount, {String currency = 'USD'}) {
    switch (currency) {
      case 'PHP':
        return NumberFormat.currency(locale: 'en_PH', symbol: '₱').format(amount);
      default:
        return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
    }
  }

  static String formatPhoneNumber(String phoneNumber, {String format = 'US'}) {
    // Remove any non-digit characters
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    switch (format) {
      case 'PH':
        if (digitsOnly.length == 10) {
          // Convert 9XXXXXXXXX to 09XX XXX XXXX
          return '0${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        } else if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
          // Format 09XXXXXXXXX to 09XX XXX XXXX
          return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
        } else if (digitsOnly.length == 12 && digitsOnly.startsWith('63')) {
          // Format 639XXXXXXXXX to +63 9XX XXX XXXX
          return '+${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8)}';
        }
        return phoneNumber;
        
      default:
        // US format
        if (digitsOnly.length == 10) {
          return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        } else if (digitsOnly.length == 11) {
          return '(${digitsOnly.substring(0, 4)}) ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
        }
        return phoneNumber;
    }
  }

  static String internationalFormatPhoneNumber(String phoneNumber) {
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    String countryCode = '+${digitsOnly.substring(0, 2)}';
    digitsOnly = digitsOnly.substring(2);

    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode) ');

    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = 2;
      if (i == 0 && countryCode == '+1') {
        groupLength = 3;
      }
      int end = i + groupLength;
      formattedNumber.write(digitsOnly.substring(i, end));
      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }
      i = end;
    }
    return formattedNumber.toString();
  }

  /// Format price with optional discount
  static String formatPrice(double price, {double? discountPercentage}) {
    if (discountPercentage != null && discountPercentage > 0) {
      final discountedPrice = price * (1 - discountPercentage / 100);
      return '${formatCurrency(discountedPrice)} (${formatPercentage(discountPercentage)} OFF)';
    }
    return formatCurrency(price);
  }

  /// Format percentage (e.g., for discounts, ratings)
  static String formatPercentage(double percentage) {
    return '${percentage.round()}%';
  }

  /// Format file size in bytes to human readable format
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[i]}';
  }

  /// Format large numbers in a readable way (e.g., 1.2k, 1.5M)
  static String formatCompactNumber(num number) {
    return NumberFormat.compact().format(number);
  }

  /// Format email address by obscuring part of it for privacy
  static String formatEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    return '${username[0]}${username[1]}***@$domain';
  }

  /// Format a DateTime to a human-readable "time ago" string
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
