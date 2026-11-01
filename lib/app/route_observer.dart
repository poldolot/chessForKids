import 'package:flutter/widgets.dart';

/// Lets widgets know when their route is covered or uncovered, so a teacher
/// under another screen stays quiet until the child comes back.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
