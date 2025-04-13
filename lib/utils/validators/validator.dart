class BValidator {
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    // Check for minimum length
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    // Check for maximum length
    if (value.length > 100) {
      return 'Name must not exceed 50 characters';
    }

    // Check for valid characters using regex
    final RegExp nameRegExp = RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$");
    if (!nameRegExp.hasMatch(value)) {
      return 'Name can only contain letters, spaces, and hyphens';
    }

    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation (RFC 5322 Official Standard)
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Allow for international format with optional country code
    // Matches formats like: +1234567890, 1234567890, (123) 456-7890
    final RegExp phoneRegExp = RegExp(
      r'^\+?([0-9]{1,4})?[-. ]?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$'
    );

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format';
    }

    // Remove all non-digit characters for length check
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Validate length (including country code)
    if (cleanNumber.length < 10 || cleanNumber.length > 15) {
      return 'Invalid phone number length';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Check minimum length
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    // Convert string to double
    final double? price = double.tryParse(value);
    if (price == null) {
      return 'Invalid price format';
    }

    // Check if price is positive
    if (price <= 0) {
      return 'Price must be greater than zero';
    }

    // Check for reasonable maximum price (adjust as needed)
    if (price > 999999.99) {
      return 'Price exceeds maximum allowed';
    }

    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    // Convert string to integer
    final int? quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Invalid quantity format';
    }

    // Check if quantity is positive
    if (quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    // Check for reasonable maximum quantity (adjust as needed)
    if (quantity > 9999) {
      return 'Quantity exceeds maximum allowed';
    }

    return null;
  }

  // URL validation
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    // Comprehensive URL validation regex that handles modern TLDs
    final RegExp urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,})([\/\w \.-]*)*\/?$',
      caseSensitive: false
    );

    if (!urlRegExp.hasMatch(value)) {
      return 'Invalid URL format';
    }

    return null;
  }

  // Postal code validation
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }

    // Remove whitespace
    final cleanPostalCode = value.trim();

    // Basic postal code validation (customize based on your country format)
    if (cleanPostalCode.length < 4 || cleanPostalCode.length > 10) {
      return 'Invalid postal code length';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 5) {
      return 'Address is too short';
    }

    if (value.length > 100) {
      return 'Address is too long';
    }

    return null;
  }

  // Card number validation (using Luhn algorithm)
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove any non-digit characters
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Check length (most card numbers are between 13 and 19 digits)
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Invalid card number length';
    }

    // Implement Luhn algorithm
    int sum = 0;
    bool isEven = false;
    
    // Loop through values starting from the rightmost digit
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    if (sum % 10 != 0) {
      return 'Invalid card number';
    }

    return null;
  }

  // Card expiry date validation
  static String? validateCardExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    // Expected format: MM/YY
    final RegExp expiryDateRegExp = RegExp(r'^\d{2}/\d{2}$');
    if (!expiryDateRegExp.hasMatch(value)) {
      return 'Invalid expiry date format (Use MM/YY)';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return 'Invalid expiry date';
    }

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    // Convert 2-digit year to 4-digit year
    final fourDigitYear = 2000 + year;
    final now = DateTime.now();
    
    // Create dates for start and end of the month
    final cardDate = DateTime(fourDigitYear, month);
    final cardEndDate = DateTime(fourDigitYear, month + 1, 0); // Last day of the month
    
    // Card must not be expired and must not be more than 10 years in the future
    if (cardEndDate.isBefore(now)) {
      return 'Card has expired';
    }
    
    final maxFutureDate = DateTime.now().add(const Duration(days: 3650)); // 10 years
    if (cardDate.isAfter(maxFutureDate)) {
      return 'Invalid expiry date - too far in the future';
    }

    return null;
  }

  // CVV validation
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    // Remove any non-digit characters
    final cleanCVV = value.replaceAll(RegExp(r'[^0-9]'), '');

    // CVV is typically 3 or 4 digits
    if (cleanCVV.length < 3 || cleanCVV.length > 4) {
      return 'Invalid CVV length';
    }

    return null;
  }

  // Search term validation
  static String? validateSearchTerm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Search term is required';
    }

    if (value.length < 2) {
      return 'Search term must be at least 2 characters long';
    }

    // Remove special characters except spaces and alphanumeric
    final cleanSearch = value.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
    if (cleanSearch.isEmpty) {
      return 'Invalid search term';
    }

    return null;
  }

  // Coupon code validation
  static String? validateCouponCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Coupon code is required';
    }

    // Typical coupon code format (alphanumeric, 5-10 characters)
    final RegExp couponRegExp = RegExp(r'^[A-Z0-9]{5,10}$');
    if (!couponRegExp.hasMatch(value.toUpperCase())) {
      return 'Invalid coupon code format';
    }

    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    // Check length (3-20 characters)
    if (value.length < 3 || value.length > 20) {
      return 'Username must be between 3 and 20 characters';
    }

    // Username format: letters, numbers, underscores, dots, hyphens
    // Must start with a letter, no consecutive dots/underscores/hyphens
    final RegExp usernameRegExp = RegExp(
      r'^[a-zA-Z][a-zA-Z0-9]*([._-]?[a-zA-Z0-9]+)*$'
    );

    if (!usernameRegExp.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and single dots/underscores/hyphens';
    }

    return null;
  }

  // Product description validation
  static String? validateProductDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product description is required';
    }

    // Minimum length check (20 characters for meaningful description)
    if (value.length < 20) {
      return 'Description must be at least 20 characters long';
    }

    // Maximum length check (1000 characters)
    if (value.length > 1000) {
      return 'Description must not exceed 1000 characters';
    }

    // Check for at least 3 words
    final wordCount = value.trim().split(RegExp(r'\s+')).length;
    if (wordCount < 3) {
      return 'Description must contain at least 3 words';
    }

    // Check for HTML injection
    if (value.contains(RegExp(r'<[^>]*>'))) {
      return 'HTML tags are not allowed in description';
    }

    return null;
  }

  // SKU validation
  static String? validateSKU(String? value) {
    if (value == null || value.isEmpty) {
      return 'SKU is required';
    }

    // Remove whitespace
    final cleanSKU = value.trim();

    // Check length (typically 8-12 characters)
    if (cleanSKU.length < 4 || cleanSKU.length > 32) {
      return 'SKU must be between 4 and 32 characters';
    }

    // SKU format: Alphanumeric with optional hyphens
    // Example formats: ABC-123, ABC123, A1B2C3
    final RegExp skuRegExp = RegExp(r'^[A-Z0-9]+(-[A-Z0-9]+)*$');
    if (!skuRegExp.hasMatch(cleanSKU.toUpperCase())) {
      return 'Invalid SKU format';
    }

    return null;
  }

  // Product review validation
  static String? validateProductReview(String? value, {double? rating}) {
    if (value == null || value.isEmpty) {
      return 'Review text is required';
    }

    // Check minimum length for meaningful review
    if (value.length < 10) {
      return 'Review must be at least 10 characters long';
    }

    // Maximum length check
    if (value.length > 500) {
      return 'Review must not exceed 500 characters';
    }

    // Check for at least 2 words
    final wordCount = value.trim().split(RegExp(r'\s+')).length;
    if (wordCount < 2) {
      return 'Review must contain at least 2 words';
    }

    // Validate rating if provided
    if (rating != null) {
      if (rating < 1 || rating > 5) {
        return 'Rating must be between 1 and 5';
      }
    }

    // Check for HTML injection
    if (value.contains(RegExp(r'<[^>]*>'))) {
      return 'HTML tags are not allowed in review';
    }

    return null;
  }

  // Date validation (general purpose)
  static String? validateDate(String? value, {DateTime? minDate, DateTime? maxDate}) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    // Expected format: YYYY-MM-DD
    final RegExp dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegExp.hasMatch(value)) {
      return 'Invalid date format (Use YYYY-MM-DD)';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      // Check if date is in the past if minDate is not provided
      if (minDate == null && date.isBefore(now)) {
        return 'Date cannot be in the past';
      }

      // Check minimum date if provided
      if (minDate != null && date.isBefore(minDate)) {
        return 'Date cannot be before ${minDate.toString().split(' ')[0]}';
      }

      // Check maximum date if provided
      if (maxDate != null && date.isAfter(maxDate)) {
        return 'Date cannot be after ${maxDate.toString().split(' ')[0]}';
      }

      return null;
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Tax ID / VAT number validation
  static String? validateTaxID(String? value, {String? country}) {
    if (value == null || value.isEmpty) {
      return 'Tax ID is required';
    }

    // Remove whitespace and convert to uppercase
    final cleanTaxID = value.trim().toUpperCase();

    // Basic length check
    if (cleanTaxID.length < 8 || cleanTaxID.length > 20) {
      return 'Invalid Tax ID length';
    }

    // Country-specific validation patterns
    Map<String, RegExp> countryPatterns = {
      'US': RegExp(r'^\d{2}-\d{7}$'), // EIN format
      'GB': RegExp(r'^GB\d{9}$'), // UK VAT format
      'EU': RegExp(r'^[A-Z]{2}\d{8,12}$'), // General EU VAT format
    };

    // If country is specified, use country-specific validation
    if (country != null && countryPatterns.containsKey(country)) {
      if (!countryPatterns[country]!.hasMatch(cleanTaxID)) {
        return 'Invalid Tax ID format for $country';
      }
    } else {
      // Generic format check: alphanumeric with optional hyphens
      final RegExp genericTaxIDRegExp = RegExp(r'^[A-Z0-9]+(-[A-Z0-9]+)*$');
      if (!genericTaxIDRegExp.hasMatch(cleanTaxID)) {
        return 'Invalid Tax ID format';
      }
    }

    return null;
  }
}
