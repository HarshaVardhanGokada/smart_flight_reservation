class CountryCodeItem {
  final String name;
  final String dialCode;
  final String code;
  final String flag;

  const CountryCodeItem({
    required this.name,
    required this.dialCode,
    required this.code,
    required this.flag,
  });

  String get displayName => '$flag $name ($dialCode)';
}

class CountryCodes {
  CountryCodes._();

  static const CountryCodeItem defaultCountry = CountryCodeItem(
    name: 'India',
    dialCode: '+91',
    code: 'IN',
    flag: '🇮🇳',
  );

  static const List<CountryCodeItem> allCountries = [
    CountryCodeItem(name: 'India', dialCode: '+91', code: 'IN', flag: '🇮🇳'),
    CountryCodeItem(name: 'United States', dialCode: '+1', code: 'US', flag: '🇺🇸'),
    CountryCodeItem(name: 'United Kingdom', dialCode: '+44', code: 'GB', flag: '🇬🇧'),
    CountryCodeItem(name: 'United Arab Emirates', dialCode: '+971', code: 'AE', flag: '🇦🇪'),
    CountryCodeItem(name: 'Singapore', dialCode: '+65', code: 'SG', flag: '🇸🇬'),
    CountryCodeItem(name: 'Australia', dialCode: '+61', code: 'AU', flag: '🇦🇺'),
    CountryCodeItem(name: 'Canada', dialCode: '+1', code: 'CA', flag: '🇨🇦'),
    CountryCodeItem(name: 'Germany', dialCode: '+49', code: 'DE', flag: '🇩🇪'),
    CountryCodeItem(name: 'France', dialCode: '+33', code: 'FR', flag: '🇫🇷'),
    CountryCodeItem(name: 'Saudi Arabia', dialCode: '+966', code: 'SA', flag: '🇸🇦'),
    CountryCodeItem(name: 'Qatar', dialCode: '+974', code: 'QA', flag: '🇶🇦'),
    CountryCodeItem(name: 'Malaysia', dialCode: '+60', code: 'MY', flag: '🇲🇾'),
    CountryCodeItem(name: 'Japan', dialCode: '+81', code: 'JP', flag: '🇯🇵'),
    CountryCodeItem(name: 'Sri Lanka', dialCode: '+94', code: 'LK', flag: '🇱🇰'),
    CountryCodeItem(name: 'Bangladesh', dialCode: '+880', code: 'BD', flag: '🇧🇩'),
    CountryCodeItem(name: 'Nepal', dialCode: '+977', code: 'NP', flag: '🇳🇵'),
    CountryCodeItem(name: 'Oman', dialCode: '+968', code: 'OM', flag: '🇴🇲'),
    CountryCodeItem(name: 'Kuwait', dialCode: '+965', code: 'KW', flag: '🇰🇼'),
    CountryCodeItem(name: 'Bahrain', dialCode: '+973', code: 'BH', flag: '🇧🇭'),
    CountryCodeItem(name: 'Thailand', dialCode: '+66', code: 'TH', flag: '🇹🇭'),
    CountryCodeItem(name: 'Indonesia', dialCode: '+62', code: 'ID', flag: '🇮🇩'),
    CountryCodeItem(name: 'South Africa', dialCode: '+27', code: 'ZA', flag: '🇿🇦'),
    CountryCodeItem(name: 'New Zealand', dialCode: '+64', code: 'NZ', flag: '🇳🇿'),
  ];

  /// Formats customer entered number into strict E.164 format (+countryCode + number)
  /// Removes any spaces, hyphens, parentheses, and leading zeros.
  static String formatE164({
    required CountryCodeItem country,
    required String rawNumber,
  }) {
    final trimmed = rawNumber.trim();
    var digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');

    if (trimmed.startsWith('+')) {
      return '+$digitsOnly';
    }

    // Strip leading zero if present (common trunk prefix)
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    final dialDigits = country.dialCode.replaceAll('+', '');
    // If the customer explicitly typed dial code prefix followed by the full number
    if (digitsOnly.length > 10 && digitsOnly.startsWith(dialDigits)) {
      return '+$digitsOnly';
    }

    return '${country.dialCode}$digitsOnly';
  }

  /// Validates whether the phone number length is valid for international standards
  static bool isValidPhoneNumber({
    required CountryCodeItem country,
    required String rawNumber,
  }) {
    var digitsOnly = rawNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    // Specific rules for common countries
    if (country.dialCode == '+91') {
      return digitsOnly.length == 10;
    }
    if (country.dialCode == '+1') {
      return digitsOnly.length == 10;
    }

    // International E.164 general validation: 7 to 15 digits
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }
}
