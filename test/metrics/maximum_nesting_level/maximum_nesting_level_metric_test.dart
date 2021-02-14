// @dart=2.8

@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/metrics/maximum_nesting_level/maximum_nesting_level_metric.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/maximum_nesting_level_example.dart';

Future<void> main() async {
  final metric = MaximumNestingLevelMetric(
    config: {MaximumNestingLevelMetric.metricId: '2'},
  );

  final scopeVisitor = ScopeVisitor();

  final example = await resolveFile(path: p.normalize(p.absolute(examplePath)));
  example.unit.visitChildren(scopeVisitor);

  group('MaximumNestingLevelMetric computes maximum nesting level of the', () {
    test('simple function', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.first.declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(3));
      expect(metricValue.level, equals(MetricValueLevel.warning));
      expect(
        metricValue.comment,
        equals(
          'This function has a nesting level of 3, which exceeds the maximum of 2 allowed.',
        ),
      );
      expect(metricValue.recommendation, isNull);
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'Block function body increases depth',
          'If statement increases depth',
          'If statement increases depth',
        ]),
      );
    });

    test('in constructor', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[1].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(2));
      expect(metricValue.level, equals(MetricValueLevel.noted));
      expect(
        metricValue.comment,
        equals('This constructor has a nesting level of 2.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'Block function body increases depth',
          'If statement increases depth',
        ]),
      );
    });

    test('in class method', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[2].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(2));
      expect(metricValue.level, equals(MetricValueLevel.noted));
      expect(
        metricValue.comment,
        equals('This getter has a nesting level of 2.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'Block function body increases depth',
          'If statement increases depth',
        ]),
      );
    });

    test('simple function for documentation', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.last.declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(3));
      expect(metricValue.level, equals(MetricValueLevel.warning));
      expect(
        metricValue.comment,
        equals(
          'This function has a nesting level of 3, which exceeds the maximum of 2 allowed.',
        ),
      );
      expect(metricValue.recommendation, isNull);
      expect(
        metricValue.context.map((e) => e.message),
        equals([
          'Block function body increases depth',
          'Do statement increases depth',
          'If statement increases depth',
        ]),
      );
    });
  });
}
