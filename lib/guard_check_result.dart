import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'guard_check_result.freezed.dart';

@freezed
abstract class GuardCheckResult implements _$GuardCheckResult {
  const GuardCheckResult._();

  const factory GuardCheckResult.pass() = GuardCheckResultPass;

  const factory GuardCheckResult.loading() = GuardCheckResultLoading;

  const factory GuardCheckResult.widget(Widget widget) = _WidgetResult;
  const factory GuardCheckResult.none() = _NoneResult;

  const factory GuardCheckResult.error(
    dynamic error, {
    StackTrace? stackTrace,
  }) = GuardCheckResultError;

  // advanced results use carefully

  // syncroniosly apply action on next build then apply new action result
  // right now it after all failed checks
  const factory GuardCheckResult.action(
    GuardCheckResult Function(BuildContext context, WidgetRef ref) action,
  ) = _ActionResult;

  // allow to wrap guarded widget into other widget, stop next guards execution
  // prefer to use as last guard to miss some problem and remember only one result used
  //
  // this widget sligthly broke the logic of not display children if gurds fail,
  // cause wrap interpret as fail but display underlying child
  const factory GuardCheckResult.wrap(
    Widget Function({required Widget child}) builder,
  ) = _GuardCheckResultPassWrap;
}
