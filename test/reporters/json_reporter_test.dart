@TestOn('vm')
import 'dart:convert';
import 'dart:io';

import 'package:code_checker/src/reporters/json_reporter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'report.dart';

class IOSinkMock extends Mock implements IOSink {}

void main() {
  group('JsonReporter reports in json format', () {
    IOSinkMock output;

    setUp(() {
      output = IOSinkMock();
    });

    test('empty report', () {
      JsonReporter(output).report([]);

      verifyNever(output.write(captureAny));
    });

    test('complex report', () {
      JsonReporter(output).report(testReport);

      final report =
          json.decode(verify(output.write(captureAny)).captured.first as String)
              as Map<String, Object>;

      expect(report, contains('records'));
      expect(report['records'] as Iterable, hasLength(2));

      final recordFirst =
          (report['records'] as Iterable).first as Map<String, Object>;
      expect(recordFirst, containsPair('path', src1Path));

      final recordLast =
          (report['records'] as Iterable).last as Map<String, Object>;
      expect(recordLast, containsPair('path', src2Path));
      expect(
        recordLast['issues'],
        equals([
          {
            'ruleId': 'id',
            'documentation': 'https://documentation.com',
            'location': {
              'start': {'offset': 0, 'line': 0, 'column': 0},
              'end': {'offset': 20, 'line': 0, 'column': 20},
              'text': 'simple function body',
            },
            'severity': 'warning',
            'problemCode': 'class Logger {\n'
                '  fin',
            'message': 'simple message',
            'verboseMessage': 'verbose message',
          },
        ]),
      );

      output.close();
    });
  });
}
