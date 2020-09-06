# Fetch

The fetch command allows you to download web based resources.

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

DCli allows you to fetch a single web resource with progress information or to simultaneously fetch multiple resources.

### Fetch a single resource

The resource 'sample.aac' will be downloaded and saved to the temporary file 'sampleAac';

```dart
    String baseURl =
    'https://raw.githubusercontent.com/bsutton/dcli/master/test/src/functions/fetch_downloads';
    var sampleAac = fs.tempFile();
    fetch(url: '$baseURl/sample.aac', saveToPath: sampleAac);
```

### Fetch as single resource and show progress

```dart
 var sampleAac = fs.tempFile();
 fetch(url: '$baseURl/sample.aac',
       saveToPath: sampleAac,
       onProgress: (progress) {
       print(progress);
 });
```

### Fetch multiple resource and show progress

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



