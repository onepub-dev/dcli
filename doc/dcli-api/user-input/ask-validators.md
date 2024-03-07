# Ask Validators

## Overview

DCli ships with a number built in validators for use with the ask function.

When a validator is applied to the ask method, the ask method will not return until the user enters a value that satisfies the validator.

{% hint style="warning" %}
If you pass required: false to`ask`, then the validator won't be called if the user input is empty!
{% endhint %}

In addition to the built-in validators, you can also create your own custom validators and combine multiple validators.

## Combining Validators

The DCli Ask command allows you to combine multiple validators with the Ask.any and Ask.all validators.

### Ask.all

The Ask.all validator takes an array of validators.

All validators must succeed for the input to be considered valid. The validators are processed in the order they are passed (left to right). The error from the first validator that fails is displayed.

The Ask.all validator is the equivalent of a boolean AND operator.

It should be noted that the user input is passed to each validator in turn and each validator has the opportunity to modify the input. As a result, each validator will be operating on a version of the input that has been processed by all validators that appear earlier in the list.

```dart
 var password = ask( 'Password?', hidden: true
      , validator: Ask.all([Ask.alphaNumeric, AskLength(10,16)]));
```

The password must be composed of alphanumeric characters **and** be between 10 and 16 characters long.

### Ask.any

The Ask.any validator takes an array of validators.

Only one of the validators must succeed for the input to be considered valid. The validators are processed in the order they are passed (left to right). If no validators pass, then the error from the first validator is displayed.

The Ask.any validator is the equivalent of a boolean OR operator.

It should be noted that the user input is passed to each validator in turn and each validator has the opportunity to modify the input. As a result, each validator will be operating on a version of the input that has been processed by all validators that appear earlier in the list.

If none of the validators pass then the error from the first validator that failed is displayed. The implication is that the user will only ever see the error from the first validator.

```dart
 var password = ask( 'Password?', hidden: true
      , validator: Ask.all([Ask.alphaNumeric, AskValidatorLength(10,16)]));
```

## Standard Ask Validators

The set of standard Ask Validators allows you to validate common input requirements. You can combine them with the Ask.all and Ask.any methods to allow for more complicated validation.

All of the standard Ask Validators allow the user to enter a blank value

{% hint style="info" %}
If you only want the validator applied if a user enters a value, then pass 'required: false' to the ask function.
{% endhint %}

### Ask.ipAddress

Validates that the entered value is an IP address. By default, both IPv4 and IPv6 addresses are permitted.

To restrict the IP address to a specific version, pass in the expected version.

```dart
var ipAddress = ask( 'Server IP?',  validator: Ask.ipAddress());
var ipV4Address = ask( 'Merchant IP?'
    , validator: Ask.ipAddress(AskValidatorIPAddress.ipv4));
```

### Ask.lengthMax

Validates that the input is no longer than the provided maximum.

```dart
var username = ask( 'username?', validator: Ask.lengthMax(32));
```

### Ask.lengthMin

Validates that the input is no shorter than the provided minimum.

```dart
var username = ask( 'username?', validator: Ask.lengthMin(26));
```

### Ask.lengthRange

Validates that the input is no shorter than the provided minimum and no longer than the provided max.

```dart
var username = ask( 'username?', validator: Ask.lengthRange(26, 32));
```

### Ask.inList

Validates that the input is contained in the provided list.

{% hint style="info" %}
You are often better off using a menu.
{% endhint %}

Set the caseSensitive to true to do a case-sensitive comparison against the list. Defaults to false.

The list may contain strings or any Dart Object.

The toString method is called on each object passed to the list to obtain the comparison string.

```dart
var sex = ask( 'sex?', validator: Ask.inList(['male', 'female']));
```

### Ask.email

Validates that the user input is a valid email address.

```dart
var email = ask( 'Email Address?', validator: Ask.email));
```

### Ask.fqdn

Validates that the user input is a valid Fully Qualified Domain Name (www.onepub.dev) address.

```dart
var email = ask( 'FQDN?', validator: Ask.fqdn));
```

### Ask.integer

Validates that the user input is a valid integer.

The integer is returned as a string.

```dart
var ageAsString = ask( 'Age?', validator: Ask.integer));
var age = int.parse(ageAsString);
```

### Ask.valueRange

Validates that an entered number is within the provided range (inclusive). Can be used with both integer and decimal no.s

The value is returned as a string.

```dart
var age = ask('Age?', 
    validator: Ask.all([Ask.integer, Ask.valueRange(18, 25)]));
```

### Ask.decimal

Validates that the user input is a valid decimal number.

The decimal is returned as a string.

```dart
var age = ask( 'Age?', validator: Ask.decimal));
```

### Ask.alpha

Validates that the user input is an alpha string with every character in the range \[a-zA-Z].

```dart
var name = ask( 'name?', validator: Ask.alpha));
```

### Ask.alphaNumeric

Validates that the user input is a alphaNumeric string with every character in the range \[a-zA-Z0-9].

```dart
var name = ask( 'name?', validator: Ask.alpha));
```

## Custom Validators

You can also write your own validators.

All validators must inherit from the AskValidator class and implement the validate method.

The validator method must return the passed line but may alter the line before returning it. The altered results are what will be returned from the ask function.

{% hint style="warning" %}
a validator MUST not include the value of the 'line' in an error message as you risk exposing a password that the user is entering.
{% endhint %}

If the ask function uses one of the combination validators (Ask.all, Ask.any) then the line input by the user will be passed to each validator in turn. Each validator may change the line and that altered value will be passed to the next validator. In this way, the entered value may go through multiple transformations before being returned to the caller.

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
    , validator:  AskGoodOrBad());
```

### Async Validators

An Ask validator must return a synchronous type. If you need to make an async call from within validator then you need to use the waitForEx function to strip the async nature of the call.

```dart
class AskAsync extends AskValidator {
  const AskAsync ();
  @override
  String validate(String line) {
    line = line.trim();
    
    if (checkInput(line) == false)
    {
      throw AskValidatorException(red("The entered line wasn't valid"));
    }
    return line;
  }
  
  Future<bool> checkInput(String line) async {
    // make some async call to check [line]
  }
}
```
