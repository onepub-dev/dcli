import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../settings.dart';
import '../util/dcli_exception.dart';
import '../util/enum_helper.dart';
import '../util/format.dart';
import '../util/terminal.dart';
import '../util/wait_for_ex.dart';
import 'function.dart';
import 'is.dart';
import 'touch.dart';

/// Typedef for the progress call back used by the [fetch] function.
typedef OnFetchProgress = void Function(FetchProgress progress);

void _devNull(FetchProgress _) {}

/// Fetches the given resource at the passed [url].
///
/// ```dart
///  print(''); // will be overwritten with progress messages.
///  fetch(
///      url:
///          'https://some/resource/file.zip',
///     saveToPath: pathToPiImage,
///     fetchProgress: FetchProgress.showBytes
///         });
/// ```
/// The [url] must be a http or https based resource.
///
/// The [saveToPath] may be an absolute (recommended) or relative path where to
/// save the downloaded resource.
///
/// The file at [saveToPath] must NOT exist. If it does a [FetchException]
///  will be thrown.
///
/// You may optionally passing in a [fetchProgress] method which will be
/// called each
/// time a chunk is downloaded with details on the download progress.
/// We guarentee that you will recieve a final event with the
/// [FetchProgress.progress]
/// containing a value of 1.0 and a status of 'complete'.
///
/// In the future we MAY allow you to cancel the download part way
/// through by returning false
/// to the [fetchProgress] call. In the meantime ensure that you
///  always return true from
/// the 'onProgress' callback.
///
void fetch({
  required String url,
  required String saveToPath,
  FetchMethod method = FetchMethod.get,
  OnFetchProgress fetchProgress = _devNull,
}) =>
    _Fetch().fetch(
      url: url,
      saveToPath: saveToPath,
      method: method,
      progress: fetchProgress,
    );

/// Fetches the list of of resources indicated by [urls];
///
/// The list of resources will be downloaded in parallel.
///
///
/// ```dart
/// var urls = <FetchUrl>[FetchUrl('https://some/resource/file.zip', saveToPath: '/tmp/file.zip')
///   , 'https://some/resource/file2.zip', saveToPath: '/tmp/file2.zip'];
/// fetch(url: urls);
/// ```
/// The passed [urls] must be a http or https based resource.
///
/// The [FetchUrl.saveToPath] contained in each [FetchUrl] may be an
/// absolute (recommended) or relative path where to
/// save the downloaded resource.
///
/// You may optionally passing in a [FetchUrl.progress] method with
/// each [FetchUrl] which will be called each
/// time a chunk is downloaded with details on the download progress.
///
/// We guarentee that you will recieve a final event with the
///  [FetchProgress.progress]
/// containing a value of 1.0 and a status of 'complete' for each url requested.
///
/// You can cancel the download part way through the download by returning false
/// to the [FetchUrl.progress] call.
///
/// You must call cancel on all downloads or the remaining downloads
/// must complete before
/// [fetchMultiple] will return.
///
void fetchMultiple({required List<FetchUrl> urls}) =>
    _Fetch().fetchMultiple(urls: urls);

// /// Http Methods used when calling [fetch]
// typedef FetchMethod = String;

// /// Types used by the [fetch] method.
// class Fetch {
//   /// peform an http GET when doing the fetch
//   static const FetchMethod get = 'GET';

//   /// perform an HTTP POST when doing the fetch.
//   static const FetchMethod post = 'POST';
// }

/// Http Methods used when calling [fetch]
enum FetchMethod {
  /// peform an http GET when doing the fetch
  get,

  /// perform an HTTP POST when doing the fetch.
  post
}

class _Fetch extends DCliFunction {
  void fetch({
    required String url,
    required String saveToPath,
    OnFetchProgress progress = _devNull,
    bool verboseProgress = false,
    FetchMethod method = FetchMethod.get,
  }) {
    waitForEx<void>(
      download(
        FetchUrl(
          url: url,
          saveToPath: saveToPath,
          progress: progress,
          method: method,
        ),
        verboseProgress: verboseProgress,
      ),
    );
  }

  void fetchMultiple({
    required List<FetchUrl> urls,
    bool verboseProgress = false,
  }) {
    final futures = <Future<void>>[];

    for (final url in urls) {
      futures.add(download(url, verboseProgress: verboseProgress));
    }

    try {
      /// wait for all downloads to complete.
      waitForEx<void>(Future.wait(futures));
    } on DCliException catch (e, st) {
      print(st);
    }
  }

  Future<void> download(FetchUrl fetchUrl, {required bool verboseProgress}) {
    // announce we are starting.
    verbose(() => 'Started downloading: ${fetchUrl.url}');
    final completer = Completer<void>();
    var progress = FetchProgress.initialising(fetchUrl);
    _sendProgressEvent(progress);

    if (exists(fetchUrl.saveToPath)) {
      throw FetchException(
        'The file at saveToPath:${fetchUrl.saveToPath} already exists.',
      );
    }

    touch(fetchUrl.saveToPath, create: true);

    _sendProgressEvent(
        progress = FetchProgress.connecting(fetchUrl, prior: progress));

    final client = HttpClient();
    unawaited(
      startCall(client, fetchUrl).then((request) {
        /// we have connected
        _sendProgressEvent(
            progress = FetchProgress.connected(fetchUrl, prior: progress));

        /// we can added headers here if we need.
        /// send the request
        return request.close();
      }).then((response) async {
        var lengthReceived = 0;

        _sendProgressEvent(
          progress = FetchProgress.response(fetchUrl, response.statusCode,
              prior: progress),
        );

        final headers = <String, List<String>>{};
        response.headers.forEach((name, values) => headers[name] = values);

        _sendProgressEvent(progress = FetchProgress.forHeaders(
            fetchUrl, headers,
            prior: FetchProgress.initialising(fetchUrl)));

        final contentLength = response.contentLength;

        // we have a response.
        _sendProgressEvent(progress = FetchProgress.downloading(
            fetchUrl, contentLength, 0,
            prior: progress));

        /// prep the save file.
        final saveFile = File(fetchUrl.saveToPath);
        final raf = await saveFile.open(mode: FileMode.append);
        await raf.truncate(0);

        late StreamSubscription<List<int>> subscription;
        subscription = response.listen(
          (newBytes) async {
            /// if we don't pause we get overlapping calls from listen
            /// which causes the [writeFrom] to fail as you can't
            /// do overlapping io.
            subscription.pause();

            /// we have new data to save.
            await raf.writeFrom(newBytes);

            lengthReceived += newBytes.length;

            /// progres indicated to cancel the download.
            _sendProgressEvent(
              progress = FetchProgress.downloading(
                  fetchUrl, contentLength, lengthReceived,
                  prior: progress),
            );

            subscription.resume();

            verbose(
              () => 'Download progress: $lengthReceived / $contentLength ',
            );
          },
          onDone: () async {
            /// down load is complete
            raf.flushSync();
            await raf.close();
            await subscription.cancel();
            client.close();
            _sendProgressEvent(
              progress = FetchProgress.complete(
                  fetchUrl, contentLength, lengthReceived,
                  prior: progress),
            );
            verbose(() => 'Completed downloading: ${fetchUrl.url}');

            completer.complete();
          },
          // ignore: avoid_types_on_closure_parameters
          onError: (Object e, StackTrace st) async {
            // something went wrong.
            _sendProgressEvent(
                progress = FetchProgress.error(fetchUrl, prior: progress));
            verbose(
              () => 'Error downloading: ${fetchUrl.url}',
            );
            raf.flushSync();
            await raf.close();
            await subscription.cancel();
            client.close();

            completer.completeError(e, st);
          },
          cancelOnError: true,
        );
      }),
    );

    return completer.future;
  }

  Future<HttpClientRequest> startCall(HttpClient client, FetchUrl fetchUrl) {
    switch (fetchUrl.method) {
      case FetchMethod.get:
        return client.getUrl(Uri.parse(fetchUrl.url));

      case FetchMethod.post:
        return client.postUrl(Uri.parse(fetchUrl.url));
    }
  }

  static void _sendProgressEvent(FetchProgress progress) {
    progress.fetch.progress(progress);
  }
}

/// Used by [FetchProgress] to indicate the progress of a download.
enum FetchStatus {
  /// we are preparing to download.
  /// You will always see one and only one instance of this status
  /// in a FetchProgress event.
  /// In most cases the fetch will only stay in this state for a moment.
  initialising,

  /// We have stated the process of connecting to the remote resource.
  connecting,

  /// We have connected to the remote server.
  connected,

  /// After connection we get a responseCode.
  response,

  /// Called when we recieve the headersafter we connect.
  headers,

  /// we have connected and recieved our first chunk of data.
  downloading,

  /// the download is complete.
  complete,

  /// An error occured whilst attempting to fetch the resource.
  /// All fetch operations will cease an an [FetchException] will be thrown.
  error
}

///
/// Used to describe a url that is being downloaded including
/// the location where it is going to be stored.
class FetchUrl {
  /// ctor.
  FetchUrl({
    required this.url,
    required this.saveToPath,
    this.method = FetchMethod.get,
    this.progress = _devNull,
  });

  /// the URL of the resource being downloaded
  final String url;

  /// The path to the file the download will be saved to.
  final String saveToPath;

  /// If provided this is the callback to allow the caller
  /// to monitor the download progress.
  final OnFetchProgress progress;

  /// the HTTP method to use when sending the url
  /// Defaults to get.
  final FetchMethod method;
}

/// Passed to the [progress] method to indicate the current progress of
/// a download.
class FetchProgress {
  @visibleForTesting
  const FetchProgress.initialising(this.fetch)
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.initialising,
        headers = null,
        responseCode = null,
        prior = null;

  @visibleForTesting
  const FetchProgress.connecting(this.fetch, {required this.prior})
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.connecting,
        headers = null,
        responseCode = null;

  @visibleForTesting
  const FetchProgress.connected(this.fetch, {required this.prior})
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.connected,
        headers = null,
        responseCode = null;

  @visibleForTesting
  const FetchProgress.downloading(this.fetch, this.length, this.downloaded,
      {required this.prior})
      : status = FetchStatus.downloading,
        progress = length != 0 ? downloaded / length : 0,
        headers = null,
        responseCode = null;

  @visibleForTesting
  const FetchProgress.complete(this.fetch, this.length, this.downloaded,
      {required this.prior})
      : progress = 1.0,
        status = FetchStatus.complete,
        headers = null,
        responseCode = null;

  @visibleForTesting
  const FetchProgress.error(this.fetch, {required this.prior})
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.error,
        headers = null,
        responseCode = null;

  @visibleForTesting
  const FetchProgress.forHeaders(this.fetch, this.headers,
      {required this.prior})
      : status = FetchStatus.headers,
        progress = 0,
        length = 0,
        downloaded = 0,
        responseCode = null;

  @visibleForTesting
  const FetchProgress.response(this.fetch, this.responseCode,
      {required this.prior})
      : status = FetchStatus.response,
        progress = 0,
        length = 0,
        downloaded = 0,
        headers = null;

  /// When the [FetchStatus.headers] event is sent
  /// this will contain the headers. At all
  /// other times it will be null.
  final Map<String, List<String>>? headers;

  /// When the [FetchStatus.response] event is recieved
  /// this value will containe the response code.
  final int? responseCode;

  /// The current status of the downloader.
  final FetchStatus status;

  /// Details of the url that is being fetched
  final FetchUrl fetch;

  /// The length (in bytes) of the file being downloaded.
  /// This isn't set until we get the initial response.
  /// In some cases it still won't be set if the remote server
  /// doesn't respond with a length.
  final int length;

  /// The number of bytes downloaded so far.
  final int downloaded;

  /// a value from 0.0 to 1.0 indicating the percentage progress.
  /// You are guarneteed to get a final progress event with a value of 1.0
  final double progress;

  final FetchProgress? prior;

  /// Shows the progress by replacing the console existing line with the
  /// message:
  /// XX/YY <url>
  ///
  /// Where XX is the bytes downloaded and YY is the total bytes to download.
  /// You can control the format of the message by passing and argument to
  /// the [format] parameter.
  ///
  /// ```dart
  ///  fetch(
  ///      url:
  ///          'https://some/resource/file.zip',
  ///     saveToPath: pathToPiImage,
  ///     fetchProgress: FetchProgress.showBytes
  ///         });
  /// ```
  static void showBytes(FetchProgress progress) {
    final update = formatByteLine(progress);
    if (update.newline) {
      print('\n${update.value}');
    } else {
      Terminal()
        ..column = update.offset
        ..write(update.value);
    }
  }

  @visibleForTesting
  static ProgressByteUpdate formatByteLine(FetchProgress progress) {
    ProgressByteUpdate update;
    final status = _fixedWidthStatus(progress.status);
    final downloaded = Format.bytesAsReadable(progress.downloaded);
    final total = Format.bytesAsReadable(progress.length, pad: false);

    final url = constrain(progress.fetch.url);
    switch (progress.status) {
      case FetchStatus.initialising:
        update = ProgressByteUpdate(0, '$status      ?/?      $url');
        break;

      case FetchStatus.connected:
      case FetchStatus.connecting:
      case FetchStatus.headers:
      case FetchStatus.response:
      case FetchStatus.error:
        update = ProgressByteUpdate(0, '$status      ?/?      $url');
        break;
      case FetchStatus.downloading:
        if (progress.prior?.status == FetchStatus.downloading) {
          update = ProgressByteUpdate(14, '$downloaded/$total');
        } else {
          update = ProgressByteUpdate(0, '$status $downloaded/$total');
        }
        break;
      case FetchStatus.complete:
        update =
            ProgressByteUpdate(0, '$status $downloaded/$total', newline: true);
        break;
    }

    return update;
  }

  static String constrain(String url, {int width = 40}) {
    final partLength = width ~/ 2 - 3;
    return '${url.substring(0, partLength)}...${url.substring(url.length - partLength)}';
  }

  // status right padded to 12 chars
  static String _fixedWidthStatus(FetchStatus status) =>
      '${EnumHelper().getName(status)}:'.padRight(13);

  static void show(
    FetchProgress progress, {
    String Function(FetchProgress progress)? format,
  }) {
    final message = format == null ? progress.toString() : format(progress);
    Terminal().overwriteLine(message);
    if (progress.status == FetchStatus.complete) {
      print('');
    }
  }

  @override
  String toString() =>
      '${EnumHelper().getName(status)}: ${Format.bytesAsReadable(downloaded)}/${Format.bytesAsReadable(length)} ${fetch.url}';
}

class ProgressByteUpdate {
  ProgressByteUpdate(this.offset, this.value, {bool this.newline = false});
  int offset;
  String value;
  bool newline;
}

/// Throw when an error occurs fetching a resource.
class FetchException extends DCliException {
  /// ctor
  FetchException(String message) : super(message);
}
