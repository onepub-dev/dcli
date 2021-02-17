import 'dart:convert';

RegExp _email = RegExp(
    r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

RegExp _ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
RegExp _ipv6 =
    RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

RegExp _surrogatePairsRegExp = RegExp(r'[\uD800-\uDBFF][\uDC00-\uDFFF]');

RegExp _alpha = RegExp(r'^[a-zA-Z]+$');
RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
RegExp _numeric = RegExp(r'^-?[0-9]+$');
RegExp _int = RegExp(r'^(?:-?(?:0|[1-9][0-9]*))$');
RegExp _float =
    RegExp(r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$');
RegExp _hexadecimal = RegExp(r'^[0-9a-fA-F]+$');
RegExp _hexcolor = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

RegExp _base64 = RegExp(
    r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

RegExp _creditCard = RegExp(
    r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$');

RegExp _isbn10Maybe = RegExp(r'^(?:[0-9]{9}X|[0-9]{10})$');
RegExp _isbn13Maybe = RegExp(r'^(?:[0-9]{13})$');

Map<String, RegExp> _uuid = {
  '3': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$'),
  '4': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
  '5': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
  'all':
      RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$')
};

RegExp _multibyte = RegExp(r'[^\x00-\x7F]');
RegExp _ascii = RegExp(r'^[\x00-\x7F]+$');
RegExp _fullWidth =
    RegExp(r'[^\u0020-\u007E\uFF61-\uFF9F\uFFA0-\uFFDC\uFFE8-\uFFEE0-9a-zA-Z]');
RegExp _halfWidth =
    RegExp(r'[\u0020-\u007E\uFF61-\uFF9F\uFFA0-\uFFDC\uFFE8-\uFFEE0-9a-zA-Z]');

/// check if the string matches the comparison
bool equals(String str, dynamic comparison) {
  return str == comparison.toString();
}

/// check if the string contains the seed
bool contains(String str, dynamic seed) {
  return str.contains(seed.toString());
}

/// check if string [str] matches the [pattern].
bool matches(String str, String pattern) {
  final RegExp re = RegExp(pattern);
  return re.hasMatch(str);
}

/// check if the string [str] is an email
bool isEmail(String str) {
  return _email.hasMatch(str.toLowerCase());
}

// /// check if the [possibleUrl] is a URL
// ///
// /// * [protocols] sets the list of allowed protocols
// /// * [requireTld] sets if TLD is required
// /// * [requireProtocol] is a `bool` that sets if protocol is required for validation
// /// * [allowUnderscore] sets if underscores are allowed
// /// * [hostWhitelist] sets the list of allowed hosts
// /// * [hostBlacklist] sets the list of disallowed hosts
// bool isURL(String possibleUrl,
//     {List<String> protocols = const ['http', 'https', 'ftp'],
//     bool requireTld = true,
//     bool requireProtocol = false,
//     bool allowUnderscore = false,
//     List<String> hostWhitelist = const [],
//     List<String> hostBlacklist = const []}) {
//   if (possibleUrl == null ||
//       possibleUrl.length == 0 ||
//       possibleUrl.length > 2083 ||
//       possibleUrl.startsWith('mailto:')) {
//     return false;
//   }

//   String? protocol,
//       user,
//       auth,
//       host,
//       hostname,
//       port,
//       port_str,
//       path,
//       query,
//       hash;

//   // check protocol
//   var urlParts = possibleUrl.split('://');
//   if (urlParts.length > 1) {
//     protocol = shift(urlParts)!;
//     if (!protocols.contains(protocol)) {
//       return false;
//     }
//   } else if (requireProtocol == true) {
//     return false;
//   }

//   // check hash
//   urlParts = possibleUrl.split('#');
//   var tag = shift(urlParts);
//   hash = split.join('#');
//   if (hash != null && hash != "" && RegExp(r'\s').hasMatch(hash)) {
//     return false;
//   }

//   // check query params
//   split = urlParts.split('?');
//   urlParts = shift(split);
//   query = split.join('?');
//   if (query != null && query != "" && RegExp(r'\s').hasMatch(query)) {
//     return false;
//   }

//   // check path
//   split = urlParts.split('/');
//   urlParts = shift(split);
//   path = split.join('/');
//   if (path != null && path != "" && RegExp(r'\s').hasMatch(path)) {
//     return false;
//   }

//   // check auth type urls
//   split = urlParts.split('@');
//   if (split.length > 1) {
//     auth = shift(split);
//     if (auth.indexOf(':') >= 0) {
//       auth = auth.split(':');
//       user = shift(auth);
//       if (!RegExp(r'^\S+$').hasMatch(user)) {
//         return false;
//       }
//       if (!RegExp(r'^\S*$').hasMatch(user)) {
//         return false;
//       }
//     }
//   }

//   // check hostname
//   hostname = split.join('@');
//   split = hostname.split(':');
//   host = shift(split);
//   if (split.length > 0) {
//     port_str = split.join(':');
//     try {
//       port = int.parse(port_str, radix: 10);
//     } catch (e) {
//       return false;
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(port_str) || port <= 0 || port > 65535) {
//       return false;
//     }
//   }

//   if (!isIP(host) &&
//       !isFQDN(host,
//           requireTld: requireTld, allowUnderscores: allowUnderscore) &&
//       host != 'localhost') {
//     return false;
//   }

//   if (hostWhitelist.isNotEmpty && !hostWhitelist.contains(host)) {
//     return false;
//   }

//   if (hostBlacklist.isNotEmpty && hostBlacklist.contains(host)) {
//     return false;
//   }

//   return true;
// }

/// check if the string [str] is IP [version] 4 or 6
///
/// * [version] is a String or an `int`.
bool isIP(String str, [/*<String | int>*/ dynamic version]) {
  final _version = version.toString();
  if (_version == 'null') {
    return isIP(str, 4) || isIP(str, 6);
  } else if (_version == '4') {
    if (!_ipv4Maybe.hasMatch(str)) {
      return false;
    }
    final parts = str.split('.');
    parts.sort((a, b) => int.parse(a) - int.parse(b));
    return int.parse(parts[3]) <= 255;
  }
  return _version == '6' && _ipv6.hasMatch(str);
}

/// check if the string [str] is a fully qualified domain name (e.g. domain.com).
///
/// * [requireTld] sets if TLD is required
/// * [allowUnderscores] sets if underscores are allowed
bool isFQDN(String str,
    {bool requireTld = true, bool allowUnderscores = false}) {
  final parts = str.split('.');
  if (requireTld) {
    final tld = parts.removeLast();
    if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
      return false;
    }
  }

  for (final part in parts) {
    if (allowUnderscores) {
      if (part.contains('__')) {
        return false;
      }
    }
    if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
      return false;
    }
    if (part[0] == '-' ||
        part[part.length - 1] == '-' ||
        part.contains('---')) {
      return false;
    }
  }
  return true;
}

/// check if the string [str] contains only letters (a-zA-Z).
bool isAlpha(String str) {
  return _alpha.hasMatch(str);
}

/// check if the string [str] contains only numbers
bool isNumeric(String str) {
  return _numeric.hasMatch(str);
}

/// check if the string [str] contains only letters and numbers
bool isAlphanumeric(String str) {
  return _alphanumeric.hasMatch(str);
}

/// check if a string [str] is base64 encoded
bool isBase64(String str) {
  return _base64.hasMatch(str);
}

/// check if the string [str] is an integer
bool isInt(String str) {
  return _int.hasMatch(str);
}

/// check if the string [str] is a float
bool isFloat(String str) {
  return _float.hasMatch(str);
}

/// check if the string  [str]is a hexadecimal number
bool isHexadecimal(String str) {
  return _hexadecimal.hasMatch(str);
}

/// check if the string [str] is a hexadecimal color
bool isHexColor(String str) {
  return _hexcolor.hasMatch(str);
}

/// check if the string [str] is lowercase
bool isLowercase(String str) {
  return str == str.toLowerCase();
}

/// check if the string [str] is uppercase
bool isUppercase(String str) {
  return str == str.toUpperCase();
}

/// check if the string [str] is a number that's divisible by another
///
/// [n] is a String or an int.
bool isDivisibleBy(String str, String n) {
  try {
    return double.parse(str) % int.parse(n) == 0;
  } catch (e) {
    return false;
  }
}

/// check if the string [str] is null or empty
bool isNull(String? str) {
  return str == null || str.isEmpty;
}

/// check if the length of the string [str] falls in a range
bool isLength(String str, int min, [int? max]) {
  final List surrogatePairs = _surrogatePairsRegExp.allMatches(str).toList();
  final int len = str.length - surrogatePairs.length;
  return len >= min && (max == null || len <= max);
}

/// check if the string's length (in bytes) falls in a range.
bool isByteLength(String str, int min, [int? max]) {
  return str.length >= min && (max == null || str.length <= max);
}

/// check if the string is a UUID (version 3, 4 or 5).
bool isUUID(String str, [String? version]) {
  String? _version;
  if (version == null) {
    _version = 'all';
  } else {
    _version = version.toString();
  }

  final RegExp? pat = _uuid[_version];
  return pat != null && pat.hasMatch(str.toUpperCase());
}

/// check if the string is a date
bool isDate(String str) {
  try {
    DateTime.parse(str);
    return true;
  } catch (e) {
    return false;
  }
}

/// check if the string is a date that's after the specified date
///
/// If `date` is not passed, it defaults to now.
bool isAfter(String str, [String? date]) {
  DateTime _dt;
  if (date == null) {
    _dt = DateTime.now();
  } else if (isDate(date)) {
    _dt = DateTime.parse(date);
  } else {
    return false;
  }

  DateTime strDate;
  try {
    strDate = DateTime.parse(str);
  } catch (e) {
    return false;
  }

  return strDate.isAfter(_dt);
}

/// check if the string is a date that's before the specified date
///
/// If `date` is not passed, it defaults to now.
bool isBefore(String str, [String? date]) {
  DateTime _dt;
  if (date == null) {
    _dt = DateTime.now();
  } else if (isDate(date)) {
    _dt = DateTime.parse(date);
  } else {
    return false;
  }

  DateTime strDate;
  try {
    strDate = DateTime.parse(str);
  } catch (e) {
    return false;
  }

  return strDate.isBefore(_dt);
}

/// check if the string is in a array of allowed values
bool isIn(String str, List<String> values) {
  if (values.isEmpty) {
    return false;
  }

  final mapped = values.map((e) => e.toString()).toList();

  return mapped.contains(str);
}

/// check if the string is a credit card
bool isCreditCard(String str) {
  final String sanitized = str.replaceAll(RegExp('[^0-9]+'), '');
  if (!_creditCard.hasMatch(sanitized)) {
    return false;
  }

  // Luhn algorithm
  int sum = 0;
  String digit;
  bool shouldDouble = false;

  for (int i = sanitized.length - 1; i >= 0; i--) {
    digit = sanitized.substring(i, i + 1);
    int tmpNum = int.parse(digit);

    if (shouldDouble == true) {
      tmpNum *= 2;
      if (tmpNum >= 10) {
        sum += (tmpNum % 10) + 1;
      } else {
        sum += tmpNum;
      }
    } else {
      sum += tmpNum;
    }
    shouldDouble = !shouldDouble;
  }

  return sum % 10 == 0;
}

/// check if the string is an ISBN (version 10 or 13)
bool isISBN(String str, [dynamic version]) {
  if (version == null) {
    return isISBN(str, '10') || isISBN(str, '13');
  }

  final _version = version.toString();

  final String sanitized = str.replaceAll(RegExp(r'[\s-]+'), '');
  int checksum = 0;

  if (_version == '10') {
    if (!_isbn10Maybe.hasMatch(sanitized)) {
      return false;
    }
    for (int i = 0; i < 9; i++) {
      checksum += (i + 1) * int.parse(sanitized[i]);
    }
    if (sanitized[9] == 'X') {
      checksum += 10 * 10;
    } else {
      checksum += 10 * int.parse(sanitized[9]);
    }
    return checksum % 11 == 0;
  } else if (_version == '13') {
    if (!_isbn13Maybe.hasMatch(sanitized)) {
      return false;
    }
    final factor = [1, 3];
    for (int i = 0; i < 12; i++) {
      checksum += factor[i % 2] * int.parse(sanitized[i]);
    }
    return int.parse(sanitized[12]) - ((10 - (checksum % 10)) % 10) == 0;
  }

  return false;
}

/// check if the string is valid JSON
bool isJSON(String str) {
  try {
    jsonDecode(str);
  } catch (e) {
    return false;
  }
  return true;
}

/// check if the string contains one or more multibyte chars
bool isMultibyte(String str) {
  return _multibyte.hasMatch(str);
}

/// check if the string contains ASCII chars only
bool isAscii(String str) {
  return _ascii.hasMatch(str);
}

/// check if the string contains any full-width chars
bool isFullWidth(String str) {
  return _fullWidth.hasMatch(str);
}

/// check if the string contains any half-width chars
bool isHalfWidth(String str) {
  return _halfWidth.hasMatch(str);
}

/// check if the string contains a mixture of full and half-width chars
bool isVariableWidth(String str) {
  return isFullWidth(str) && isHalfWidth(str);
}

/// check if the string contains any surrogate pairs chars
bool isSurrogatePair(String str) {
  return _surrogatePairsRegExp.hasMatch(str);
}

/// check if the string is a valid hex-encoded representation of a MongoDB ObjectId
bool isMongoId(String str) {
  return isHexadecimal(str) && str.length == 24;
}

var _threeDigit = RegExp(r'^\d{3}$');
var _fourDigit = RegExp(r'^\d{4}$');
var _fiveDigit = RegExp(r'^\d{5}$');
var _sixDigit = RegExp(r'^\d{6}$');
var _postalCodePatterns = {
  "AD": RegExp(r'^AD\d{3}$'),
  "AT": _fourDigit,
  "AU": _fourDigit,
  "BE": _fourDigit,
  "BG": _fourDigit,
  "CA": RegExp(
      r'^[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][\s\-]?\d[ABCEGHJ-NPRSTV-Z]\d$',
      caseSensitive: false),
  "CH": _fourDigit,
  "CZ": RegExp(r'^\d{3}\s?\d{2}$'),
  "DE": _fiveDigit,
  "DK": _fourDigit,
  "DZ": _fiveDigit,
  "EE": _fiveDigit,
  "ES": _fiveDigit,
  "FI": _fiveDigit,
  "FR": RegExp(r'^\d{2}\s?\d{3}$'),
  "GB": RegExp(r'^(gir\s?0aa|[a-z]{1,2}\d[\da-z]?\s?(\d[a-z]{2})?)$',
      caseSensitive: false),
  "GR": RegExp(r'^\d{3}\s?\d{2}$'),
  "HR": RegExp(r'^([1-5]\d{4}$)'),
  "HU": _fourDigit,
  "ID": _fiveDigit,
  "IL": _fiveDigit,
  "IN": _sixDigit,
  "IS": _threeDigit,
  "IT": _fiveDigit,
  "JP": RegExp(r'^\d{3}\-\d{4}$'),
  "KE": _fiveDigit,
  "LI": RegExp(r'^(948[5-9]|949[0-7])$'),
  "LT": RegExp(r'^LT\-\d{5}$'),
  "LU": _fourDigit,
  "LV": RegExp(r'^LV\-\d{4}$'),
  "MX": _fiveDigit,
  "NL": RegExp(r'^\d{4}\s?[a-z]{2}$', caseSensitive: false),
  "NO": _fourDigit,
  "PL": RegExp(r'^\d{2}\-\d{3}$'),
  "PT": RegExp(r'^\d{4}\-\d{3}?$'),
  "RO": _sixDigit,
  "RU": _sixDigit,
  "SA": _fiveDigit,
  "SE": RegExp(r'^\d{3}\s?\d{2}$'),
  "SI": _fourDigit,
  "SK": RegExp(r'^\d{3}\s?\d{2}$'),
  "TN": _fourDigit,
  "TW": RegExp(r'^\d{3}(\d{2})?$'),
  "UA": _fiveDigit,
  "US": RegExp(r'^\d{5}(-\d{4})?$'),
  "ZA": _fourDigit,
  "ZM": _fiveDigit
};

bool isPostalCode(String text, String locale, {bool Function()? orElse}) {
  final pattern = _postalCodePatterns[locale];
  return pattern != null
      ? pattern.hasMatch(text)
      : orElse != null
          ? orElse()
          : throw const FormatException();
}

String? shift(List<String> l) {
  if (l.isNotEmpty) {
    final first = l.first;
    l.removeAt(0);
    return first;
  }
  return null;
}
