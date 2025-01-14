import 'dart:io';

import 'package:atmos_cli/src/commands/create/templates/template.dart';
import 'package:atmos_cli/src/commands/run_script/scripts/setup_firebase/setup_firebase_bundle.dart';
import 'package:mason_logger/src/mason_logger.dart';

class SetupFirebaseTemplate extends Template {
  SetupFirebaseTemplate()
      : super(
          name: 'setup-firebase',
          bundle: setupFirebaseScriptBundle,
          help: 'Setup Firebase in a Flutter project.',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    await _runSetupScript(logger, outputDir);
  }

  Future<void> _runSetupScript(Logger logger, Directory outputDir) async {}
}
