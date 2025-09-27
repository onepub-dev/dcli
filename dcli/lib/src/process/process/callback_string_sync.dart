class CallbackStringSync implements Sink<String> {
  final void Function(String) callback;

  CallbackStringSync(this.callback);

  @override
  void add(String data) {
    callback(data);
  }

  @override
  void close() {}
}
