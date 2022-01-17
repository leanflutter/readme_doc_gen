import 'package:args/args.dart';
import 'package:readme_doc_gen/readme_doc_gen.dart';

Future<void> main(List<String> args) async {
  final generator = ReadmeDocGen();

  final argParser = ArgParser();
  argParser.addOption('files', help: '');

  ArgResults argResults = argParser.parse(args);
  if (argResults.wasParsed('files')) {
    List<String> files = (argResults['files'] ?? '').split(',');
    await generator.generate(
      files: files,
    );
  } else {
    print(argParser.usage);
  }
}
