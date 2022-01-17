import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:source_span/source_span.dart';

const _kMdMark = '<!-- README_DOC_GEN -->';

class ReadmeDocGen {
  Future<void> generate({
    required List<String> files,
  }) async {
    String renderedString = '';

    for (var filePath in files) {
      String content = File(filePath).readAsStringSync();

      SourceFile sourceFile = SourceFile.fromString(content);
      ParseStringResult parseStringResult = parseString(content: content);

      for (var declaration in parseStringResult.unit.declarations) {
        if (declaration is ClassOrMixinDeclaration) {
          renderedString += "### ${declaration.name}\n";
          renderedString += "\n";
          renderedString += "#### Methods\n";
          renderedString += "\n";

          for (var member in declaration.members) {
            if (member is MethodDeclaration) {
              MethodDeclaration methodDeclaration = member;
              String name = methodDeclaration.name.toString();
              String description = sourceFile
                  .getText(methodDeclaration.offset, methodDeclaration.end)
                  .split('\n')
                  .where((e) => e.trim().startsWith('///'))
                  .map((e) => e.replaceAll('///', '').trim())
                  .where((e) => !e.startsWith('@platforms'))
                  .join('\n');
              String platforms = sourceFile
                  .getText(methodDeclaration.offset, methodDeclaration.end)
                  .split('\n')
                  .where((e) => e.contains('@platforms'))
                  .map((e) => e.replaceAll('/// @platforms ', '').trim())
                  .join()
                  .trim();

              if (name.startsWith('_')) continue;
              if (description.isEmpty) continue;

              String mdPlatforms = '';

              if (platforms.isNotEmpty) {
                mdPlatforms += ' ';
                mdPlatforms +=
                    platforms.split(',').map((e) => ' `$e`').join(' ');
              }

              renderedString += "##### ${name}${mdPlatforms}\n";
              renderedString += "\n";
              renderedString += "${description}\n";
              renderedString += "\n";
            }
          }
        }
      }
    }

    File mdFile = File('README.md');
    String mdString = mdFile.readAsStringSync();

    int markIndexS = mdString.indexOf(_kMdMark) + _kMdMark.length;
    int markIndexE = mdString.lastIndexOf(_kMdMark);

    String newContent = '';
    newContent += mdString.substring(0, markIndexS);
    newContent += '\n$renderedString\n';
    newContent += mdString.substring(markIndexE);

    mdFile.writeAsStringSync(newContent);
  }
}
