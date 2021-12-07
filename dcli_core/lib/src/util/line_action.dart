/// Typedef for LineActions
typedef LineAction = void Function(String line);

/// Typedef for cancellable LineActions.
typedef CancelableLineAction = bool Function(String line);
