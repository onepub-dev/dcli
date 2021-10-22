# Fetch

The fetch command allows you to send and receive data to or from a server.

Currently fetch only supports http and https but the list of supported protocols is expected to grow.

In its simplest form fetch is often used to download a file from a web server however you can also post data to a web server.

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

DCli allows you to fetch a single web resource with progress information or to simultaneously fetch multiple resources.

## Fetch a single resource

The resource 'sample.aac' will be downloaded and saved to the temporary file 'sampleAac'.

```dart
    withTempFile((sampleAac) {
    String baseURl =
'https://raw.githubusercontent.com/noojee/dcli/master/test/src/functions/fetch_downloads';
    fetch(url: '$baseURl/sample.aac', saveToPath: sampleAac);
    }, create: false);
```

## Fetch as single resource and show progress

```dart
 var sampleAac = fs.tempFile();
 fetch(url: '$baseURl/sample.aac',
       saveToPath: sampleAac,
       onProgress: (progress) {
       print(progress);
 });
```

## Fetch multiple resource and show progress

```dart
void get() {
  var sampleAac = fs.tempFile();
  var sampleWav = fs.tempFile();

  fetchMultiple(urls: [
          FetchUrl(url: '$baseURl/sample.aac', saveToPath: sampleAac, onProgress: showProgress),
          FetchUrl(url: '$baseURl/sample.wav', saveToPath: sampleWav)
        ]);
}

void showProgress(FetchProgress progress) {
  print(progress);
}
```

## Post data to a server:

```dart
 withTempFile((file) {
        const content = 'Hellow World';
        fetch(
            url: 'https://httpbin.org/post',
            method: FetchMethod.post,
            data: FetchData.fromString(content),
            saveToPath: file);
        /// process the json response.
        final map =
            Parser(read(file).toList()).jsonDecode() as Map<String, dynamic>;
        expect(map['data'] as String, equals(content));
        expect(
            (map['headers'] as Map<String, dynamic>)['Content-Type'] as String,
            equals('text/plain'));
      }, create: false);
```
