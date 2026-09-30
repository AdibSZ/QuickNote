import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class DoodleStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DoodleStroke({required this.points, required this.color, this.strokeWidth = 3.0});

  static List<DoodleStroke> parseStrokes(String raw) {
    final List<DoodleStroke> strokes = [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      for (final s in list) {
        final colVal = s['color'] as int? ?? 0xFFFFFFFF;
        final w = (s['width'] as num?)?.toDouble() ?? 3.0;
        final pts = (s['points'] as List).map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())).toList();
        strokes.add(DoodleStroke(points: pts, color: Color(colVal), strokeWidth: w));
      }
    } catch (_) {}
    return strokes;
  }
}

class DoodleCanvasModal extends StatefulWidget {
  final String? initialData;
  final ValueChanged<String> onSave;

  const DoodleCanvasModal({super.key, this.initialData, required this.onSave});

  static void show(BuildContext context, {String? initialData, required ValueChanged<String> onSave}) {
    TactileFeedback.medium();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, anim1, anim2) => DoodleCanvasModal(initialData: initialData, onSave: onSave),
        transitionsBuilder: (context, anim, secondaryAnim, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<DoodleCanvasModal> createState() => _DoodleCanvasModalState();
}

class _DoodleCanvasModalState extends State<DoodleCanvasModal> {
  final List<DoodleStroke> _strokes = [];
  Color _currentColor = Colors.white;
  final double _currentWidth = 3.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _loadInitialData(widget.initialData!);
    }
  }

  void _loadInitialData(String raw) {
    try {
      final List<dynamic> list = jsonDecode(raw);
      for (final s in list) {
        final colVal = s['color'] as int? ?? Colors.white.toARGB32();
        final w = (s['width'] as num?)?.toDouble() ?? 3.0;
        final pts = (s['points'] as List).map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())).toList();
        _strokes.add(DoodleStroke(points: pts, color: Color(colVal), strokeWidth: w));
      }
    } catch (_) {}
  }

  String _serialize() {
    final list = _strokes.map((s) {
      return {
        'color': s.color.toARGB32(),
        'width': s.strokeWidth,
        'points': s.points.map((p) => [p.dx, p.dy]).toList(),
      };
    }).toList();
    return jsonEncode(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Finger Doodle & Sketch',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white70),
                    onPressed: _strokes.isEmpty ? null : () {
                      TactileFeedback.light();
                      setState(() => _strokes.removeLast());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: _strokes.isEmpty ? null : () {
                      TactileFeedback.medium();
                      setState(() => _strokes.clear());
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      TactileFeedback.success();
                      widget.onSave(_serialize());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            // Drawing Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onPanStart: (details) {
                    final local = details.localPosition;
                    setState(() {
                      _strokes.add(DoodleStroke(
                        points: [local],
                        color: _currentColor,
                        strokeWidth: _currentWidth,
                      ));
                    });
                  },
                  onPanUpdate: (details) {
                    final local = details.localPosition;
                    setState(() {
                      _strokes.last.points.add(local);
                    });
                  },
                  child: CustomPaint(
                    painter: DoodlePainter(_strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            // Bottom Color & Brush Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...[Colors.white, const Color(0xFF0A84FF), const Color(0xFF30D158), const Color(0xFFFF9F0A), Colors.redAccent, const Color(0xFFBF5AF2)].map((c) {
                    final isSel = _currentColor == c;
                    return GestureDetector(
                      onTap: () {
                        TactileFeedback.selection();
                        setState(() => _currentColor = c);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 2.5),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoodlePainter extends CustomPainter {
  final List<DoodleStroke> strokes;
  final bool fit;
  DoodlePainter(this.strokes, {this.fit = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;
    if (fit && size.width > 0 && size.height > 0) {
      double minX = double.infinity, minY = double.infinity;
      double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
      for (final s in strokes) {
        for (final p in s.points) {
          if (p.dx < minX) minX = p.dx;
          if (p.dy < minY) minY = p.dy;
          if (p.dx > maxX) maxX = p.dx;
          if (p.dy > maxY) maxY = p.dy;
        }
      }
      final w = maxX - minX;
      final h = maxY - minY;
      if (w > 0 && h > 0) {
        final scaleX = (size.width - 24) / w;
        final scaleY = (size.height - 24) / h;
        final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.05, 3.0);
        canvas.translate((size.width - w * scale) / 2 - minX * scale, (size.height - h * scale) / 2 - minY * scale);
        canvas.scale(scale);
      }
    }
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      if (s.points.isNotEmpty) {
        path.moveTo(s.points.first.dx, s.points.first.dy);
        for (int i = 1; i < s.points.length; i++) {
          path.lineTo(s.points[i].dx, s.points[i].dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DoodlePainter oldDelegate) => true;
}
