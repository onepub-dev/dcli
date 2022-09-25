# User input

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

Asking the user to input data into a CLI application should be simple. DCli provide a number of core methods to facilitate user input.

* ask
* confirm
* menu

## Ask

The 'ask' function provides a simple but flexible means of requesting information from the user.

In its simplest form you can ask the user for an input string.

{% hint style="info" %}
Any user input has **whitespace** stripped before it is validated or returned.
{% endhint %}

### Arguments

#### prompt

The prompt is the only positional argument that ask takes. Ask will display the prompt verbatim.

```dart
var username = ask('Username:');
```

```bash
Username: brett
```

You may pass an empty string for the prompt in which case no prompt will be displayed.

#### hidden

You can request that the user input isn't echoed back to the user:

```dart
var password = ask('Password:', hidden: true);
```

```bash
Password: ******
```

#### defaultValue

You can provide a default value. If the user hits enter without entering any text then the default value will be returned.

```dart
var username = ask('Username:', defaultValue: 'Administrator');
```

```bash
Username: Administrator 
```

If you combine a defaultValue with the hidden argument then the default value will be rendered as 6 '\*'.

```dart
var password = ask('Password:', hidden: true, defaultValue: 'a secret');
```

```bash
password: ****** 
```

If you combine a defaultValue with an empty prompt then Ask will not display the prompt nor the default value.

```dart
var secretQuestion = ask('', defaultValue: 'a secret', required: false);
```

```bash

```

#### validator

Ask takes  a validator. If the entered input doesn't match the supplied validator then the user will be re-prompted until they enter a valid value.

```dart
var age = ask('Age:', validator: Ask.integer);
```

```bash
Age: abc
Invalid integer.
Age:
```

See the section on [validators](ask-validators.md) for more details.

#### required

By default the ask function requires the user to enter a non-blank line \(whitespace is stripped from user input before it is evaluated\).

If you want to make a user value optional either pass in a defaultValue or pass required: false

```dart
var age = ask('Age:', required: false, validator: Ask.integer);
```

## Confirm

The confirm method allows you to ask the user for a true/false response and returns a bool reflecting what the user entered.

```dart
bool allowed = confirm('Are you over 18', defaultValue: false);
```

## Menu

The menu function allows you to display a list of menu items for the user to select from and returns the selected item.

```dart
var selected = menu('Select your poison'
   , options: ['beer', 'wine', 'spirits']
   , defaultOption: 'beer');
print(green('You chose $selected'));
```

```dart
1) beer
2) wine
3) spirits
Selection your poison: 1
```

You can also specify a default option. If you pass a default value and the user hits enter without entering a value then the default value will be returned.

The list of options can be a String or a Dart class. By default menu will call toString on any object passed but you can pass the format argument to control how each option is displayed:

```dart
class Car
{
   String make;
   String model;
   Car(this.make, this.model);
}
var selected = menu('Choose your preferred car:'
   , options: [Car('Ford', 'Falcon'), Car('Holden', 'Capree'), Car('BMW', 'M3')]
   , format: (car) => '${car.make} ${car.model}'
   , defaultOption: 'Ford Falcon');
print(green('You chose $selected'));
```

```dart
1) Ford Falcon
2) Holden Capree
3) BMW M3
Choose your preferred car: 1
```

