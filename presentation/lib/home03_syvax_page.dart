import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'interaction/home03_bloom.dart';
import 'interaction/syvax.dart';
import 'presentation/criterivox_theme.dart';

class Home03SyvaxPage extends StatefulWidget {
  final ValueChanged<String> onOpen;

  const Home03SyvaxPage({
    super.key,
    required this.onOpen,
  });

  @override
  State<Home03SyvaxPage> createState() => _Home03SyvaxPageState();
}

class _Home03SyvaxPageState extends State<Home03SyvaxPage> {
  final controller = TextEditingController();
  final correction = TextEditingController();

  Map<String, dynamic>? plan;
  Map<String, dynamic>? bloom;
  Map<String, dynamic>? rendered;

  String mode = 'HITL';
  String view = 'executive';
  bool busy = false;

  Uri get base {
    final scheme = Uri.base.scheme == 'https' ? 'https' : 'http';
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;

    return Uri.parse(
      '$scheme://$host:${const String.fromEnvironment(
        'CRITERIVOX_BACKEND_PORT',
        defaultValue: '8000',
      )}',
    );
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      base.replace(path: '${base.path}$path'),
      headers: const {
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Backend returned an invalid response.');
    }

    final data = Map<String, dynamic>.from(decoded);

    if (response.statusCode >= 400) {
      throw Exception(
        '${data['detail'] ?? data['safety'] ?? 'Request failed'}',
      );
    }

    return data;
  }

  Future<void> loadBloom() async {
    try {
      final response = await http.get(
        base.replace(
          path: '${base.path}/api/bloom/state',
        ),
      );

      if (response.statusCode < 300 && mounted) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          setState(() {
            bloom = Map<String, dynamic>.from(decoded);
          });
        }
      }
    } catch (_) {
      // Bloom state is supplementary. The main Syvax workflow
      // should remain usable when the Bloom endpoint is unavailable.
    }
  }

  Future<void> dispatch(String text) async {
    if (text.trim().isEmpty || busy) {
      return;
    }

    setState(() {
      busy = true;
    });

    try {
      final data = await post(
        '/api/syvax/dispatch',
        {
          'message': text.trim(),
          'data': {
            'origin': 'home03-syvax',
          },
          'context': {
            'entered_through': 'Home 03',
          },
        },
      );

      final dispatchedPlan = data['plan'];

      if (dispatchedPlan is! Map) {
        throw Exception('Syvax dispatch returned no valid plan.');
      }

      final intent = dispatchedPlan['intent'];

      final intentType = intent is Map
          ? '${intent['intent_type'] ?? 'task'}'
          : 'task';

      final renderResult = await post(
        '/api/syvax/render',
        {
          'text': text.trim(),
          'intent': intentType,
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        plan = data;
        rendered = renderResult;
      });

      await loadBloom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> attach() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.length > 8 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Universal Dropzone accepts files up to 8 MB.',
            ),
          ),
        );
      }
      return;
    }

    try {
      final response = await post(
        '/api/home03/ingest',
        {
          'filename': file.name,
          'content_type': file.extension,
          'content_base64': base64Encode(bytes),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sent to Sandre · foundation ${response['foundation_id']}',
            ),
          ),
        );
      }

      await loadBloom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadBloom();
  }

  @override
  void dispose() {
    controller.dispose();
    correction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);

    final rawPlan = plan?['plan'];

    final steps = rawPlan is Map && rawPlan['steps'] is List
        ? List<Map<String, dynamic>>.from(
            (rawPlan['steps'] as List).map(
              (entry) => Map<String, dynamic>.from(
                entry as Map,
              ),
            ),
          )
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: theme.page,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                30,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HOME 03 · SYVAX',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Interaction & Gateway',
                                style: TextStyle(
                                  color: theme.text,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Dialogue · routing · safety · steering · output translation',
                                style: TextStyle(
                                  color: theme.mutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _mode(theme),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 1000) {
                          return Column(
                            children: [
                              _radar(theme, steps),
                              const SizedBox(height: 14),
                              Syvax(
                                onSubmit: dispatch,
                                busy: busy,
                              ),
                              const SizedBox(height: 14),
                              _bloom(theme),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _radar(theme, steps),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Syvax(
                                    onSubmit: dispatch,
                                    busy: busy,
                                  ),
                                  const SizedBox(height: 14),
                                  _bloom(theme),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _dropzone(theme),
                    const SizedBox(height: 14),
                    _workbench(theme, rawPlan),
                    const SizedBox(height: 14),
                    _steering(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mode(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Row(
        children: [
          for (final currentMode in ['HITL', 'HOTL'])
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      await post(
                        '/api/syvax/oversight',
                        {
                          'mode': currentMode,
                        },
                      );

                      await post(
                        '/api/bloom/mode',
                        {
                          'mode': currentMode,
                        },
                      );

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        mode = currentMode;
                      });

                      await loadBloom();
                    },
              style: TextButton.styleFrom(
                backgroundColor: mode == currentMode
                    ? theme.primary.withValues(alpha: .18)
                    : Colors.transparent,
              ),
              child: Text(
                currentMode,
                style: TextStyle(
                  color: mode == currentMode
                      ? theme.text
                      : theme.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _radar(
    CriterivoxTheme theme,
    List<Map<String, dynamic>> steps,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TASK ROUTING RADAR',
                  style: TextStyle(
                    color: theme.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                plan == null ? 'READY' : '${steps.length} STAGES',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _routeNode(
                theme,
                'SYVAX',
                'reception',
              ),
              for (final step in steps)
                _routeNode(
                  theme,
                  '${step['actor']}',
                  '${step['home']} · ${step['capability']}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            plan == null
                ? 'Send a task through Syvax to compile and dispatch an adaptive execution plan.'
                : pText(plan),
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String pText(Map<String, dynamic>? data) {
    final currentPlan = data?['plan'];

    if (currentPlan is! Map) {
      return '';
    }

    final intent = currentPlan['intent'];

    final intentType = intent is Map
        ? '${intent['intent_type'] ?? 'task'}'
        : 'task';

    final confidence = intent is Map
        ? ((intent['confidence'] ?? 0) as num).toDouble()
        : 0.0;

    return '$intentType · confidence ${(confidence * 100).round()}% · ${currentPlan['task_id']}';
  }

  Widget _routeNode(
    CriterivoxTheme theme,
    String title,
    String subtitle,
  ) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: title == 'SYVAX'
              ? theme.primary
              : theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropzone(CriterivoxTheme theme) {
    return InkWell(
      onTap: attach,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.primary.withValues(alpha: .55),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.upload_file_rounded,
              color: theme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UNIVERSAL DROPZONE',
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Voice/image/document/code payload → normalize → Sandre / Data Foundation',
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'ATTACH',
              style: TextStyle(
                color: theme.primary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workbench(
    CriterivoxTheme theme,
    dynamic currentPlan,
  ) {
    String content;

    if (view == 'json') {
      content = const JsonEncoder.withIndent('  ').convert(
        {
          'plan': null,
          'rendered': null,
          'bloom': null,
        },
      );

      content = const JsonEncoder.withIndent('  ').convert(
        {
          'plan': plan,
          'rendered': rendered,
          'bloom': bloom,
        },
      );
    } else if (view == 'reasoning') {
      if (currentPlan is Map && currentPlan['steps'] is List) {
        final rawSteps = currentPlan['steps'] as List;

        content = rawSteps.asMap().entries.map((entry) {
          final value = entry.value;

          if (value is Map) {
            return '${entry.key + 1}. '
                '${value['actor']} · ${value['reason']}';
          }

          return '${entry.key + 1}. $value';
        }).join('\n');
      } else {
        content = 'No execution path yet.';
      }
    } else if (rendered != null) {
      final components = rendered!['components'];
      content = components?.toString() ?? 'No rendered output yet.';
    } else if (currentPlan == null) {
      content = 'No execution result yet.';
    } else {
      final rawSteps = currentPlan['steps'];

      if (rawSteps is List) {
        final actors = rawSteps.map((entry) {
          if (entry is Map) {
            return '${entry['actor']}';
          }

          return '$entry';
        }).join(' → ');

        content = 'Syvax routed the request through $actors.';
      } else {
        content = 'Syvax produced an execution plan without stages.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SYVAX LENS · UI WORKBENCH',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final currentView in [
                'executive',
                'reasoning',
                'json',
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        view = currentView;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: view == currentView
                          ? theme.primary.withValues(alpha: .16)
                          : Colors.transparent,
                    ),
                    child: Text(
                      currentView.toUpperCase(),
                      style: TextStyle(
                        color: view == currentView
                            ? theme.primary
                            : theme.mutedText,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            content,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _steering(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: correction,
              decoration: const InputDecoration(
                hintText: 'Add a mid-flight correction or constraint…',
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: plan == null
                ? null
                : () async {
                    try {
                      await post(
                        '/api/syvax/steer',
                        {
                          'task_id': plan!['plan']['task_id'],
                          'correction': correction.text,
                        },
                      );

                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Workflow paused. Correction recorded.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$e'),
                        ),
                      );
                    }
                  },
            child: const Text('Pause & steer'),
          ),
        ],
      ),
    );
  }

  Widget _bloom(CriterivoxTheme theme) {
    final activeHomes = bloom?['active_homes'];
    final traces = bloom?['traces'];
    final checkpoints = bloom?['checkpoints'];

    final activeHomeCount =
        activeHomes is List ? activeHomes.length : 0;

    final traceCount = traces is List ? traces.length : 0;

    final checkpointCount =
        checkpoints is List ? checkpoints.length : 0;

    final bloomMode = bloom?['mode'] ?? mode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🌸 THE BLOOM · 8 HOMES',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$activeHomeCount ACTIVE',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Home03Bloom(
            onOpen: widget.onOpen,
            state: bloom,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mode: $bloomMode · traces $traceCount · checkpoints $checkpointCount',
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 9,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onOpen('stewardship');
                },
                icon: const Icon(
                  Icons.inventory_2_rounded,
                ),
                tooltip: 'Open Data Stewardship',
              ),
            ],
          ),
        ],
      ),
    );
  }
}