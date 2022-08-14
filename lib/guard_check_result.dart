import 'package:flutter/material.dart';
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
}
