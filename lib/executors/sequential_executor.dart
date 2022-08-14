import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../guard_base.dart';
import '../guard_check_result.dart';
import '../guard_executor.dart';

class SequentialExecutor implements GuardExecutor {
  @override
  void execute(
    BuildContext context,
    WidgetRef ref,
    Iterable<GuardBase> guards,
    GuardedWidgetUpdate update,
    int runId,
    int Function() currentRunId,
  ) async {
    bool checkIsSync = true;
    for (final guard in guards) {
      // if we has async guards and new check started just return without result
      if (!checkIsSync && currentRunId() != runId) return;
      final rawResult = guard.check(context, ref);
      final guardIsSync = rawResult is! Future;
      final result = guardIsSync ? rawResult : await rawResult;
      checkIsSync &= guardIsSync;

      if (result is GuardCheckResultPass) continue;
      return update(result, runId: runId, sync: checkIsSync);
    }
    return update(
      const GuardCheckResultPass(),
      runId: runId,
      sync: checkIsSync,
    );
  }
}
