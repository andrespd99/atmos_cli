import 'package:args/command_runner.dart';
import 'package:atmos_cli/src/commands/commands.dart';
import 'package:mason/mason.dart';

/// {@template run_script_command}
/// `atmos script` command which runs a script in the current project.
/// {@endtemplate}
class ScriptCommand extends Command<int> {
  /// {@macro update_command}
  ScriptCommand({
    required Logger logger,
  }) : _logger = logger {
    // very_good create flame_game <args>
    addSubcommand(
      CreateFlameGame(
        logger: logger,
        generatorFromBundle: generatorFromBundle,
        generatorFromBrick: generatorFromBrick,
      ),
    );
  }

  final Logger _logger;

  @override
  String get description => 'Run a script in the current project.';

  /// The [name] of the command. But static.
  static const String commandName = 'script';

  @override
  String get name => commandName;

  @override
  String get invocation => 'atmos script <script-name> [arguments]';
}
