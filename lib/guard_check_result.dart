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

  // syncroniosly apply action on next build then apply new action result
  // right now it after all failed checks
  const factory GuardCheckResult.action(
    GuardCheckResult Function(BuildContext context, WidgetRef ref) action,
  ) = _ActionResult;

  const factory GuardCheckResult.error(
    dynamic error, {
    StackTrace? stackTrace,
  }) = GuardCheckResultError;
}
