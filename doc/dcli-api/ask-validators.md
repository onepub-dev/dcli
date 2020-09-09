# Ask Validators

## Overview

DCli ships with a number built in validators for use with the ask function.

When a validator is applied to the ask method, the ask method will not return until the user enters a value that satisfies the validator.

In addition to the built in validators you can also creating your own custom validators and combine multiple validators.

## Combining Validators

The DCli Ask command allows you to combine multiple validators with the Ask.any and Ask.all validators.

### Ask.all

The Ask.all validator takes an array of validators.

All validators must pass for the input to be considered valid. The validators are processed in the order they are passed \(left to right\). The error from the first validator that fails is displayed.

The Ask.all validator is the equivalent of a boolean AND operator.

It should be noted that the user input is passed to each validator in turn and each validator has the opportunity to modify the input. As a result each validators will be operating on a version of the input that has been processed by all validators that appear earlier in the list.

```dart
 var password = ask( 'Password?', hidden: true
      , validator: Ask.all([Ask.alphaNumeric, AskLength(10,16)]));
```

### Ask.any

The Ask.any validator takes an array of validators.

Only one of the validators must pass for the input to be considered valid. The validators are processed in the order they are passed \(left to right\). The error from the first validator that fails is displayed.

The Ask.any validator is the equivalent of a boolean OR operator.

It should be noted that the user input is passed to each validator in turn and each validator has the opportunity to modify the input. As a result each validators will be operating on a version of the input that has been processed by all validators that appear earlier in the list.

If none of the validators pass then the error from the first validator that failed is displayed. The implications is that the user will only ever see the error from the first validator.

```dart
 var password = ask( 'Password?', hidden: true
      , validator: Ask.all([Ask.alphaNumeric, AskValidatorLength(10,16)]));
```

## Standard Ask Validators

### Ask.ipAddress

Validates that the entered value is an ip address. By default both IPv4 and IPv6 address are permitted.

To restrict the ip address to a specific version, pass in the expected version.

```dart
var ipAddress = ask( 'Server IP?',  validator: Ask.ipAddress());
var ipV4Address = ask( 'Merchant IP?'
    , validator: Ask.ipAddress(AskValidatorIPAddress.ipv4);
```

### Ask.lengthMax

Validates that the input is no longer than the provided maximum.

```dart
var username = ask( 'username?', validator: Ask.lengthMax(32);
```

### Ask.lengthMin

Validates that the input is no shorter than the provided minimum.

```dart
var username = ask( 'username?', validator: Ask.lengthMin(26);
```

### Ask.lengthRange

Validates that the input is no shorter than the provided minimum.

```dart
var username = ask( 'username?', validator: Ask.lengthRange(26, 32);
```

### Ask.inList

Validates that the input is contained in the provided list.

{% hint style="info" %}
You are often better of using a menu.
{% endhint %}

Set the caseSensitive to true to do a case sensitive comparison. Defaults to false.

The toString method on the object is called to obtain the comparison string.

```dart
var sex = ask( 'sex?', validator: Ask.inList(['male', 'female']);
```

### Ask.required

Forces the user to enter an input value. There is no point using Ask.required if you also provide a defaultValue as the defaultValue will satisfy the required condition.

```dart
var sex = ask( 'sex?', validator: Ask.required);
```

### Ask.email

Validates that the user input is a valid email address.

```dart
var email = ask( 'Email Address?', validator: Ask.email);
```

### Ask.fqdn

Validates that the user input is a valid email address.

```dart
var email = ask( 'Email Address?', validator: Ask.email);
```

### Ask.integer

Validates that the user input is a valid integer.

```dart
var age = ask( 'Age?', validator: Ask.integer);
```

### Ask.decimal

Validates that the user input is a valid decimal number.

```dart
var age = ask( 'Age?', validator: Ask.decimal);
```

### Ask.alpha

Validates that the user input is a alpha string with every character in the range \[a-zA-Z\].

```dart
var name = ask( 'name?', validator: Ask.alpha);
```

### Ask.alphaNumeric

Validates that the user input is a alphaNumeric string with every character in the range \[a-zA-Z0-9\].

```dart
var name = ask( 'name?', validator: Ask.alpha);
```

## Custom Validators

You can also write your own validators.

All validators must inherit from the AskValidator class and implement the validate method.

The validator method must return the passed line, but may alter the line before returning it. The altered results is what will be passed out to the caller of the ask function.

If the ask function uses one of the combination validators \(Ask.all, Ask.any\) then the line input by the user will be passed to each validator in turn. Each validator may change the line and that altered value will be passed to the next validator. In this way the entered value may go through multiple transformations before being returned to the caller.

```dart
class AskGoodOrBad extends AskValidator {
  const AskGoodOrBad();
  @override
  String validate(String line) {
    line = line.trim();

    if (line != 'good' && line != 'bad') {
      throw AskValidatorException(red('The response must be good | bad'));
    }
    return line;
  }
}
```

To use your your new validator:

```dart
var getsPresent = ask('Have you been good or bad'
    , validator:  AskGoodOrBad();
```

