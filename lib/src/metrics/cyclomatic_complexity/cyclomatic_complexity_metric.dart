import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';

import '../../models/code_example.dart';
import '../../models/context_message.dart';
import '../../models/entity_type.dart';
import '../../models/metric_documentation.dart';
import '../../models/scoped_class_declaration.dart';
import '../../models/scoped_function_declaration.dart';
import '../../utils/metric_utils.dart';
import '../../utils/node_utils.dart';
import '../../utils/string_extension.dart';
import '../function_metric.dart';
import '../metric_computation_result.dart';
import 'cyclomatic_complexity_flow_visitor.dart';

const _documentation = MetricDocumentation(
  name: 'Cyclomatic Complexity',
  shortName: 'CYCLO',
  brief: 'The number of linearly-independent paths through a code block',
  measuredType: EntityType.methodEntity,
  examples: [
    CodeExample(
      examplePath: 'test/resources/cyclomatic_complexity_metric_example.dart',
      startLine: 70,
      endLine: 87,
    ),
  ],
);

/// Cyclomatic Complexity (CYCLO)
///
/// Cyclomatic сomplexity is a measure of the code's complexity achieved by
/// measuring the number of linearly independent paths through a source code.
class CyclomaticComplexityMetric extends FunctionMetric<int> {
  static const String metricId = 'cyclomatic-complexity';

  CyclomaticComplexityMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          documentation: _documentation,
          threshold: readThreshold<int>(config, metricId, 20),
          levelComputer: valueLevel,
        );

  @override
  MetricComputationResult<int> computeImplementation(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) {
    final visitor = CyclomaticComplexityFlowVisitor();
    node.visitChildren(visitor);

    return MetricComputationResult(
      value: visitor.complexityEntities.length + 1,
      context: _context(node, visitor.complexityEntities, source),
    );
  }

  @override
  String commentMessage(String nodeType, int value, int threshold) {
    final exceeds = value > threshold
        ? ', which exceeds the maximum of $threshold allowed'
        : '';

    return 'This $nodeType has a cyclomatic complexity of $value$exceeds.';
  }

  Iterable<ContextMessage> _context(
    Declaration node,
    Iterable<SyntacticEntity> complexityEntities,
    ResolvedUnitResult source,
  ) =>
      complexityEntities.map((entity) {
        String message;
        if (entity is AstNode) {
          message = _removeImpl(entity.runtimeType.toString() ?? '')
              .camelCaseToText();
        } else if (entity is Token) {
          message = 'Operator ${entity.lexeme}';
        }

        return ContextMessage(
          message: '${message.capitalize()} increases complexity',
          location: nodeLocation(node: entity, source: source),
        );
      }).toList()
        ..sort((a, b) => a.location.start.compareTo(b.location.start));

  String _removeImpl(String typeName) {
    const _impl = 'Impl';

    return typeName.endsWith(_impl)
        ? typeName.substring(0, typeName.length - _impl.length)
        : typeName;
  }
}
