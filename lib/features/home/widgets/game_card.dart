import 'package:flutter/material.dart';

import '../../../core/game_sdk/game_metadata.dart';
import '../../../core/theme/hub_theme.dart';
import 'game_card_art.dart';

/// Card de jogo no grid 2 colunas — ilustração grande integrada ao fundo.
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.metadata,
    required this.onTap,
  });

  final GameMetadata metadata;
  final VoidCallback onTap;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = HubTheme.themeFor(widget.metadata);
    final title = hubDisplayTitle(widget.metadata.title);
    final titleLead = hubTitleLead(widget.metadata.title);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(HubTheme.cardRadius),
            border: Border.all(color: HubTheme.cardBorder, width: 4),
            boxShadow: [
              BoxShadow(
                color: theme.cardColor.withValues(alpha: 0.35),
                blurRadius: _pressed ? 4 : 12,
                offset: Offset(0, _pressed ? 2 : 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Ilustração ocupa o card inteiro (desenhada, sem PNG)
              GameCardArt(
                gameId: widget.metadata.id,
                theme: theme,
              ),
              // Vinheta leve só atrás do título
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.cardColor.withValues(alpha: 0.95),
                        theme.cardColor.withValues(alpha: 0.35),
                        theme.cardColor.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.5, 1],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: _underlineWidth(titleLead),
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.metadata.featured)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4757),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'NOVO!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
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

  double _underlineWidth(String word) {
    final len = word.length.clamp(3, 10);
    return 24.0 + len * 4.5;
  }
}
