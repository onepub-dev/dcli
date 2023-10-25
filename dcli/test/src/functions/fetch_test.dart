@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/parser.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

String baseURl =
    'https://github.com/noojee/dcli/raw/master/dcli/test/src/functions/fetch_downloads';
void main() {
  group('Fetch Single', () {
    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    test('Fetch One', () {
      withTempDir((testRoot) {
        withTempFile(
          (sampleAac) {
            fetch(url: '$baseURl/sample.aac', saveToPath: sampleAac);
            expect(fileLength(sampleAac), equals(14951));
            delete(sampleAac);
          },
          create: false,
        );

        // withTempFile((sampleWav) {
        //   fetch(url: '$baseURl/sample.wav', saveToPath: sampleWav);
        //   expect(FileSync(sampleWav).length, equals(212948));
        //   delete(sampleWav);
        // }, create: false);
      });
    });

    test('Fetch One with Progress', () {
      withTempDir((testRoot) {
        withTempFile(
          (sampleAac) {
            fetch(
              url: '$baseURl/sample.aac',
              saveToPath: sampleAac,
              fetchProgress: (progress) async {
                Terminal().overwriteLine('${progress.progress * 100} %');
              },
            );
            expect(fileLength(sampleAac), equals(14951));
            delete(sampleAac);

            withTempFile(
              (sampleWav) {
                fetch(
                  url: '$baseURl/sample.wav',
                  saveToPath: sampleWav,
                  fetchProgress: (progress) async {
                    Terminal().overwriteLine('${progress.progress * 100} %');
                  },
                );
                expect(fileLength(sampleWav), equals(212948));
                delete(sampleWav);
              },
              create: false,
            );
          },
          create: false,
        );
      });
    });

    test('Fetch with Headers', () {
      withTempDir((testRoot) {
        withTempFile(
          (result) {
            final headers = {'Head1': 'value1', 'Head2': 'value2'};

            /// httpbin echos the headers we pass.
            /// However it capitalises the first letter of the header key.
            /// So we preempt it by sending them capitialised.
            fetch(
                url: 'https://httpbin.org/post',
                saveToPath: result,
                method: FetchMethod.post,
                headers: headers,
                data: FetchData.fromString('Hello World'));
            final lines = read(result).toList();
            final jsonMap = Parser(lines).jsonDecode() as Map<String, dynamic>;

            final resultHeaders = jsonMap['headers'] as Map<String, dynamic>;
            expect(resultHeaders.containsKey('Head1'), isTrue);
            expect(resultHeaders['Head1'], equals('value1'));
            expect(resultHeaders.containsKey('Head2'), isTrue);
            expect(resultHeaders['Head2'], equals('value2'));
          },
          create: false,
        );

        // withTempFile((sampleWav) {
        //   fetch(url: '$baseURl/sample.wav', saveToPath: sampleWav);
        //   expect(FileSync(sampleWav).length, equals(212948));
        //   delete(sampleWav);
        // }, create: false);
      });
    });
  });

  group('Fetch Multi', () {
    test('Fetch  ', () {
      withTempDir((testRoot) {
        withTempFile(
          (sampleAac) {
            withTempFile(
              (sampleWav) {
                fetchMultiple(
                  urls: [
                    FetchUrl(
                      url: '$baseURl/sample.aac',
                      saveToPath: sampleAac,
                      progress: showProgress,
                    ),
                    FetchUrl(url: '$baseURl/sample.wav', saveToPath: sampleWav),
                  ],
                );
                expect(fileLength(sampleAac), equals(14951));
                expect(fileLength(sampleWav), equals(212948));

                delete(sampleAac);
                delete(sampleWav);
              },
              create: false,
            );
          },
          create: false,
        );
      });
    });

    test('Fetch With Progress ', () {
      withTempDir((testRoot) {
        withTempFile(
          (sampleAac) {
            withTempFile(
              (sampleWav) {
                fetchMultiple(
                  urls: [
                    FetchUrl(
                      url: '$baseURl/sample.aac',
                      saveToPath: sampleAac,
                      progress: showProgress,
                    ),
                    FetchUrl(
                      url: '$baseURl/sample.wav',
                      saveToPath: sampleWav,
                      progress: showProgress,
                    )
                  ],
                );
                expect(fileLength(sampleAac), equals(14951));
                expect(fileLength(sampleWav), equals(212948));
              },
              create: false,
            );
          },
          create: false,
        );
      });
    });
  });

  test('Fetch - shutdown bug', () {
    withTempFile(
      (sampleAac) {
        fetch(
          url: '$baseURl/sample.aac',
          saveToPath: sampleAac,
          fetchProgress: (progress) async {
            Terminal().overwriteLine('${progress.progress * 100} %');
          },
        );
        expect(fileLength(sampleAac), equals(14951));
      },
      suffix: 'acc',
      create: false,
    );

    final temp = withTempFile(
      (sampleWav) {
        fetch(
          url: '$baseURl/sample.wav',
          saveToPath: sampleWav,
          fetchProgress: (progress) async {
            Terminal().overwriteLine('${progress.progress * 100} %');
          },
        );
        expect(fileLength(sampleWav), equals(212948));
        print('finished');
        return sampleWav;
      },
      suffix: 'wav',
      create: false,
    );
    expect(exists(temp), isFalse);
  });

  group('error handling', () {
    test('host not found', () {
      withTempFile((file) {
        const url =
            'http://test.comeing.com.au/long/123456789012345678901234567890';

        expect(
          () => fetch(url: url, saveToPath: file),
          throwsA(
            predicate<FetchException>(
              (e) =>

                  /// we get different errors on windows and linux
                  /// windows
                  (e.message.contains('No such host is known.') &&
                      e.errorCode == 11001) ||

                  ///linux
                  (e.message.contains('Name or service not known') &&
                      e.errorCode == -2) ||

                  ///linux
                  (e.message.contains('Failed host lookup') &&
                      e.errorCode == -5),
            ),
          ),
        );
      }, create: false);
    });

    test('404', () {
      withTempFile((file) {
        const url = 'https://www.noojee.com.au/notfound';

        expect(
          () => fetch(url: url, saveToPath: file),
          throwsA(
            predicate<FetchException>(
              (e) => e.message.contains('Not Found') && e.errorCode == 404,
            ),
          ),
        );
      }, create: false);
    });
  });

  group('progress', () {
    test('showBytes', () {
      const url =
          'http://test.comeing.com.au/long/123456789012345678901234567890';

      final fetchUrl = FetchUrl(url: url, saveToPath: '/tmp/me');

      const constrained = 'http://test.comein...345678901234567890';
      final initializing = FetchProgress.initialising(fetchUrl);
      final downloading =
          FetchProgress.downloading(fetchUrl, 100, 100, prior: initializing);
      final downloading2 =
          FetchProgress.downloading(fetchUrl, 100, 100, prior: downloading);

      final complete =
          FetchProgress.complete(fetchUrl, 100, 100, prior: downloading);
      expect(FetchProgress.formatByteLine(initializing).value,
          'Initialising:      ?/?      $constrained');
      expect(FetchProgress.formatByteLine(downloading).value,
          'Downloading:    100B/100B');
      final downloadUpdate = FetchProgress.formatByteLine(downloading2);
      expect(downloadUpdate.value, '  100B/100B');
      expect(downloadUpdate.offset, 14);
      expect(FetchProgress.formatByteLine(complete).value,
          'Complete:       100B/100B');
    });

    test('Progress showBytes', () {
      withTempDir((testRoot) {
        withTempFile(
          (sampleAac) {
            fetch(
                url: '$baseURl/sample.aac',
                saveToPath: sampleAac,
                fetchProgress: FetchProgress.showBytes);
            expect(fileLength(sampleAac), equals(14951));
            delete(sampleAac);
          },
          create: false,
        );
      });
    });
  });

  group('post data', () {
    // example of data returned from https://httpbin.org/post
    // '{\r\n'
    //     '  "args": {}, \r\n'
    //     '  "data": "Hellow World", \r\n'
    //     '  "files": {}, \r\n'
    //     '  "form": {}, \r\n'
    //     '  "headers": {\r\n'
    //     '    "Accept-Encoding": "gzip", \r\n'
    //     '    "Content-Length": "12", \r\n'
    //     '    "Content-Type": "text/plain", \r\n'
    //     '    "Host": "httpbin.org", \r\n'
    //     '    "User-Agent": "Dart/2.14 (dart:io)", \r\n'
    //     '    "X-Amzn-Trace-Id": "Root=1-6171cf8b-615d216f4bae3846659b6697"\r\n'
    //     '  }, \r\n'
    //     '  "json": null, \r\n'
    //     '  "origin": "14.201.92.199", \r\n'
    //     '  "url": "https://httpbin.org/post"\r\n'
    //     '}'
    test('send string', () {
      withTempFile((file) {
        const content = 'Hellow World';
        fetch(
            url: 'https://httpbin.org/post',
            method: FetchMethod.post,
            data: FetchData.fromString(content),
            saveToPath: file);
        final map =
            Parser(read(file).toList()).jsonDecode() as Map<String, dynamic>;
        expect(map['data'] as String, equals(content));
        expect(
            (map['headers'] as Map<String, dynamic>)['Content-Type'] as String,
            equals('text/plain'));
      }, create: false);
    });

    test('send file', () {
      withTempFile((pathToData) {
        withTempFile((file) {
          const content = 'Hellow World2';
          pathToData.write(content);

          fetch(
              url: 'https://httpbin.org/post',
              method: FetchMethod.post,
              data: FetchData.fromFile(pathToData),
              saveToPath: file);
          final map =
              Parser(read(file).toList()).jsonDecode() as Map<String, dynamic>;
          expect(map['data'] as String, equals('$content$eol'));
          expect(
              (map['headers'] as Map<String, dynamic>)['Content-Type']
                  as String,
              equals('text/plain'));
        }, create: false);
      });
    });

    test('send stream', () {
      withTempFile((pathToData) {
        withTempFile((file) {
          const content = 'Hellow World2';
          pathToData.write(content);

          fetch(
              url: 'https://httpbin.org/post',
              method: FetchMethod.post,
              data: FetchData.fromStream(File(pathToData).openRead()),
              saveToPath: file);
          final map =
              Parser(read(file).toList()).jsonDecode() as Map<String, dynamic>;
          expect(map['data'] as String, equals('$content$eol'));
          expect(
              (map['headers'] as Map<String, dynamic>)['Content-Type']
                  as String,
              equals('application/octet-stream'));
        }, create: false);
      });
    });

    test('send bytes', () {
      withTempFile((pathToData) {
        withTempFile((file) {
          const bytes = <int>[0, 1, 2, 3, 4, 5];

          fetch(
              url: 'https://httpbin.org/post',
              method: FetchMethod.post,
              data: FetchData.fromBytes(bytes),
              saveToPath: file);
          final map =
              Parser(read(file).toList()).jsonDecode() as Map<String, dynamic>;
          expect((map['data'] as String).codeUnits, equals(bytes));
          expect(
              (map['headers'] as Map<String, dynamic>)['Content-Type']
                  as String,
              equals('application/octet-stream'));
        }, create: false);
      });
    });

    /// you can't use data with get.
    test('bad data', () {
      withTempFile((pathToData) {
        withTempFile((file) {
          const content = 'Hellow World2';
          pathToData.write(content);

          expect(
              () => fetch(
                  url: 'https://httpbin.org/get',
                  data: FetchData.fromFile(pathToData),
                  saveToPath: file),
              throwsA(predicate<FetchException>(
                (e) => e.message.contains(
                    'FetchData is not supported for the FetchMethod:'),
              )));
        }, create: false);
      });
    });

    test('custom headers', () {
      withTempFile((file) {
        fetch(
            url: 'https://httpbin.org/get',
            headers: {'X-Test-Header1': 'Value1', 'X-Test-Header2': 'Value2'},
            saveToPath: file);
        final map =
            Parser(read(file).toList()).jsonDecode() as Map<String, dynamic>;
        expect(
            (map['headers'] as Map<String, dynamic>)['X-Test-Header1']
                as String,
            equals('Value1'));
        expect(
            (map['headers'] as Map<String, dynamic>)['X-Test-Header2']
                as String,
            equals('Value2'));
      }, create: false);
    });
  });

  group('FetchData', () {
    group('mime-type', () {
      test('by extension - png', () {
        withTempFile((pathToData) {
          expect(FetchData.fromFile(pathToData).mimeType, 'image/png');
        }, suffix: 'png');
      });
      test('explicity', () {
        withTempFile((pathToData) {
          expect(
              FetchData.fromFile(pathToData, mimeType: 'alphabet/soup')
                  .mimeType,
              'alphabet/soup');
        }, suffix: 'png');
      });
      test('by extension - csv', () {
        withTempFile((pathToData) {
          expect(FetchData.fromFile(pathToData).mimeType, 'text/csv');
        }, suffix: 'csv');
      });
      test('default', () {
        withTempFile((pathToData) {
          expect(FetchData.fromFile(pathToData).mimeType, 'text/plain');
        });
      });
    });

    test('FetchData.fromFile - missing file', () {
      expect(
          () => FetchData.fromFile(join('/tmp/path/to/nowhere')),
          throwsA(predicate<FetchException>(
            (e) => e.message.contains('does not exist'),
          )));
    });

    test('FetchData.fromFile - not a file', () {
      withTempDir((tmpDir) {
        expect(
            () => FetchData.fromFile(tmpDir),
            throwsA(predicate<FetchException>(
              (e) => e.message.contains('is not a file'),
            )));
      });
    });
  });
}

Future<void> showProgress(FetchProgress progress) async {
  Terminal().overwriteLine('${progress.progress * 100} %');
}
