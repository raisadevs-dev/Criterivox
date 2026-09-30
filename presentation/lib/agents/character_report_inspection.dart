import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../human/residence/store.dart';
import '../presentation/shared/api_client.dart';

class CharacterReportInspection extends StatelessWidget {
  final String reportId;
  final String characterName;
  const CharacterReportInspection({super.key, required this.reportId, required this.characterName});

  Future<Map<String, dynamic>?> _load() async {
    final residence = await HumanResidenceStore().load();
    final token = residence?.metadata['session_token']?.toString();
    if (token == null || token.isEmpty) return null;
    final response = await http.get(
      CriterivoxApi.uri('/api/human-residence/case-report/$reportId?session_token=${Uri.encodeQueryComponent(token)}'),
    ).timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    final body = jsonDecode(response.body);
    return body is Map && body['report'] is Map ? Map<String, dynamic>.from(body['report']) : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator());
        }
        final report = snapshot.data;
        if (report == null) return const SizedBox.shrink();
        final sections = report['sections'] is List ? (report['sections'] as List).whereType<Map>().toList() : <Map>[];
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$characterName · Character Report', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text('${report['human_id'] ?? 'CR-27'} · ${report['title'] ?? ''}', style: const TextStyle(fontSize: 10)),
            const SizedBox(height: 10),
            ...sections.map((section) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${section['title'] ?? ''}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${section['text'] ?? ''}', style: const TextStyle(fontSize: 9, height: 1.35)),
              ]),
            )),
          ]),
        );
      },
    );
  }
}
