import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../settings.dart';
import '../util/dshell_exception.dart';
import '../util/file_system.dart';
import '../util/wait_for_ex.dart';
import 'function.dart';
import 'is.dart';
import 'touch.dart';

typedef OnFetchProgress = void Function(FetchProgress progress);

/// Fetches the given resource at the passed [url].
///
/// ```dart
/// fetch(url: 'https://some/resource/file.zip', saveToPath: '/tmp/file.zip');
/// ```
/// The [url] must be a http or https based resource.
///
/// The [saveToPath] may be an absolute (recommended) or relative path where to
/// save the downloaded resource.
///
/// The file at [saveToPath] must NOT exist. If it does a [FetchException] will be thrown.
///
/// You may optionally passing in a [progess] method which will be called each
/// time a chunk is downloaded with details on the download progress.
/// We guarentee that you will recieve a final event with the [FetchProgress.progress]
/// containing a value of 1.0 and a status of 'complete'.
///
/// In the future we MAY allow you to cancel the download part way through by returning [false]
/// to the [onProgress] call. In the meantime ensure that you always return [true] from
/// the 'onProgress' callback.
///
void fetch(
        {@required String url,
        @required String saveToPath,
        OnFetchProgress onProgress}) =>
    _Fetch().fetch(url: url, saveToPath: saveToPath, onProgress: onProgress);

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
/// The [url] contained in each passed [FetchUrl] must be a http or https based resource.
///
/// The [saveToPath] contained in each [FetchUrl] may be an absolute (recommended) or relative path where to
/// save the downloaded resource.
///
///
/// You may optionally passing in a [progess] method with each [FetchUrl] which will be called each
/// time a chunk is downloaded with details on the download progress.
///
/// We guarentee that you will recieve a final event with the [FetchProgress.progress]
/// containing a value of 1.0 and a status of 'complete' for each url requested.
///
/// You can cancel the download part way through the download by returning [false]
/// to the [onProgress] call.
/// You must call cancel on all downloads or the remaining downloads must complete before
/// [fetchMultiple] will return.
///
void fetchMultiple({@required List<FetchUrl> urls}) =>
    _Fetch().fetchMultiple(urls: urls);

class _Fetch extends DShellFunction {
  void fetch({String url, String saveToPath, OnFetchProgress onProgress}) {
    waitForEx<void>(download(
        FetchUrl(url: url, saveToPath: saveToPath, onProgress: onProgress)));
  }

  void fetchMultiple({List<FetchUrl> urls}) {
    var futures = <Future<void>>[];

    for (var url in urls) {
      futures.add(download(url));
    }

    try {
      /// wait for all downloads to complete.
      waitForEx<void>(Future.wait(futures));
    } on DShellException catch (e, st) {
      print(st);
    }
  }

  Future<void> download(FetchUrl fetchUrl) {
    // announce we are starting.
    Settings().verbose('Started downloading: ${fetchUrl.url}');
    var completer = Completer<void>();
    _sendProgressEvent(FetchProgress._initialising(fetchUrl));

    if (exists(fetchUrl.saveToPath)) {
      throw FetchException(
          'The file at saveToPath:${fetchUrl.saveToPath} already exists.');
    }

    touch(fetchUrl.saveToPath, create: true);

    _sendProgressEvent(FetchProgress._connecting(fetchUrl));

    var client = HttpClient();
    unawaited(client.getUrl(Uri.parse(fetchUrl.url)).then((request) {
      /// we have connected
      _sendProgressEvent(FetchProgress._connected(fetchUrl));

      /// we can added headers here if we need.
      /// send the request
      return request.close();
    }).then((response) async {
      var lengthReceived = 0;

      var contentLength = response.contentLength;

      // we have a response.
      _sendProgressEvent(
          FetchProgress._downloading(fetchUrl, contentLength, 0));

      /// prep the save file.
      var saveFile = File(fetchUrl.saveToPath);
      var raf = await saveFile.open(mode: FileMode.append);
      await raf.truncate(0);

      StreamSubscription<List<int>> subscription;
      subscription = response.listen(
        (newBytes) async {
          /// if we don't pause we get overlapping calls from listen
          /// which causes the [writeFrom] to fail as you can't
          /// do overlapping io.
          subscription.pause();

          /// we have new data to save.
          await raf.writeFrom(newBytes);
          subscription.resume();
          lengthReceived += newBytes.length;

          /// progres indicated to cancel the download.
          _sendProgressEvent(FetchProgress._downloading(
              fetchUrl, contentLength, lengthReceived));

          Settings()
              .verbose('Download progress: $lengthReceived / $contentLength ');
        },
        onDone: () async {
          /// down load is complete
          await raf.close();
          _sendProgressEvent(
              FetchProgress._complete(fetchUrl, contentLength, lengthReceived));
          Settings().verbose('Completed downloading: ${fetchUrl.url}');
          unawaited(subscription.cancel());
          completer.complete();
        },
        // ignore: avoid_types_on_closure_parameters
        onError: (Object e, StackTrace st) async {
          // something went wrong.
          _sendProgressEvent(FetchProgress._error(fetchUrl));
          Settings().verbose(
            'Error downloading: ${fetchUrl.url}',
          );
          await raf.close();
          completer.completeError(e, st);
        },
        cancelOnError: true,
      );
    }));

    return completer.future;
  }

  static void _sendProgressEvent(FetchProgress progress) {
    if (progress.fetch.onProgress != null) {
      progress.fetch.onProgress(progress);
    }
  }
}

/// Used by [FetchProgress] to indicate the progress of a download.
enum FetchStatus {
  /// we are preparing to download.
  /// You will always see one and only one instance of this status in a FetchProgress event.
  /// In most cases the fetch will only stay in this state for a moment.
  initialising,

  /// We have stated the process of connecting to the remote resource.
  connecting,

  /// We have connected to the remote server.
  connected,

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
  /// the URL of the resource being downloaded
  final String url;

  /// The path to the file the download will be saved to.
  final String saveToPath;

  /// If provided this is the callback to allow the caller
  /// to monitor the download progress.
  final OnFetchProgress onProgress;

  /// ctor.
  FetchUrl({this.url, this.saveToPath, this.onProgress});
}

/// Passed to the [onProgress] method to indicate the current progress of
/// a download.
class FetchProgress {
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

  const FetchProgress._initialising(this.fetch)
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.initialising;

  const FetchProgress._connecting(this.fetch)
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.connecting;

  const FetchProgress._connected(this.fetch)
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.connected;

  const FetchProgress._downloading(this.fetch, this.length, this.downloaded)
      : status = FetchStatus.downloading,
        progress = length != 0 ? downloaded / length : 0;

  const FetchProgress._complete(this.fetch, this.length, this.downloaded)
      : progress = 1.0,
        status = FetchStatus.complete;

  const FetchProgress._error(this.fetch)
      : progress = 0.0,
        length = 0,
        downloaded = 0,
        status = FetchStatus.error;

  @override
  String toString() =>
      '$status progress:${humanNumber(downloaded)}/${humanNumber(length)} ${fetch.url}';
}

/// Throw when an error occurs fetching a resource.
class FetchException extends DShellException {
  /// ctor
  FetchException(String message) : super(message);
}
