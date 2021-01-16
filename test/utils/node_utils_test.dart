@TestOn('vm')
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:code_checker/src/models/processed_file.dart';
import 'package:code_checker/src/utils/node_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class AnnotatedNodeMock extends Mock implements AnnotatedNode {}

class CompilationUnitMock extends Mock implements CompilationUnit {}

class CharacterLocationMock extends Mock implements CharacterLocation {}

class LineInfoMock extends Mock implements LineInfo {}

class TokenMock extends Mock implements Token {}

const examplePath = 'test/resources/weight_of_class_example.dart';

void main() {
  group('nodeLocation returns information about node original code', () {
    const nodeComment = '/*comment*/';
    const nodeCode = 'code';
    const node = '$nodeComment$nodeCode';
    const preNodeCode = 'prefix ';
    const postNodeCode = ' postfix';

    const line = 2;

    const nodeOffset = preNodeCode.length;
    final nodeOffsetLineInfo = CharacterLocation(line, nodeOffset - line);

    const nodeEnd = nodeOffset + node.length;
    final nodeEndLineInfo = CharacterLocation(line, nodeEnd - line);

    const codeOffset = preNodeCode.length + nodeComment.length;
    final codeOffsetLineInfo = CharacterLocation(line, codeOffset - line);

    final sourceUrl = Uri.parse('file://source.dart');

    final lineInfoMock = LineInfoMock();
    when(lineInfoMock.getLocation(nodeOffset)).thenReturn(nodeOffsetLineInfo);
    when(lineInfoMock.getLocation(nodeEnd)).thenReturn(nodeEndLineInfo);
    when(lineInfoMock.getLocation(codeOffset)).thenReturn(codeOffsetLineInfo);

    final compilationUnitMock = CompilationUnitMock();
    when(compilationUnitMock.lineInfo).thenReturn(lineInfoMock);

    final tokenMock = TokenMock();
    when(tokenMock.offset).thenReturn(codeOffset);
    when(tokenMock.end).thenReturn(nodeEnd);

    final nodeMock = AnnotatedNodeMock();
    when(nodeMock.firstTokenAfterCommentAndMetadata).thenReturn(tokenMock);
    when(nodeMock.offset).thenReturn(nodeOffset);
    when(nodeMock.end).thenReturn(nodeEnd);

    test('without comment or metadata', () {
      final span = nodeLocation(
        node: nodeMock,
        source: ProcessedFile(
          sourceUrl,
          '$preNodeCode$node$postNodeCode',
          compilationUnitMock,
        ),
      );

      expect(span.start.sourceUrl, equals(sourceUrl));
      expect(span.start.offset, equals(codeOffset));
      expect(span.start.line, equals(line));
      expect(span.start.column, equals(codeOffset - line));

      expect(span.end.sourceUrl, equals(sourceUrl));
      expect(span.end.offset, equals(nodeEnd));
      expect(span.end.line, equals(line));
      expect(span.end.column, equals(nodeEnd - line));

      expect(span.text, equals(nodeCode));
    });
    test('with comment or metadata', () {
      final span = nodeLocation(
        node: nodeMock,
        source: ProcessedFile(
          sourceUrl,
          '$preNodeCode$node$postNodeCode',
          compilationUnitMock,
        ),
        withCommentOrMetadata: true,
      );

      expect(span.start.sourceUrl, equals(sourceUrl));
      expect(span.start.offset, equals(nodeOffset));
      expect(span.start.line, equals(line));
      expect(span.start.column, equals(nodeOffset - line));

      expect(span.end.sourceUrl, equals(sourceUrl));
      expect(span.end.offset, equals(nodeEnd));
      expect(span.end.line, equals(line));
      expect(span.end.column, equals(nodeEnd - line));

      expect(span.text, equals(node));
    });
  });
}
