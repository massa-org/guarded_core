part of 'guarded_configuration.dart';

class GuardedConfigurationLoadingWidget extends GuardedConfiguration {
  static GuardedConfigurationLoadingWidget? watch(WidgetRef ref) =>
      GuardedConfiguration.watch<GuardedConfigurationLoadingWidget>(ref);

  GuardedConfigurationLoadingWidget(this.loadingWidget);

  final Widget loadingWidget;
}

class GuardedLoading extends ConsumerWidget {
  const GuardedLoading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = GuardedConfigurationLoadingWidget.watch(ref);
    if (config != null) return config.loadingWidget;

    return const CircularProgressIndicator();
  }
}
