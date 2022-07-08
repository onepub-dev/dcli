/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

/// Typedef for LineActions
typedef LineAction = void Function(String line);

/// Typedef for cancellable LineActions.
typedef CancelableLineAction = bool Function(String line);
