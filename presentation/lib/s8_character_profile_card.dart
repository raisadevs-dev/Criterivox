import 'package:flutter/material.dart';

class S8CharacterProfileCard extends StatefulWidget {
  final String characterId;
  final String name;
  final String role;
  final String quote;
  final List<String> skills;
  final Widget avatar;
  final VoidCallback? onClose;

  const S8CharacterProfileCard({
    super.key,
    required this.characterId,
    required this.name,
    required this.role,
    required this.quote,
    required this.skills,
    required this.avatar,
    this.onClose,
  });

  @override
  State<S8CharacterProfileCard> createState() =>
      _S8CharacterProfileCardState();
}

class _S8CharacterProfileCardState
    extends State<S8CharacterProfileCard> {
  Offset _offset = const Offset(24, 24);
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _dragging = true;
                });
              },
              onPanUpdate: (details) {
                final size = MediaQuery.sizeOf(context);

                setState(() {
                  _offset += details.delta;

                  _offset = Offset(
                    _offset.dx.clamp(
                      8.0,
                      size.width - 328.0,
                    ),
                    _offset.dy.clamp(
                      8.0,
                      size.height - 260.0,
                    ),
                  );
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _dragging = false;
                });
              },
              child: AnimatedScale(
                scale: _dragging ? 1.02 : 1,
                duration: const Duration(
                  milliseconds: 120,
                ),
                child: Material(
                  color: Colors.transparent,
                  elevation: 18,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xF10B1220),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white24,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 32,
                          spreadRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 58,
                              height: 70,
                              child: widget.avatar,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.role,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.characterId
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 8,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close profile',
                              onPressed: widget.onClose,
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 17,
                              ),
                              color: Colors.white54,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '“${widget.quote}”',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            height: 1.35,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Skills
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.skills
                              .map(
                                (skill) => Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white12,
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 8.5,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 9),

                        const Row(
                          children: [
                            Icon(
                              Icons.open_with_rounded,
                              size: 12,
                              color: Colors.white30,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Drag to reposition',
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}