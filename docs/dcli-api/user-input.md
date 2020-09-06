# User input

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

Asking the user to input data into a cli application should be simple. DCli provide a number of core methods to facilitate user input.

* ask
* confirm
* menu

### Ask

The 'ask' function provides a simple but flexible means of requesting information from the user.

In its simplest form you can ask the user for an input string.

You may pass null for the prompt in which case not prompt will be displayed.

```dart
var username = ask('Username:');
```

```bash
Username: brett
```

You can also request that the user inputs isn't displayed back to the user:

```dart
var password = ask('Password:', hidden: true);
```

```bash
Password: ******
```

You can provide a default value. If the user just hits enter without entering any text then the default value will be returned.

```dart
var username = ask('Username:', defaultValue: 'Administrator');
```

```bash
Username: 
```

You can also add a validator. If the entered input doesn't match the supplied validator then the user will be re-prompted until the enter a valid value.

```dart
var age = ask('Age:', validator: Ask.integer);
```

```bash
Age: abc
Invalid integer.
Age:
```

### Confirm

The confirm method allows you to ask the user fro a true/false response and returns a bool reflecting what the user entered.

```dart
bool allowed = confirm('Are you over 18', defaultValue: false);
```

### Menu

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

The list of options can be a String or a class. By default menu will call toString on any object passed but you can pass the format argument to control how each option is displayed:

```dart
class Car
{
   String make;
   String model;
   Car(this.make, this.model);
}
var selected = menu('Choose your preferred car:'
   , options: [Car('Ford', 'falcon'), Car('Holden', 'Capree'), Car('BMW', 'M3')]
   , format: (car) => '${car.make} ${car.model}'
   , defaultOption: 'beer');
print(green('You chose $selected'));
```

```dart
1) Ford falcon
2) Holden Capree
3) BMW M3
Choose your preferred car: 1
```



