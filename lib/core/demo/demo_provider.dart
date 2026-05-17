import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'demo_app_state.dart';
import 'demo_store.dart';

part 'demo_provider.g.dart';

/// Store mutasyonlarında artar — Riverpod yenilemesi için.
final demoRevisionProvider = StateProvider<int>((ref) => 0);

@Riverpod(keepAlive: true)
DemoStore demoStore(Ref ref) {
  return DemoStore(
    onStateChanged: () {
      ref.read(demoRevisionProvider.notifier).state++;
    },
  );
}

@Riverpod(keepAlive: true)
DemoAppState demoAppState(Ref ref) {
  ref.watch(demoRevisionProvider);
  return ref.read(demoStoreProvider).state;
}
