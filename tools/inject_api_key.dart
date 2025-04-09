import 'dart:io';

void main() async {
  final envFile = File('.env');
  final templateFile = File('web/template_index.html');
  final outputFile = File('web/index.html');

  if (!envFile.existsSync() || !templateFile.existsSync()) {
    print('❌ Missing .env or template_index.html file.');
    exit(1);
  }

  final envLines = await envFile.readAsLines();
  final apiKeyLine = envLines.firstWhere(
    (line) => line.startsWith('GOOGLE_MAPS_API_KEY='),
    orElse: () => '',
  );

  final apiKey =
      apiKeyLine.split('=').length > 1 ? apiKeyLine.split('=')[1] : '';

  if (apiKey.isEmpty) {
    print('❌ API key not found in .env');
    exit(1);
  }

  final htmlTemplate = await templateFile.readAsString();
  final outputHtml = htmlTemplate.replaceAll('{{API_KEY}}', apiKey);
  await outputFile.writeAsString(outputHtml);

  print('✅ index.html generated with injected API key!');
}
