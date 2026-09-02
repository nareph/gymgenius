// tool/deduplicate_exercises.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  final definitionsDir = Directory(
    'lib/engines/workout_engine/shared/exercises/catalog/definitions',
  );

  if (!await definitionsDir.exists()) {
    stderr.writeln('Directory not found: ${definitionsDir.path}');
    exit(1);
  }

  final files = definitionsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('_exercises.dart'))
      .toList();

  if (files.isEmpty) {
    stderr.writeln('No *_exercises.dart files found.');
    exit(1);
  }

  print('📂 Found ${files.length} definition files.');

  // Global map: normalized name -> ExerciseEntry
  final globalEntries = <String, ExerciseEntry>{};

  for (final file in files) {
    print('📄 Processing ${file.path}...');
    final content = await file.readAsString();
    final entries = _extractEntries(content);

    if (entries.isEmpty) {
      print('⚠️  No entries found in ${file.path} – skipping.');
      continue;
    }

    // Deduplicate within this file by normalized name.
    final localMap = <String, List<ExerciseEntry>>{};
    for (final entry in entries) {
      final key = _normalizeName(entry.name);
      localMap.putIfAbsent(key, () => []).add(entry);
    }

    final mergedLocal = <ExerciseEntry>[];
    for (final group in localMap.values) {
      if (group.length == 1) {
        mergedLocal.add(group.first);
      } else {
        final merged = _mergeEntries(group);
        mergedLocal.add(merged);
        print(
            '🔀 Merged ${group.length} duplicates in ${file.path} -> "${merged.name}"');
      }
    }

    // Merge with global entries.
    final finalEntries = <ExerciseEntry>[];
    for (final entry in mergedLocal) {
      final key = _normalizeName(entry.name);
      final existing = globalEntries[key];
      if (existing != null) {
        // Merge splits.
        final mergedSplits = {
          ...existing.compatibleSplits,
          ...entry.compatibleSplits
        };
        globalEntries[key] = existing.copyWith(compatibleSplits: mergedSplits);
        print(
          '🔗 Merged "${entry.name}" from ${file.path} into existing global entry '
          '(now has ${mergedSplits.length} splits).',
        );
      } else {
        globalEntries[key] = entry;
        finalEntries.add(entry);
      }
    }

    // Rebuild file content.
    final newContent = _rebuildFileContent(file.path, finalEntries);
    await file.writeAsString(newContent);
    print('✅ Updated ${file.path}');
  }

  print('🎉 Deduplication complete.');
}

/// Normalize an exercise name for grouping.
String _normalizeName(String name) {
  var normalized = name
      .replaceAll(RegExp(r'\([^)]*\)'), '')
      .replaceAll(RegExp(r'\[[^\]]*\]'), '')
      .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  // Remove common qualifiers.
  final removeWords = [
    'bench',
    'machine',
    'selectorized',
    'smith',
    'cable',
    'band',
    'barbell',
    'dumbbell',
    'kettlebell',
    'homemade',
    'chair',
    'resistance',
    'push',
    'pull',
    'press',
    'raise',
    'row',
    'fly',
    'curl',
    'extension',
    'kickback',
    'shrug',
  ];
  for (final word in removeWords) {
    normalized = normalized.replaceAll(' $word ', ' ');
    if (normalized.startsWith('$word ')) {
      normalized = normalized.substring(word.length + 1);
    }
    if (normalized.endsWith(' $word')) {
      normalized = normalized.substring(0, normalized.length - word.length - 1);
    }
  }

  return normalized.trim();
}

/// Extract all ExercisePoolEntry texts from Dart source.
List<ExerciseEntry> _extractEntries(String content) {
  final entries = <ExerciseEntry>[];
  // Find the list start: const List<ExercisePoolEntry> name = [
  final listStart =
      RegExp(r'const List<ExercisePoolEntry> \w+ = \[').firstMatch(content);
  if (listStart == null) return entries;

  int startIdx = listStart.end; // position after '['
  // Find the matching closing ']'.
  int braceCount = 1;
  int i = startIdx;
  bool inString = false;
  bool inComment = false;
  while (i < content.length && braceCount > 0) {
    final char = content[i];
    if (inComment) {
      if (char == '\n') inComment = false;
      i++;
      continue;
    }
    if (!inString && char == '/') {
      final next = i + 1 < content.length ? content[i + 1] : null;
      if (next == '/') {
        inComment = true;
        i += 2;
        continue;
      }
    }
    if (char == '"' || char == "'") {
      // Handle strings.
      final quote = char;
      inString = !inString;
      // We need to handle escape sequences; skip the next char if it's backslash.
      i++;
      while (i < content.length) {
        if (content[i] == '\\') {
          i += 2; // skip backslash and escaped char.
          continue;
        }
        if (content[i] == quote) {
          inString = !inString;
          i++;
          break;
        }
        i++;
      }
      continue;
    }
    if (inString) {
      i++;
      continue;
    }
    if (char == '[')
      braceCount++;
    else if (char == ']') braceCount--;
    i++;
  }

  if (braceCount != 0) return entries; // malformed.

  final listBody =
      content.substring(startIdx, i - 1); // exclude the closing ']'

  // Now split by ExercisePoolEntry(.
  final parts = <String>[];
  int pos = 0;
  while (pos < listBody.length) {
    final start = listBody.indexOf('ExercisePoolEntry(', pos);
    if (start == -1) break;
    // Find the matching closing ) for this entry.
    int parenCount = 0;
    int j = start;
    bool inString2 = false;
    while (j < listBody.length) {
      final char = listBody[j];
      if (char == '"' || char == "'") {
        final quote = char;
        inString2 = !inString2;
        j++;
        while (j < listBody.length) {
          if (listBody[j] == '\\') {
            j += 2;
            continue;
          }
          if (listBody[j] == quote) {
            inString2 = !inString2;
            j++;
            break;
          }
          j++;
        }
        continue;
      }
      if (!inString2) {
        if (char == '(')
          parenCount++;
        else if (char == ')') {
          parenCount--;
          if (parenCount == 0) {
            // Found the end of this entry.
            final entryText = listBody.substring(start, j + 1);
            parts.add(entryText);
            pos = j + 1;
            break;
          }
        }
      }
      j++;
    }
    if (parenCount != 0) break; // malformed
  }

  for (final text in parts) {
    final entry = _parseEntry(text);
    if (entry != null) entries.add(entry);
  }

  return entries;
}

/// Parse a single ExercisePoolEntry text block.
ExerciseEntry? _parseEntry(String text) {
  final idMatch = RegExp(r"id:\s*'([^']*)'").firstMatch(text);
  if (idMatch == null) return null;
  final id = idMatch.group(1)!;

  final nameMatch = RegExp(r"name:\s*'([^']*)'").firstMatch(text);
  if (nameMatch == null) return null;
  final name = nameMatch.group(1)!;

  // Extract compatibleSplits.
  final splits = <String>{};
  final splitsStart = text.indexOf('compatibleSplits: {');
  if (splitsStart != -1) {
    int braceCount = 0;
    int j = splitsStart + 'compatibleSplits: {'.length - 1;
    bool inString = false;
    while (j < text.length) {
      final char = text[j];
      if (char == '"' || char == "'") {
        final quote = char;
        inString = !inString;
        j++;
        while (j < text.length) {
          if (text[j] == '\\') {
            j += 2;
            continue;
          }
          if (text[j] == quote) {
            inString = !inString;
            j++;
            break;
          }
          j++;
        }
        continue;
      }
      if (!inString) {
        if (char == '{')
          braceCount++;
        else if (char == '}') {
          braceCount--;
          if (braceCount == 0) {
            // End of compatibleSplits.
            final splitsText = text.substring(splitsStart, j + 1);
            final matches = RegExp(r"'([^']*)'").allMatches(splitsText);
            for (final m in matches) {
              splits.add(m.group(1)!);
            }
            break;
          }
        }
      }
      j++;
    }
  }

  return ExerciseEntry(
    id: id,
    name: name,
    compatibleSplits: splits,
    rawText: text,
  );
}

/// Merge multiple entries into one.
ExerciseEntry _mergeEntries(List<ExerciseEntry> entries) {
  final base = entries.first;
  final allSplits = <String>{};
  for (final e in entries) {
    allSplits.addAll(e.compatibleSplits);
  }
  // Keep the first entry's name as base, or choose longest.
  String bestName = base.name;
  for (final e in entries) {
    if (e.name.length > bestName.length) {
      bestName = e.name;
    }
  }
  return ExerciseEntry(
    id: base.id,
    name: bestName,
    compatibleSplits: allSplits,
    rawText: base.rawText,
  );
}

/// Rebuild the file content with the given entries.
String _rebuildFileContent(String filePath, List<ExerciseEntry> entries) {
  final original = File(filePath).readAsStringSync();
  final lines = original.split('\n');
  final header = <String>[];
  bool insideList = false;
  for (final line in lines) {
    if (!insideList) {
      header.add(line);
      if (line.contains('const List<ExercisePoolEntry>') &&
          line.contains('=[')) {
        insideList = true;
      }
    }
    if (insideList && line.contains('];')) {
      insideList = false;
    }
  }

  // Extract variable name.
  final varMatch =
      RegExp(r'const List<ExercisePoolEntry> (\w+) =').firstMatch(original);
  final varName = varMatch?.group(1) ?? 'unknownDefinitions';

  // Generate entries.
  final buffer = StringBuffer();
  for (final entry in entries) {
    // Reconstruct using rawText but replace compatibleSplits.
    String entryText = entry.rawText;
    // Replace compatibleSplits block.
    final splitsStr =
        entry.compatibleSplits.map((s) => "      '$s',").join('\n');
    final newSplitsBlock = 'compatibleSplits: {\n$splitsStr\n    },';
    final oldSplitsPattern =
        RegExp(r'compatibleSplits:\s*\{[^}]*\},', dotAll: true);
    entryText = entryText.replaceAll(oldSplitsPattern, newSplitsBlock);
    // Ensure comma at the end.
    if (!entryText.trim().endsWith(',')) {
      final lastParen = entryText.lastIndexOf(')');
      if (lastParen != -1 && lastParen == entryText.length - 1) {
        entryText = entryText.substring(0, lastParen) + ',)';
      }
    }
    buffer.writeln('  $entryText');
  }

  final result = StringBuffer();
  for (final line in header) {
    if (line.contains('const List<ExercisePoolEntry>') && line.contains('=[')) {
      result.writeln('const List<ExercisePoolEntry> $varName = [');
    } else if (line.contains('];')) {
      // skip, we'll write closing later.
    } else {
      result.writeln(line);
    }
  }
  result.write(buffer.toString());
  result.writeln('];');
  return result.toString();
}

// ============================================================
// Data class
// ============================================================

class ExerciseEntry {
  final String id;
  final String name;
  final Set<String> compatibleSplits;
  final String rawText;

  ExerciseEntry({
    required this.id,
    required this.name,
    required this.compatibleSplits,
    required this.rawText,
  });

  ExerciseEntry copyWith({
    String? id,
    String? name,
    Set<String>? compatibleSplits,
    String? rawText,
  }) {
    return ExerciseEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      compatibleSplits: compatibleSplits ?? this.compatibleSplits,
      rawText: rawText ?? this.rawText,
    );
  }
}
