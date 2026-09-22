import 'dart:async';

import 'package:flutter/material.dart';

import 'analysis_context_workspace_page.dart';
import 'app_introduction_page.dart';
import 'bloom_page.dart';
import 'civilization_page.dart';
import 'civilization_home_preview_page.dart';
import 'level2_operational_page.dart';
import 'world_portal_page.dart';
import 'human_residence_entry_page.dart';
import 'guest_pass_experience_page.dart';
import 'private_room_page.dart';
import 'collaboration_room_page.dart';
import 'chat/character_chat_page.dart';
import 'context/home02_context_console.dart';
import 'interaction/bloom.dart';
import 'presentation/criterivox_theme.dart' as criterivox_theme;
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';
import 'stewardship_live_workspace_page.dart';

class CriterivoxShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool connectRuntime;
  final CharacterRuntimeClient? runtimeClient;

  const CriterivoxShell({
    super.key,
    this.isDarkMode = true,
    this.onToggleTheme = _noop,
    this.connectRuntime = true,
    this.runtimeClient,
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
      runtime.connect();
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

  void showReserved(String capability) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$capability is reserved for a future capability sprint.',
          ),
        ),
      );
  }

  void handleBloomCapability(
    BloomCapability capability,
  ) {
    if (capability == BloomCapability.stewardship) {
      open('stewardship');
      return;
    }

    if (capability != BloomCapability.analyze) {
      showReserved(
        Bloom.labels[capability] ?? capability.name,
      );
    }
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
    setState(() {
      civilizationHome = home;
    });

    open('home-preview');
  }

  void _openLevel2(String home) {
    setState(() {
      civilizationHome = home;
    });

    open('level2');
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

    return Scaffold(
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
                  onReserved: showReserved,
                  onToggle: () {
                    setState(() {
                      railOpen = !railOpen;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
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

            if (chatOverlayOpen && page != 'chat')
              Positioned.fill(
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
    );
  }

  Widget _buildPage(
    PresentationState? workspaceState,
  ) {
    switch (page) {
      case 'home-preview':
        return CivilizationHomePreviewPage(
          key: const ValueKey('home-preview'),
          homeId: civilizationHome ?? 'context',
          onBack: () => open('civilization'),
          onChat: () => open('chat'),
          onOpenOperationalHome: _openLevel2,
        );

      case 'level2':
        return Level2OperationalPage(
          key: const ValueKey('level2'),
          homeId: civilizationHome ?? 'context',
          onBack: () => open('home-preview'),
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
          onBloomWorkspace: () => open('workspace'),
          onBloomChat: () => open('chat'),
          onBloomStewardship: () => open('stewardship'),
        );

      case 'private-room':
        return PrivateRoomPage(
          onWorkspace: () => open('workspace'),
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
          onOpenChat: () => open('chat'),
          onOpenHome: _openHome,
        );

      case 'intro':
        return AppIntroductionPage(
          key: const ValueKey('intro'),
          onOpenWorkspace: () => open('workspace'),
          onOpenCivilization: () =>
              open('civilization'),
          onOpenChat: () => open('chat'),
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
        );

      case 'home02':
        return Home02ContextConsole(
          key: const ValueKey('home02'),
          state: workspaceState,
          onBuildContext: buildContext,
          onManualAdapt: adaptContext,
          onOpenChat: () => open('chat'),
          onCreateSandbox: createSandbox,
          onRunSandbox: runSandbox,
          onInspectSandbox: inspectSandbox,
          onPromoteSandbox: promoteSandbox,
          onDiscardSandbox: discardSandbox,
          sandboxReady: sandboxId != null,
        );

      case 'workspace':
        return AnalysisContextWorkspacePage(
          key: const ValueKey('workspace'),
          state: workspaceState,
          busy: busy,
          task: task,
          data: data,
          contextText: ctx,
          onStart: start,
          onBuildContext: buildContext,
          onOpenChat: () => open('chat'),
          onChatCharacter: chatWith,
        );

      case 'stewardship':
        return StewardshipLiveWorkspacePage(
          key: const ValueKey('stewardship'),
          state: state,
          runtime: runtime,
          onChatCharacter: chatWith,
        );

      case 'bloom':
      default:
        return BloomPage(
          key: const ValueKey('bloom'),
          state: state,
          onCapability: handleBloomCapability,
          onSub: (value) {
            switch (value) {
              case BloomSuboption.workspace:
                open('workspace');
                break;

              case BloomSuboption.chat:
                open('chat');
                break;

              case BloomSuboption.stewardshipHome:
                open('stewardship');
                break;

              case BloomSuboption.stewardshipChat:
                chatWith('sandre');
                break;
            }
          },
          onSyvax: (message) {
            send(
              message,
              target: 'syvax',
            );
          },
          onStewardship: () =>
              open('stewardship'),
          onHandoff: handoffFromBloom,
          onOpenAnalysis: () =>
              open('workspace'),
          busy: busy,
        );
    }
  }
}


class _Sidebar extends StatefulWidget {
  final String page;
  final bool expanded;
  final ScrollController scrollController;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onReserved;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.page,
    required this.expanded,
    required this.scrollController,
    required this.onOpen,
    required this.onReserved,
    required this.onToggle,
  });

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  bool humanTerritoryOpen = true;
  bool civilizationOpen = true;

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);
    final expanded = widget.expanded;
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
                    _section('START HERE', expanded, t),
                    _nav(
                      'App Introduction',
                      Icons.auto_awesome_rounded,
                      widget.page == 'intro',
                      () => widget.onOpen('intro'),
                      expanded, t,
                    ),
                    const SizedBox(height: 12),

                    _group(
                      'HUMAN TERRITORY',
                      Icons.home_work_rounded,
                      humanTerritoryOpen,
                      widget.page == 'human-residence' ||
                          widget.page == 'human-residence-entry' ||
                          widget.page == 'private-room' ||
                          widget.page == 'collaboration-room' ||
                          widget.page == 'guest',
                      () => setState(() {
                        humanTerritoryOpen = !humanTerritoryOpen;
                      }),
                      expanded, t,
                    ),
                    if (expanded && humanTerritoryOpen) ...[
                      _section('LOGIN / SIGN UP', true, t),
                      _nav('Human Residence', Icons.home_work_rounded,
                          widget.page == 'human-residence',
                          () => widget.onOpen('human-residence'),
                          true, t, indent: true),
                      _nav('Private Room', Icons.lock_outline_rounded,
                          widget.page == 'private-room',
                          () => widget.onOpen('private-room'),
                          true, t, indent: true),
                      _nav('Collaboration Room', Icons.groups_rounded,
                          widget.page == 'collaboration-room',
                          () => widget.onOpen('collaboration-room'),
                          true, t, indent: true),
                      _nav('Decision Desk', Icons.fact_check_outlined,
                          widget.page == 'private-room',
                          () => widget.onOpen('private-room'),
                          true, t, indent: true),
                      _nav('Results Journal', Icons.menu_book_outlined,
                          widget.page == 'private-room',
                          () => widget.onOpen('private-room'),
                          true, t, indent: true),
                      _subgroup('COLLABORATION COMMONS', Icons.forum_outlined, [
                        _ChildNav('Meeting Hall', 'collaboration-room'),
                        _ChildNav('Project Rooms', 'collaboration-room'),
                        _ChildNav('Shared Workspaces', 'collaboration-room'),
                      ], t),
                      _subgroup('GUEST DISTRICT', Icons.travel_explore_rounded, [
                        _ChildNav('Guest Camp', 'guest'),
                        _ChildNav('Welcome Pavilion', 'guest'),
                        _ChildNav('Goal Desk', 'guest'),
                        _ChildNav('Context Table', 'guest'),
                        _ChildNav('Temporary Decision Space', 'guest'),
                      ], t),
                    ],

                    const SizedBox(height: 12),
                    _group(
                      'CRITERIVOX CIVILIZATION',
                      Icons.location_city_rounded,
                      civilizationOpen,
                      widget.page == 'civilization' ||
                          widget.page == 'home-preview' ||
                          widget.page == 'level2' ||
                          widget.page == 'bloom',
                      () => setState(() {
                        civilizationOpen = !civilizationOpen;
                      }),
                      expanded, t,
                    ),
                    if (expanded && civilizationOpen) ...[
                      _nav('BLOOM NEXUS', Icons.spa_rounded,
                          widget.page == 'bloom',
                          () => widget.onOpen('bloom'),
                          true, t, indent: true),
                      _civilizationGroup('DATA STEWARDSHIP QUARTER',
                          'Data Stewardship Home', 'data',
                          ['Sandre', 'Kaelen'], Icons.inventory_2_rounded, t),
                      _civilizationGroup('CONTEXT QUARTER',
                          'Context Home', 'context',
                          ['Dharen', 'Anuka'], Icons.hub_rounded, t),
                      _civilizationGroup('GATEWAY QUARTER',
                          'Gateway Home', 'gateway',
                          ['Syvax'], Icons.route_rounded, t),
                      _civilizationGroup('INTELLIGENCE QUARTER',
                          'Intelligence Home', 'reasoning',
                          ['Vivren', 'Tarkis'], Icons.psychology_rounded, t),
                      _civilizationGroup('DECISION & ACTION QUARTER',
                          'Planning & Decision Home', 'decision',
                          ['Pramon', 'Bodhex', 'Manis'], Icons.gavel_rounded, t),
                      _civilizationGroup('EVIDENCE & EXPERIMENT QUARTER',
                          'Evidence & Experiment Home', 'evidence',
                          ['Medrus', 'Epistre', 'Veridat'], Icons.science_outlined, t),
                      _civilizationGroup('KNOWLEDGE QUARTER',
                          'Knowledge Home', 'knowledge',
                          ['Viveda'], Icons.menu_book_rounded, t),
                      _subgroup('CHALLENGE & REVIEW QUARTER', Icons.rate_review_outlined, [
                        _ChildNav('Challenge & Review Home', 'civilization'),
                        _ChildNav('Manis', 'civilization'),
                      ], t),
                      _subgroup('NETWORK TERRITORY', Icons.alt_route_rounded, [
                        _ChildNav('Anukor', 'civilization'),
                        _ChildNav('Network Streets', 'civilization'),
                        _ChildNav('Routing Junctions', 'civilization'),
                        _ChildNav('Bridges', 'civilization'),
                        _ChildNav('Signal Towers', 'civilization'),
                      ], t),
                      _subgroup('CIVIC COMMONS', Icons.park_outlined, [
                        _ChildNav('Discovery Playground', 'civilization'),
                        _ChildNav('Observation Treehouses', 'civilization'),
                        _ChildNav('Gardens', 'civilization'),
                        _ChildNav('Parks', 'civilization'),
                        _ChildNav('Civic Streets', 'civilization'),
                      ], t),
                      _subgroup('OUTER CRITERIVOX WORLD', Icons.public_rounded, [
                        _ChildNav('Countryside Village', 'civilization'),
                        _ChildNav('Fields', 'civilization'),
                        _ChildNav('Streams', 'civilization'),
                        _ChildNav('CRITERIVOX COAST', 'civilization'),
                        _ChildNav('Information Harbour', 'civilization'),
                        _ChildNav('Transfer Pier', 'civilization'),
                        _ChildNav('Beach', 'civilization'),
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

  Widget _section(String text, bool visible, criterivox_theme.CriterivoxTheme t) {
    if (!visible) return const SizedBox(height: 8);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
        child: Text(
          text,
          style: TextStyle(
            color: t.mutedText,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _group(
    String title,
    IconData icon,
    bool open,
    bool active,
    VoidCallback onToggle,
    bool visible,
    criterivox_theme.CriterivoxTheme t,
  ) {
    return Material(
      color: t.surface,
      child: Tooltip(
        message: visible ? '' : title,
        child: ListTile(
          onTap: visible ? onToggle : null,
          selected: active,
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: visible ? 10 : 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selectedTileColor: t.primary.withValues(alpha: .13),
          leading: Icon(icon, size: 19,
              color: active ? t.primary : t.mutedText),
          title: visible
              ? Text(title, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? t.text : t.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .35,
                  ))
              : null,
          trailing: visible
              ? Icon(open
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
                  color: t.mutedText)
              : null,
        ),
      ),
    );
  }

  Widget _subgroup(
    String title,
    IconData icon,
    List<_ChildNav> children,
    criterivox_theme.CriterivoxTheme t,
  ) {
    return ExpansionTile(
      dense: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 18),
      childrenPadding: const EdgeInsets.only(left: 18, right: 4),
      leading: Icon(icon, size: 17, color: t.mutedText),
      title: Text(title, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: t.mutedText,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .55,
          )),
      children: children.map((child) => _nav(
        child.label,
        Icons.chevron_right_rounded,
        false,
        () => widget.onOpen(child.route),
        true, t, indent: true,
      )).toList(),
    );
  }

  Widget _civilizationGroup(
    String quarter,
    String home,
    String homeId,
    List<String> residents,
    IconData icon,
    criterivox_theme.CriterivoxTheme t,
  ) {
    return ExpansionTile(
      dense: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 18),
      childrenPadding: const EdgeInsets.only(left: 18, right: 4),
      leading: Icon(icon, size: 17, color: t.mutedText),
      title: Text(quarter, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: t.mutedText,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .55,
          )),
      children: [
        _nav(home, Icons.home_outlined, false,
            () => widget.onOpen('civilization'), true, t, indent: true),
        ...residents.map((resident) => _nav(
          resident,
          Icons.person_outline_rounded,
          false,
          () => widget.onOpen('civilization'),
          true, t, indent: true,
        )),
      ],
    );
  }

  Widget _nav(
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
    bool visible,
    criterivox_theme.CriterivoxTheme t, {
    bool indent = false,
  }) {
    return Material(
      color: t.surface,
      child: Tooltip(
        message: visible ? '' : label,
        child: ListTile(
          onTap: onTap,
          selected: active,
          dense: true,
          horizontalTitleGap: 12,
          contentPadding: EdgeInsets.only(
            left: indent ? 24 : (visible ? 10 : 13),
            right: visible ? 10 : 13,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selectedTileColor: t.primary.withValues(alpha: .13),
          leading: Icon(icon, size: 18,
              color: active ? t.primary : t.mutedText),
          title: visible
              ? Text(label, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? t.text : t.mutedText,
                    fontSize: indent ? 11 : 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ))
              : null,
        ),
      ),
    );
  }
}

class _ChildNav {
  final String label;
  final String route;
  const _ChildNav(this.label, this.route);
}

class _StatusCard extends StatelessWidget {
  final bool expanded;

  const _StatusCard({
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    return Container(
      padding: EdgeInsets.all(
        expanded ? 14 : 10,
      ),
      decoration: BoxDecoration(
        color: t.surfaceStrong,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: t.primary,
            size: 19,
          ),
          if (expanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'RUNTIME',
                    style: TextStyle(
                      color: t.mutedText,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Living system',
                    style: TextStyle(
                      color: t.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = criterivox_theme.CriterivoxTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        10,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: t.mutedText,
                    size: 19,
                  ),
                  hintText:
                      'Search analyses by name or ID...',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: t.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 7,
                  color: connectionLive
                      ? t.primary
                      : t.warning,
                ),
                const SizedBox(width: 7),
                Text(
                  connectionLive
                      ? 'LIVE'
                      : 'CONNECTING',
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: isDarkMode
                ? 'Switch to day mode'
                : 'Switch to night mode',
            onPressed: onToggleTheme,
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
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

  const _BrandMark({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return _BloomMark(size: size);
  }
}

class _BloomMark extends StatelessWidget {
  final double size;

  const _BloomMark({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 8; i++)
            Transform.rotate(
              angle: i * 3.1415926535 / 4,
              child: Container(
                width: size * .22,
                height: size * .48,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF9A7BFF),
                      Color(0xFF6654E8),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            width: size * .24,
            height: size * .24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF7D68F7),
            ),
          ),
        ],
      ),
    );
  }
}