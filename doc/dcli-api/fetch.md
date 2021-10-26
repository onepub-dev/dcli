# Fetch

The fetch command allows you to send and receive data to or from a server.

Fetch supports http and https but where possible you should always use https.

In its simplest form fetch is often used to download a file from a web server however you can also post data to a web server.

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

DCli allows you to fetch a single web resource with progress information or to simultaneously fetch multiple resources.

## Fetch a single resource

The resource 'sample.aac' will be downloaded and saved to the temporary file 'sample.aac'.

```dart
withTempFile((sampleAac) {
  try {
        String baseURl =
'https://raw.githubusercontent.com/noojee/dcli/master/test/src/functions/fetch_downloads';
        fetch(url: '$baseURl/sample.aac', saveToPath: sampleAac);
    } on FetchException catch (e) {
      print('Exception Thrown: ${e.errorCode} ${e.message}');
    }
    /// print the returned data including any errors.
    if (exists(tmp)) {
      print(read(tmp).toParagraph());
    }
}, create: false
, suffix: 'acc');
```

## Fetch as single resource and show progress

```dart
  withTempFile((sampleAac) {
   try {
       fetch(url: '$baseURl/sample.aac',
            saveToPath: sampleAac,
            onProgress: (progress) {
            print(progress);
       });
    } on FetchException catch (e) {
      print('Exception Thrown: ${e.errorCode} ${e.message}');
    }
    /// print the returned data including any errors.
    if (exists(tmp)) {
      print(read(tmp).toParagraph());
    }
 }, create: false
 , suffix: 'acc');
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

## Post data to a server

Send the data contained in the 'content' variable to httpbin.org.

```dart
 withTempFile((file) {
     try
     {
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
    } on FetchException catch (e) {
      print('Exception Thrown: ${e.errorCode} ${e.message}');
    }
    /// print the returned data including any errors.
    if (exists(file)) {
      print(read(file).toParagraph());
    }
  }, create: false);
      
```

## FetchData

When posting data to a server you can provide the data from a number of different sources using the appropriate FetchData constructor.

### FetchData.fromString

Provides data to the fetch method contained in a String.&#x20;

By default the mimeType is set to text/plain but you can override this by explicitly passing a mimeType

```dart
FetchData.fromString('Hello World', mimeType: 'plain.csv');
```

### FetchData.fromFile

The fromFile constructor uses a file as the source of the data to be posted.

By default fromFile will use the filename's extension to determine the mime type.

You can override the default behaviour by passing the mimeType to the constructor

```dart
FetchData.fromFile('mountains.png');

FetchData.fromFile('mountains', mimeType: 'image/png');
```

### FetchData.fromBytes

The fromBytes constructor allows you to set the source of data as a byte array.

```dart
  withTempFile((pathToData) {
        withTempFile((file) {
          const bytes = <int>[0, 1, 2, 3, 4, 5];

          fetch(
              url: 'https://httpbin.org/post',
              method: FetchMethod.post,
              data: FetchData.fromBytes(bytes),
              saveToPath: file);
        
        }, create: false);
      });
```

### FetchData.fromStream

The fromStream constructor allows you use a stream as the source of the post data.

By default the mimeType is set to 'application/octet-stream' but you can override this by passing an explicit mimeType to FetchData.fromStream.

```dart
withTempFile((pathToData) { 
    withTempFile((file) { 
        const content = 'Hellow World2'; 
        pathToData.write(content);  
            
      fetch(
          url: 'https://httpbin.org/post',
          method: FetchMethod.post,
          data: FetchData.fromStream(File(pathToData).openRead()),
          saveToPath: file);
          
    }, create: false);
  });
```

### Custom Headers

The fetch function allows you to set custom HTTP headers.

The 'Content-Type' header will be overridden by the mimeType in FetchData.&#x20;

```dart
   withTempFile((file) {
        fetch(url: 'https://httpbin.org/get',
            headers: {'X-Test-Header1': 'Value1', 'X-Test-Header2': 'Value2'},
            saveToPath: file);
            
      }, create: false);
```
