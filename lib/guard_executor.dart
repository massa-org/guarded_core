import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guard_base.dart';
import 'guard_check_result.dart';

typedef GuardedWidgetUpdate = void Function(
  GuardCheckResult result, {
  required bool sync,
  required int runId,
});

abstract class GuardExecutor {
  void execute(
    BuildContext context,
    WidgetRef ref,
    Iterable<GuardBase> guards,
    GuardedWidgetUpdate update,
    // id of this run for ignore irrelevant updates and stop if next run started
    int runId,
    // closure for get currentRunId for cancel unused checks
    int Function() currentRunId,
  );
}
