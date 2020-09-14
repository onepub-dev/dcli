# dipaddr

Prints each of the IP addresses bound to your PC without all of the croft.

```dart
./dipaddr.dart
name: enp39s0
  0) 192.168.1.1
name: virbr0
  0) 192.168.12.1
name: docker0
  0) 172.0.0.1
```

```dart
#! /usr/bin/env dcli

import 'dart:io';

void main() {
	NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any)
    	.then((List<NetworkInterface> interfaces) {
        interfaces.forEach((interface) {
          print('name: ${interface.name}');
          var i = 0;
          interface.addresses.forEach((address) {
            print('  ${i++}) ${address.address}');
          });
        });
    });
}

```

