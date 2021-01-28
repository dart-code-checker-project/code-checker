import 'package:meta/meta.dart';

import '../utils/analysis_options_utils.dart';
import 'analysis_options.dart';

/// Class representing config
@immutable
class Config {
  final Iterable<String> excludePatterns;
  final Iterable<String> excludeForMetricsPatterns;
  final Map<String, Object> metrics;

  const Config({
    @required this.excludePatterns,
    @required this.excludeForMetricsPatterns,
    @required this.metrics,
  });

  factory Config.fromAnalysisOptions(AnalysisOptions options) {
    const _rootKey = 'code_checker';

    return Config(
      excludePatterns: options.readIterableOfString(['analyzer', 'exclude']),
      excludeForMetricsPatterns:
          options.readIterableOfString([_rootKey, 'metrics-exclude']),
      metrics: options.readMap([_rootKey, 'metrics']),
    );
  }

  Config merge(Config overrides) => Config(
        excludePatterns: {...excludePatterns, ...overrides.excludePatterns},
        excludeForMetricsPatterns: {
          ...excludeForMetricsPatterns,
          ...overrides.excludeForMetricsPatterns,
        },
        metrics: mergeMaps(defaults: metrics, overrides: overrides.metrics),
      );
}
