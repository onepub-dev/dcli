class CallbackStringSync implements Sink<String> {
  CallbackStringSync(this.callback);

  final void Function(String) callback;

  @override
  void add(String data) {
    callback(data);
  }

  @override
  void close() {}
}
