import 'package:mason/mason.dart' hide packageVersion;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';
import 'package:atmos_cli/src/command_runner.dart';
import 'package:atmos_cli/src/commands/update.dart';
import 'package:atmos_cli/src/version.dart';

import '../../helpers/helpers.dart';

class _MockProgress extends Mock implements Progress {}

void main() {
  const latestVersion = '0.0.0';
  final successProcessResult = ProcessResult(
    42,
    ExitCode.success.code,
    '',
    '',
  );

  group('update', () {
    test('can be instantiated without optional parameters', () {
      expect(
        () => UpdateCommand(logger: Logger()),
        returnsNormally,
      );
    });

    test(
      'handles pub latest version query errors',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenThrow(Exception('oops'));
        final result = await commandRunner.run(['update']);
        expect(result, equals(ExitCode.software.code));
        verify(() => logger.progress('Checking for updates')).called(1);
        verify(() => logger.err('Exception: oops'));
        verifyNever(
          () => pubUpdater.update(
            packageName: any(named: 'packageName'),
            versionConstraint: any(named: 'versionConstraint'),
          ),
        );
      }),
    );

    test(
      'handles pub update errors',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);
        when(
          () => pubUpdater.update(
            packageName: any(named: 'packageName'),
            versionConstraint: any(named: 'versionConstraint'),
          ),
        ).thenThrow(Exception('oops'));
        final result = await commandRunner.run(['update']);
        expect(result, equals(ExitCode.software.code));
        verify(() => logger.progress('Checking for updates')).called(1);
        verify(() => logger.err('Exception: oops'));
        verify(
          () => pubUpdater.update(
            packageName: any(named: 'packageName'),
            versionConstraint: any(named: 'versionConstraint'),
          ),
        ).called(1);
      }),
    );

    test(
      'handles pub update process errors',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        final errorProcessResult = ProcessResult(
          42,
          1,
          '',
          'Oh no! Installing this is not possible right now!',
        );

        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);

        when(
          () => pubUpdater.update(
            packageName: any(named: 'packageName'),
            versionConstraint: any(named: 'versionConstraint'),
          ),
        ).thenAnswer((_) => Future.value(errorProcessResult));

        final result = await commandRunner.run(['update']);

        expect(result, equals(ExitCode.software.code));
        verify(() => logger.progress('Checking for updates')).called(1);
        verify(
          () => logger.err(
            '''Error updating Very Good CLI: Oh no! Installing this is not possible right now!''',
          ),
        );
        verify(
          () => pubUpdater.update(
            packageName: any(named: 'packageName'),
            versionConstraint: any(named: 'versionConstraint'),
          ),
        ).called(1);
      }),
    );

    test(
      'updates when newer version exists',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);
        when(
          () => pubUpdater.update(
            packageName: any(named: 'packageName'),
            versionConstraint: any(named: 'versionConstraint'),
          ),
        ).thenAnswer((_) => Future.value(successProcessResult));

        when(() => logger.progress(any())).thenReturn(_MockProgress());
        final result = await commandRunner.run(['update']);
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('Checking for updates')).called(1);
        verify(() => logger.progress('Updating to $latestVersion')).called(1);
        verify(
          () => pubUpdater.update(
            packageName: packageName,
            versionConstraint: latestVersion,
          ),
        ).called(1);
      }),
    );

    test(
      'does not update when already on latest version',
      withRunner((commandRunner, logger, pubUpdater, printLogs) async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => packageVersion);
        when(() => logger.progress(any())).thenReturn(_MockProgress());
        final result = await commandRunner.run(['update']);
        expect(result, equals(ExitCode.success.code));
        verify(
          () => logger.info('Very Good CLI is already at the latest version.'),
        ).called(1);
        verifyNever(() => logger.progress('Updating to $latestVersion'));
        verifyNever(
          () => pubUpdater.update(
            packageName: packageName,
            versionConstraint: latestVersion,
          ),
        );
      }),
    );
  });
}
