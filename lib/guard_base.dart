import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guard_check_result.dart';

abstract class GuardBase {
  FutureOr<GuardCheckResult> check(BuildContext context, WidgetRef ref);
}
