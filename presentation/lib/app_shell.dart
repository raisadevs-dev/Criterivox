import 'dart:async';

import 'package:flutter/material.dart';

import 'app_introduction_page.dart';
import 'bloom_page.dart';
import 'bloom_companion.dart';
import 'civilization_world_portal_page.dart';
import 'civilization_page.dart';
import 'civilization_home_preview_page.dart';
import 'level2_operational_page.dart';
import 'world_portal_page.dart';
import 'human_residence_entry_page.dart';
import 'guest_pass_experience_page.dart';
import 'private_room_page.dart';
import 'collaboration_room_page.dart';
import 'decision_history_page.dart';
import 'decision_desk_page.dart';
import 'results_journal_page.dart';
import 'collaboration_commons_page.dart';
import 'character_focus_page.dart';
import 'chat/character_chat_page.dart';
import 'context/context_intelligence_page.dart';
import 'interaction/bloom.dart';
import 'presentation/criterivox_theme.dart' as criterivox_theme;
import 'presentation/language_mode.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';
import 'data_stewardship_page.dart';
import 'home03_syvax_page.dart';
import 's7/s7_environment_page.dart';
import 'decision_action_quarter_page.dart';
import 'evidence_experiment_quarter_page.dart';

class CriterivoxShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool connectRuntime;
  final CharacterRuntimeClient? runtimeClient;
  final CriterivoxLanguage language;
  final ValueChanged<CriterivoxLanguage>? onLanguageChanged;

  const CriterivoxShell({
    super.key,
    this.isDarkMode = true,
    this.onToggleTheme = _noop,
    this.connectRuntime = true,
    this.runtimeClient,
    this.language = CriterivoxLanguage.auto,
    this.onLanguageChanged,
  });

  static void _noop() {}

  @override
  State<CriterivoxShell> createState() => _ShellState();
}

class _ShellState extends State<CriterivoxShell> {
  late CharacterRuntimeClient runtime;

  final ScrollController _sidebarScrollController =
      ScrollController();

  final TextEditingController task = TextEditingController(
    text: 'Analyze the supplied information in its current context.',
  );

  final TextEditingController data = TextEditingController(
    text: 'Local sample dataset',
  );

  final TextEditingController ctx = TextEditingController(
    text: 'Synthetic local research context',
  );

  PresentationState? state;
  final List<PresentationState> _history = [];

  String page = 'bloom';
  String chatTarget = 'dharen';
  String? focusedCharacter;

  bool busy = false;
  bool railOpen = true;
  bool chatOverlayOpen = false;

  String? sandboxId;
  String? civilizationHome;

  late StreamSubscription<PresentationState> _stateSubscription;
  late StreamSubscription<String> _errorSubscription;
  late StreamSubscription<Map<String, dynamic>> _contextSubscription;
  late StreamSubscription<Map<String, dynamic>> _operationSubscription;

  Map<String, dynamic>? operationState;

  @override
  void initState() {
    super.initState();

    runtime =
        widget.runtimeClient ?? CharacterRuntimeClient();
    runtime.setLanguageMode(widget.language.code);

    _stateSubscription = runtime.states.listen((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        state = value;
        busy = false;

        if (value.taskId != null) {
          _history.removeWhere(
            (item) =>
                item.taskId == value.taskId &&
                item.agentId == value.agentId,
          );

          _history.insert(0, value);
        }
      });
    });

    _errorSubscription = runtime.errors.listen((error) {
      if (!mounted) {
        return;
      }

      setState(() {
        busy = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
    });

    _operationSubscription =
        runtime.operationEvents.listen((event) {
      if (!mounted) {
        return;
      }

      setState(() {
        operationState = event;
      });
    });

    _contextSubscription =
        runtime.contextEvents.listen((event) {
      if (!mounted) {
        return;
      }

      final incomingSandboxId = event['sandbox_id'];

      if (incomingSandboxId != null) {
        setState(() {
          sandboxId = '$incomingSandboxId';
        });
      }
    });

    if (widget.connectRuntime) {
      unawaited(_connectRuntime());
    }
  }

  Future<void> _connectRuntime() async {
    await runtime.loadResearchIdentity();
    await runtime.connect();
  }

  @override
  void didUpdateWidget(covariant CriterivoxShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language.code != widget.language.code) {
      runtime.setLanguageMode(widget.language.code);
    }
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _errorSubscription.cancel();
    _contextSubscription.cancel();
    _operationSubscription.cancel();

    if (widget.runtimeClient == null) {
      unawaited(runtime.dispose());
    }

    _sidebarScrollController.dispose();
    task.dispose();
    data.dispose();
    ctx.dispose();

    super.dispose();
  }

  void open(String value) {
    setState(() {
      page = value;
    });
  }

  void handleBloomActivation(BloomActivation activation) {
    open(activation.route);
  }

  void openCharacterFocus(String id) {
    setState(() => focusedCharacter = id);
    open('character-focus');
  }

  String? _characterHome(String id) {
    const homes = <String, String>{
      'syvax': 'gateway', 'sandre': 'data', 'kaelen': 'data',
      'dharen': 'context', 'anuka': 'context',
      'vivren': 'reasoning', 'tarkis': 'reasoning',
      'pramon': 'decision', 'bodhex': 'decision', 'manis': 'decision',
      'medrus': 'evidence', 'epistre': 'evidence', 'veridat': 'evidence',
      'viveda': 'knowledge',
    };
    return homes[id.toLowerCase()];
  }

  void openCharacterHome(String id) {
    final home = _characterHome(id);
    if (home == null) {
      open('civilization');
      return;
    }
    setState(() => civilizationHome = home);
    open('home-preview');
  }

  void handoffFromBloom() {
    final id = state?.foundationId;

    final confirmed =
        state?.foundationConfirmation == 'user-confirmed' ||
            state?.foundationConfirmation == 'user-corrected';

    if (id == null || !confirmed) {
      open('stewardship');
      return;
    }

    setState(() {
      busy = true;
    });

    runtime.dataAction(
      foundationId: id,
      action: 'handoff',
      recipient: 'dharen',
    );

    open('workspace');
  }

  void buildContext() {
    final id = state?.foundationId;

    if (id == null) {
      open('stewardship');
      return;
    }

    setState(() {
      busy = true;
      page = 'home02';
    });

    runtime.buildContext(
      foundationId: id,
      userIntentContext: {
        'origin': 'Home 02 Context Intelligence',
        'context_token_budget': 4096,
      },
    );
  }

  void adaptContext() {
    final id = state?.foundationId;

    if (id == null) {
      return;
    }

    setState(() {
      busy = true;
    });

    runtime.activateContextManually(
      foundationId: id,
      userIntentContext: {
        'origin': 'Home 02 manual adaptation',
        'manual_activation': true,
        'context_token_budget': 4096,
      },
    );
  }

  void createSandbox() {
    final id = state?.foundationId;

    if (id == null) {
      return;
    }

    runtime.createSandbox(
      foundationId: id,
      variables: {
        'shadow_mode': true,
        'origin': 'Home 02',
      },
    );
  }

  void runSandbox() {
    final id = state?.foundationId;

    if (id == null || sandboxId == null) {
      return;
    }

    runtime.runSandbox(
      foundationId: id,
      sandboxId: sandboxId!,
      overrides: {
        'shadow_mode': true,
        'replay_requested': true,
      },
      taskId: state?.taskId,
    );
  }

  void inspectSandbox() {
    final id = sandboxId;

    if (id != null) {
      runtime.inspectSandbox(id);
    }
  }

  void promoteSandbox() {
    final id = sandboxId;

    if (id != null) {
      runtime.promoteSandbox(id);
    }
  }

  void discardSandbox() {
    final id = sandboxId;

    if (id != null) {
      runtime.discardSandbox(id);

      setState(() {
        sandboxId = null;
      });
    }
  }

  void send(
    String message, {
    String? target,
    List<Map<String, dynamic>> references = const [],
  }) {
    final selected = target ?? chatTarget;

    setState(() {
      busy = true;
      chatTarget = selected;
    });

    runtime.sendChat(
      message: message,
      targetCharacter: selected,
      taskId: state?.taskId,
      data: {
        'dataset': data.text,
        'records': 3,
      },
      context: {
        'description': ctx.text,
        'origin': 'Character Chat',
      },
      references: references,
    );
  }

  void start() {
    final value = task.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter an analysis task before starting.',
          ),
        ),
      );
      return;
    }

    setState(() {
      busy = true;
    });

    runtime.requestApplication(
      intent: 'analyze',
      task: value,
      taskId: state?.taskId,
      data: {
        'dataset': data.text,
        'records': 3,
      },
      context: {
        'description': ctx.text,
        'origin': 'Analysis & Context Workspace',
      },
      source: 'workspace',
    );
  }

  void _openHome(String home) {
    if (home == 'data') {
      open('stewardship');
      return;
    }
    setState(() => civilizationHome = home);
    open('home-preview');
  }

  void _openReasoningRoom(String roomId) {
    setState(() {
      civilizationHome = 'reasoning';
      page = 'reasoning-room';
    });
  }

  void _openLevel2(String home) {
    if (home == 'data') {
      open('stewardship');
      return;
    }

    setState(() => civilizationHome = home);

    if (home == 'decision') {
      _openHome07Inspection();
      return;
    }

    if (home == 'knowledge') {
      _openHome08Inspection();
      return;
    }

    if (home == 'evidence') {
      open('evidence-experiment');
      return;
    }

    open('level2');
  }

  Future<void> _openHome07Inspection() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog.fullscreen(
          child: SafeArea(
            child: Level2OperationalPage(
              homeId: 'decision',
              onBack: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openHome08Inspection() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog.fullscreen(
          child: SafeArea(
            child: Level2OperationalPage(
              homeId: 'knowledge',
              onBack: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      },
    );
  }

  void toggleGlobalChat() {
    setState(() {
      chatOverlayOpen = !chatOverlayOpen;
    });
  }

  void chatWith(String agent) {
    setState(() {
      chatTarget = agent;
      chatOverlayOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    final dharenStates = _history
        .where((item) => item.agentId == 'dharen')
        .toList();

    final workspaceState = state?.agentId == 'dharen'
        ? state
        : (dharenStates.isEmpty
            ? null
            : dharenStates.first);

    return CriterivoxLanguageScope(
      language: widget.language,
      onChanged: widget.onLanguageChanged ?? (_) {},
      child: Scaffold(
        backgroundColor: t.page,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                _Sidebar(
                  page: page,
                  expanded: railOpen,
                  scrollController:
                      _sidebarScrollController,
                  onOpen: open,
                  onToggle: () {
                    setState(() {
                      railOpen = !railOpen;
                    });
                  },
                  language: widget.language,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 12, top: 4),
                          child: CriterivoxLanguageSelector(),
                        ),
                      ),
                      _TopBar(
                        isDarkMode: widget.isDarkMode,
                        onToggleTheme:
                            widget.onToggleTheme,
                        connectionLive: state != null,
                        onSearch: (value) {
                          final q =
                              value.trim().toLowerCase();

                          if (q.isEmpty) {
                            return;
                          }

                          final found = _history
                              .where(
                                (item) =>
                                    (item.taskId ?? '')
                                        .toLowerCase()
                                        .contains(q) ||
                                    (item.task ?? '')
                                        .toLowerCase()
                                        .contains(q),
                              )
                              .toList();

                          if (found.isNotEmpty) {
                            setState(() {
                              state = found.first;
                            });

                            open('workspace');
                          }
                        },
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 260,
                          ),
                          child: _buildPage(
                            workspaceState,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_isCivilizationExperience)
              Positioned(
                left: 16,
                bottom: 18,
                child: BloomCompanion(
                  location: _companionLocation,
                  characterId: focusedCharacter,
                  onReturnToBloom: () => open('bloom'),
                  compact: MediaQuery.sizeOf(context).width < 900,
                ),
              ),

            if (page != 'chat')
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !chatOverlayOpen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: chatOverlayOpen ? 1 : 0,
                    child: Material(
                      color: t.page.withValues(alpha: .98),
                      child: CharacterChatPage(
                    key: const ValueKey(
                      'global-character-chat',
                    ),
                    state: state,
                    busy: busy,
                    selectedAgent: chatTarget,
                    onSelectAgent: (agent) {
                      setState(() {
                        chatTarget = agent;
                      });
                    },
                    onSend: (message, agent, references) {
                      send(
                        message,
                        target: agent,
                        references: references,
                      );
                    },
                    onOpenTask: () {
                      setState(() {
                        chatOverlayOpen = false;
                      });
                      open('workspace');
                    },
                    onConfirmInterpretation: (accepted) {
                      final id = state?.inputConfirmationId;
                      if (id != null) {
                        runtime.confirmChatInterpretation(
                          confirmationId: id,
                          accepted: accepted,
                        );
                      }
                    },
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              right: 18,
              bottom: 18,
              child: Semantics(
                button: true,
                toggled: chatOverlayOpen,
                label: chatOverlayOpen
                    ? 'Close character chat'
                    : 'Open character chat',
                child: FloatingActionButton(
                  key: const ValueKey('global-character-chat-launcher'),
                  tooltip: chatOverlayOpen
                      ? 'Close character chat'
                      : 'Open character chat',
                  onPressed: toggleGlobalChat,
                  child: Icon(
                    chatOverlayOpen
                        ? Icons.close_rounded
                        : Icons.forum_rounded,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  bool get _isCivilizationExperience => const {
        'bloom', 'civilization', 'home-preview', 'level2',
        'reasoning-room', 'character-focus', 'decision-action',
        'evidence-experiment',
      }.contains(page);

  String get _companionLocation {
    if (page == 'bloom') return 'bloom';
    if (page == 'civilization') return 'civilization';
    if (page == 'home-preview') return 'home';
    if (page == 'level2') return 'level2';
    if (page == 'reasoning-room') return 'reasoning-room';
    if (page == 'character-focus') return 'character-focus';
    return 'home';
  }

  Widget _buildPage(
    PresentationState? workspaceState,
  ) {
    if (page == 'reasoning-room') {
      return const S7EnvironmentPage(
        key: ValueKey('reasoning-room'),
      );
    }

    switch (page) {
      case 'character-focus':
        return CharacterFocusPage(
          key: ValueKey('character-focus-${focusedCharacter ?? 'unknown'}'),
          characterId: focusedCharacter ?? 'dharen',
          onBack: () => open('civilization'),
          onOpenHome: focusedCharacter == null
              ? null
              : () => openCharacterHome(focusedCharacter!),
        );

      case 'decision-desk':
        return DecisionDeskPage(onResults: () => open('results-journal'));

      case 'results-journal':
        return ResultsJournalPage(onDecisionDesk: () => open('decision-desk'));

      case 'meeting-hall':
        return CollaborationCommonsPage(destination: CollaborationDestination.meetingHall, onDecisionDesk: () => open('decision-desk'));

      case 'project-rooms':
        return CollaborationCommonsPage(destination: CollaborationDestination.projectRooms, onDecisionDesk: () => open('decision-desk'));

      case 'shared-workspaces':
        return CollaborationCommonsPage(destination: CollaborationDestination.sharedWorkspaces, onDecisionDesk: () => open('decision-desk'));

      case 'decision-action':
        return DecisionActionQuarterPage(
          key: const ValueKey('decision-action'),
          onBack: () => open('home-preview'),
          onOpenHumanDecisionWorkspace: () => open('private-room'),
        );

      case 'evidence-experiment':
        return EvidenceExperimentQuarterPage(
          key: const ValueKey('evidence-experiment'),
          onBack: () => open('home-preview'),
          onOpenHumanDecisionWorkspace: () => open('private-room'),
        );

      case 'home-preview':
        return CivilizationHomePreviewPage(
          key: const ValueKey('home-preview'),
          homeId: civilizationHome ?? 'context',
          onBack: () => open('civilization'),
          onOpenOperationalHome: _openLevel2,
          onOpenCharacter: openCharacterFocus,
        );

      case 'level2':
        return Level2OperationalPage(
          key: const ValueKey('level2'),
          homeId: civilizationHome ?? 'context',
          onBack: () => open('home-preview'),
          onEnterRoom: civilizationHome == 'reasoning'
              ? _openReasoningRoom
              : null,
        );

      case 'human-residence-entry':
        return HumanResidenceEntryPage(
          onCreateHouse: () =>
              open('human-residence'),
          onCreateClub: () =>
              open('human-residence'),
          onGuest: () => open('guest'),
        );

      case 'human-residence':
        return HumanResidencePage(
          onGuest: () => open('guest'),
          onWorkspace: () => open('private-room'),
          onPrivateRoom: () => open('private-room'),
          onCollaborationRoom: () => open('collaboration-room'),
          onBloomCapability: handleBloomActivation,
        );

      case 'decision-history':
        return DecisionHistoryPage(onBack: () => open('private-room'));

      case 'private-room':
        return PrivateRoomPage(
          onWorkspace: () => open('workspace'),
          onCollaborationRoom: () => open('collaboration-room'),
        );

      case 'collaboration-room':
        return const CollaborationRoomPage();

      case 'guest':
        return GuestPassPage(
          onWorkspace: () => open('guest-experience'),
        );

      case 'guest-experience':
        return GuestPassExperiencePage(
          onWorkspace: () => open('workspace'),
        );

      case 'civilization':
        return CivilizationPage(
          key: const ValueKey('civilization'),
          state: state,
          onBackToBloom: () => open('bloom'),
          onOpenHome: _openHome,
          onOpenCharacter: openCharacterFocus,
        );

      case 'intro':
        return AppIntroductionPage(
          key: const ValueKey('intro'),
          onOpenWorkspace: () => open('decision-desk'),
          onOpenCivilization: () =>
              open('civilization'),
        );

      case 'chat':
        return CharacterChatPage(
          key: const ValueKey('chat'),
          state: state,
          busy: busy,
          operationState: operationState,
          selectedAgent: chatTarget,
          onSelectAgent: (agent) {
            setState(() {
              chatTarget = agent;
            });
          },
          onSend: (message, agent, references) {
            send(
              message,
              target: agent,
              references: references,
            );
          },
          onOpenTask: () => open('workspace'),
          onConfirmInterpretation: (accepted) {
            final id = state?.inputConfirmationId;
            if (id != null) {
              runtime.confirmChatInterpretation(confirmationId: id, accepted: accepted);
            }
          },
        );

      case 'home02':
        return ContextIntelligencePage(
          key: const ValueKey('home02'),
          state: workspaceState,
          busy: busy,
          task: task,
          data: data,
          contextText: ctx,
          onStart: start,
          onBuildContext: buildContext,
          onManualAdapt: adaptContext,
          onChatCharacter: null,
          onCreateSandbox: createSandbox,
          onRunSandbox: runSandbox,
          onInspectSandbox: inspectSandbox,
          onPromoteSandbox: promoteSandbox,
          onDiscardSandbox: discardSandbox,
          sandboxReady: sandboxId != null,
          initialLayer: 0,
        );

      case 'workspace':
        return ContextIntelligencePage(
          key: const ValueKey('workspace'),
          state: workspaceState,
          busy: busy,
          task: task,
          data: data,
          contextText: ctx,
          onStart: start,
          onBuildContext: buildContext,
          onManualAdapt: adaptContext,
          onChatCharacter: null,
          onCreateSandbox: createSandbox,
          onRunSandbox: runSandbox,
          onInspectSandbox: inspectSandbox,
          onPromoteSandbox: promoteSandbox,
          onDiscardSandbox: discardSandbox,
          sandboxReady: sandboxId != null,
          initialLayer: 2,
        );

      case 'gateway':
        return Home03SyvaxPage(
          key: const ValueKey('gateway'),
          onOpen: open,
        );

      case 'stewardship':
        return DataStewardshipPage(
          key: const ValueKey('stewardship'),
          state: state,
          runtime: runtime,
          onChatCharacter: null,
        );

      case 'bloom':
        return CivilizationWorldPortalPage(
          key: const ValueKey('world-portal'),
          state: state,
          onOpenCivilization: () => open('civilization'),
          onOpenCapability: handleBloomActivation,
          onStewardship: () => open('stewardship'),
          onHandoff: handoffFromBloom,
          onOpenAnalysis: () => open('workspace'),
          busy: busy,
        );

      default:
        return BloomPage(
          key: const ValueKey('bloom'),
          state: state,
          onCapability: (_) {},
          onOpenCapability: handleBloomActivation,
          onStewardship: () => open('stewardship'),
          onHandoff: handoffFromBloom,
          onOpenAnalysis: () => open('workspace'),
          busy: busy,
        );
    }
  }
}


class _TopBar extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool connectionLive;
  final ValueChanged<String> onSearch;

  const _TopBar({
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.connectionLive,
    required this.onSearch,
  });

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: widget.onSearch,
              style: TextStyle(color: t.text),
              decoration: InputDecoration(
                hintText: 'Search research history',
                hintStyle: TextStyle(color: t.mutedText),
                prefixIcon: Icon(Icons.search_rounded, color: t.mutedText),
                filled: true,
                fillColor: t.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.circle,
            size: 10,
            color: widget.connectionLive ? Colors.green : t.mutedText,
          ),
          const SizedBox(width: 6),
          Text(
            widget.connectionLive ? 'Connected' : 'Offline',
            style: TextStyle(color: t.mutedText, fontSize: 12),
          ),
          IconButton(
            tooltip: widget.isDarkMode ? 'Use light theme' : 'Use dark theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: t.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;

  const _BrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = criterivox_theme.CriterivoxTheme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool expanded;

  const _StatusCard({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(expanded ? 12 : 8),
      decoration: BoxDecoration(
        color: t.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: expanded
          ? Row(
              children: [
                Icon(Icons.circle, size: 10, color: t.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Research workspace ready',
                    style: TextStyle(
                      color: t.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Icon(Icons.circle, size: 10, color: t.primary),
    );
  }
}

class _Sidebar extends StatefulWidget {
  final String page;
  final bool expanded;
  final ScrollController scrollController;
  final ValueChanged<String> onOpen;
  final VoidCallback onToggle;
  final CriterivoxLanguage language;

  const _Sidebar({
    required this.page,
    required this.expanded,
    required this.scrollController,
    required this.onOpen,
    required this.onToggle,
    required this.language,
  });

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _ChildNav {
  final String label;
  final String page;

  const _ChildNav(this.label, this.page);
}

class _SidebarState extends State<_Sidebar> {
  bool humanTerritoryOpen = true;
  bool civilizationOpen = true;

  Widget _section(
    String label,
    bool expanded,
    dynamic t,
  ) {
    if (!expanded) {
      return const SizedBox(height: 12);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: t.mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
      ),
    );
  }

  Widget _nav(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
    bool expanded,
    dynamic t, {
    bool indent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: indent && expanded ? 12 : 0,
        bottom: 4,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 10 : 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? t.primary.withValues(alpha: .14) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? t.primary : t.mutedText,
                size: 20,
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? t.text : t.mutedText,
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(
    String label,
    IconData icon,
    bool open,
    bool selected,
    VoidCallback onTap,
    bool expanded,
    dynamic t,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 10 : 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? t.primary.withValues(alpha: .14) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? t.primary : t.mutedText,
                size: 20,
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? t.text : t.mutedText,
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  open
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: t.mutedText,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _subgroup(
    String label,
    IconData icon,
    List<_ChildNav> children,
    dynamic t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _group(
          label,
          icon,
          true,
          children.any((child) => child.page == widget.page),
          () {},
          true,
          t,
        ),
        ...children.map(
          (child) => _nav(
            child.label,
            Icons.chevron_right_rounded,
            child.page == widget.page,
            () => widget.onOpen(child.page),
            true,
            t,
            indent: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    final expanded = widget.expanded;
    final strings = CriterivoxStrings(widget.language);
    final width = expanded ? 244.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: width,
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: .96),
        border: Border(right: BorderSide(color: t.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              expanded ? 18 : 4, 18, expanded ? 10 : 4, 14,
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                _BrandMark(size: expanded ? 34 : 28),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Criterivox',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  width: expanded ? null : 32,
                  height: expanded ? null : 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: expanded
                        ? 'Collapse sidebar'
                        : 'Open sidebar',
                    onPressed: widget.onToggle,
                    icon: Icon(
                      expanded
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: t.mutedText,
                      size: expanded ? 24 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: widget.scrollController,
              thumbVisibility: expanded,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                primary: false,
                padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8),
                child: Column(
                  children: [
                    _StatusCard(expanded: expanded),
                    const SizedBox(height: 18),
                    _section(strings.startHere, expanded, t),
                    _nav(
                      strings.appIntroduction,
                      Icons.auto_awesome_rounded,
                      widget.page == 'intro',
                      () => widget.onOpen('intro'),
                      expanded, t,
                    ),
                    const SizedBox(height: 12),
                    _nav(
                      'Criterivox Workers / Bloom',
                      Icons.auto_awesome_rounded,
                      const {'bloom','civilization','home-preview','level2','character-focus','reasoning-room'}.contains(widget.page),
                      () => widget.onOpen('bloom'),
                      expanded, t,
                    ),
                    const SizedBox(height: 12),

                    _group(
                      strings.humanTerritory,
                      Icons.home_work_rounded,
                      humanTerritoryOpen,
                      widget.page == 'human-residence' ||
                          widget.page == 'human-residence-entry' ||
                          widget.page == 'private-room' ||
                          widget.page == 'decision-desk' ||
                          widget.page == 'results-journal' ||
                          widget.page == 'meeting-hall' ||
                          widget.page == 'project-rooms' ||
                          widget.page == 'shared-workspaces' ||
                          widget.page == 'guest',
                      () => setState(() {
                        humanTerritoryOpen = !humanTerritoryOpen;
                      }),
                      expanded, t,
                    ),
                    if (expanded && humanTerritoryOpen) ...[
                      _section(strings.loginSignup, true, t),
                                            _nav(strings.signUpLogin, Icons.person_rounded,
                          widget.page == 'human-residence-entry',
                          () => widget.onOpen('human-residence-entry'),
                          true, t, indent: true),
                      _nav(strings.guestPass, Icons.confirmation_number_rounded,
                          widget.page == 'guest',
                          () => widget.onOpen('guest'),
                          true, t, indent: true),
                      _nav(strings.privateRoom, Icons.lock_outline_rounded,
                          widget.page == 'private-room',
                          () => widget.onOpen('private-room'),
                          true, t, indent: true),
                      _nav(strings.decisionDesk, Icons.fact_check_outlined,
                          widget.page == 'decision-desk',
                          () => widget.onOpen('decision-desk'),
                          true, t, indent: true),
                      _nav('Results Journal', Icons.menu_book_outlined,
                          widget.page == 'results-journal',
                          () => widget.onOpen('results-journal'),
                          true, t, indent: true),
                      _subgroup(strings.collaborationCommons, Icons.forum_outlined, [
                        _ChildNav(strings.meetingHall, 'meeting-hall'),
                        _ChildNav(strings.projectRooms, 'project-rooms'),
                        _ChildNav(strings.sharedWorkspaces, 'shared-workspaces'),
                      ], t),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}