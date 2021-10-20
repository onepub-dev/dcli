@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/parser.dart';
import 'package:test/test.dart';

String baseURl =
    'https://raw.githubusercontent.com/bsutton/dcli/master/test/src/functions/fetch_downloads';
String? testFile;
void main() {
  group('Fetch Single', () {
    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    test('Fetch One', () {
      //Settings().setVerbose(enabled: true);
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
      //Settings().setVerbose(enabled: true);
      withTempDir((testRoot) {
        withTempFile(
          (result) {
            final headers = {'Head1': 'value1', 'Head2': 'value2'};

            /// httpbin echos the headers we pass.
            /// However it capitalises the first letter of the header key.
            /// So we pre-empt it by sending them capitialised.
            fetch(
                url: 'https://httpbin.org/headers',
                saveToPath: result,
                headers: headers);
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
                  e is FetchException &&
                  e.message.contains('No such host is known.') &&
                  e.errorCode == 11001,
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
              (e) =>
                  e is FetchException &&
                  e.message.contains('Not Found') &&
                  e.errorCode == 404,
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
}

Future<void> showProgress(FetchProgress progress) async {
  Terminal().overwriteLine('${progress.progress * 100} %');
}
