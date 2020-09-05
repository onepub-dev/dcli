# Piping

## Piping

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

Now let's pipe the output of one cli command to another.

```dart
('grep import *.dart' | 'head -n 5').forEach((line) => print(line)) ;
```

The above command launches 'grep' and 'head' to find all import lines in any Dart file and then trim the list \(via head\) to the first five lines and finally print those lines.

Note: when you use pipe you MUST surround the pipe commands with parentheses \(\) due to a precedence issue. In the above example note the parentheses just before the .forEach and the matching one at the start of the line.

What we have now is the power of Bash and the elegance of Dart.

