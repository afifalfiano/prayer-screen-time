import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/collections/blocked_app.dart';
import '../data/blocking_repository.dart';
import '../data/platform_bridge.dart';

final platformBridgeProvider = Provider<PlatformBridge>((ref) {
  return PlatformBridge();
});

final blockingRepositoryProvider = Provider<BlockingRepository>((ref) {
  return BlockingRepository();
});

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final bridge = ref.watch(platformBridgeProvider);
  return bridge.getInstalledApps();
});

final blockedAppsProvider =
    StateNotifierProvider<BlockedAppsNotifier, List<BlockedApp>>((ref) {
  final repo = ref.watch(blockingRepositoryProvider);
  return BlockedAppsNotifier(repo);
});

class BlockedAppsNotifier extends StateNotifier<List<BlockedApp>> {
  final BlockingRepository _repo;

  BlockedAppsNotifier(this._repo) : super(_repo.getBlockedApps());

  Future<void> toggleApp(AppInfo app, bool blocked) async {
    if (blocked) {
      await _repo.addBlockedApp(BlockedApp(
        packageName: app.packageName,
        appName: app.appName,
        isBlocked: true,
      ));
    } else {
      await _repo.removeBlockedApp(app.packageName);
    }
    state = _repo.getBlockedApps();
  }
}

class AppSelectionScreen extends ConsumerStatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  ConsumerState<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends ConsumerState<AppSelectionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final installedApps = ref.watch(installedAppsProvider);
    final blockedApps = ref.watch(blockedAppsProvider);
    final blockedPackages =
        blockedApps.map((a) => a.packageName).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Apps'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Show blocked count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${blockedApps.length} apps blocked during prayer times',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: installedApps.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text('App listing requires native integration.'),
                    const SizedBox(height: 8),
                    Text(
                      'Blocked apps will appear here once Android/iOS native bridge is configured.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              data: (apps) {
                final filtered = apps
                    .where((app) => app.appName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList()
                  ..sort((a, b) => a.appName.compareTo(b.appName));

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final app = filtered[index];
                    final isBlocked =
                        blockedPackages.contains(app.packageName);

                    return SwitchListTile(
                      title: Text(app.appName),
                      subtitle: Text(
                        app.packageName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: isBlocked,
                      onChanged: (value) {
                        ref
                            .read(blockedAppsProvider.notifier)
                            .toggleApp(app, value);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
