@TestOn('vm')
import 'package:code_checker/src/config/analysis_options.dart';
import 'package:code_checker/src/config/config.dart';
import 'package:test/test.dart';

const _options = AnalysisOptions({
  'include': 'package:pedantic/analysis_options.yaml',
  'analyzer': {
    'exclude': ['test/resources/**'],
    'plugins': ['code_checker'],
    'strong-mode': {'implicit-casts': false, 'implicit-dynamic': false},
  },
  'code_checker': {
    'anti-patterns': {
      'anti-pattern-id1': true,
      'anti-pattern-id2': false,
      'anti-pattern-id3': true,
    },
    'metrics': {
      'metric-id1': '5',
      'metric-id2': '10',
      'metric-id3': '5',
      'metric-id4': '0',
    },
    'metrics-exclude': ['test/**', 'examples/**'],
    'rules': {'rule-id1': false, 'rule-id2': true, 'rule-id3': true},
  },
});

const _defaults = Config(
  excludePatterns: ['test/resources/**'],
  excludeForMetricsPatterns: ['test/**'],
  metrics: {
    'metric-id1': '15',
    'metric-id2': '10',
    'metric-id3': '5',
  },
);

const _empty = Config(
  excludePatterns: [],
  excludeForMetricsPatterns: [],
  metrics: {},
);

const _merged = Config(
  excludePatterns: ['test/resources/**'],
  excludeForMetricsPatterns: ['test/**', 'examples/**'],
  metrics: {
    'metric-id1': '5',
    'metric-id2': '10',
    'metric-id3': '5',
    'metric-id4': '0',
  },
);

const _overrides = Config(
  excludePatterns: [],
  excludeForMetricsPatterns: ['examples/**'],
  metrics: {
    'metric-id1': '5',
    'metric-id4': '0',
  },
);

void main() {
  group('Config', () {
    group('fromAnalysisOptions constructs instance from passed', () {
      test('empty options', () {
        final config = Config.fromAnalysisOptions(const AnalysisOptions({}));

        expect(config.excludePatterns, isEmpty);
        expect(config.excludeForMetricsPatterns, isEmpty);
        expect(config.metrics, isEmpty);
      });

      test('data', () {
        final config = Config.fromAnalysisOptions(_options);

        expect(config.excludePatterns, equals(['test/resources/**']));
        expect(
          config.excludeForMetricsPatterns,
          equals(['test/**', 'examples/**']),
        );
        expect(
          config.metrics,
          equals({
            'metric-id1': '5',
            'metric-id2': '10',
            'metric-id3': '5',
            'metric-id4': '0',
          }),
        );
      });
    });

    group('merge constructs instance with data from', () {
      test('defaults and empty configs', () {
        final result = _defaults.merge(_empty);

        expect(result.excludePatterns, equals(_defaults.excludePatterns));
        expect(
          result.excludeForMetricsPatterns,
          equals(_defaults.excludeForMetricsPatterns),
        );
        expect(result.metrics, equals(_defaults.metrics));
      });
      test('empty and overrides configs', () {
        final result = _empty.merge(_overrides);

        expect(result.excludePatterns, equals(_overrides.excludePatterns));
        expect(
          result.excludeForMetricsPatterns,
          equals(_overrides.excludeForMetricsPatterns),
        );
        expect(result.metrics, equals(_overrides.metrics));
      });
      test('defaults and overrides configs', () {
        final result = _defaults.merge(_overrides);

        expect(result.excludePatterns, equals(_merged.excludePatterns));
        expect(
          result.excludeForMetricsPatterns,
          equals(_merged.excludeForMetricsPatterns),
        );
        expect(result.metrics, equals(_merged.metrics));
      });
    });
  });
}
