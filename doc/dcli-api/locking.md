# Locking

DCli provides a NamedLock class which enables you to control access to a resource.

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

There are many scenarios where you only want a single process to access a file or some other resource.

NamedLocks are a co-operative locking mechanism. This means that if some process chooses to ignore the lock then we can do nothing about that.

However if you are running multiple copies of a cli application that you built with the DCli api then you can use a NamedLock to ensure that the apps co-operate with each other.

The NamedLock class tries to be clever and is able to detect if a crashed application has left an old lock lying around. If NamedLock detects this it will release the lock held by the crashed application.

```dart
 NamedLock(name: 'rebuild').withLock(() {
          /// this body will only be called when the lock is taken
          // Do a database rebulid....
        });
```

There a many uses case for a NamedLock, internally we run parallel deployments which require dcli scripts to be pre-compiled. Rather than having multiple deployment tools all trying to compile the tools at the same time we wrap the compile step in a named lock.

