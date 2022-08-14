import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guarded_core/guarded_core.dart';

final resultStreamProvider = StreamProvider<GuardCheckResult>(
  (_) => const Stream.empty(),
);

class GuardWithSyncRefResult implements GuardBase {
  @override
  GuardCheckResult check(BuildContext context, WidgetRef ref) {
    return ref.watch(resultStreamProvider).value ??
        const GuardCheckResult.loading();
  }
}

class GuardWithAsyncRefResult implements GuardBase {
  @override
  Future<GuardCheckResult> check(BuildContext context, WidgetRef ref) async {
    return ref.watch(resultStreamProvider.future);
  }
}

class GuardWithResult implements GuardBase {
  final GuardCheckResult result;

  GuardWithResult(this.result);
  @override
  GuardCheckResult check(BuildContext context, WidgetRef ref) {
    return result;
  }
}

class GuardWithAsyncResult implements GuardBase {
  final GuardCheckResult result;

  GuardWithAsyncResult(this.result);
  @override
  Future<GuardCheckResult> check(BuildContext context, WidgetRef ref) {
    return Future.value(result);
  }
}

class GuardWithSynchronousFutureResult implements GuardBase {
  final GuardCheckResult result;

  GuardWithSynchronousFutureResult(this.result);
  @override
  Future<GuardCheckResult> check(BuildContext context, WidgetRef ref) {
    return SynchronousFuture(result);
  }
}
