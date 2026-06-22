import 'package:flutter/material.dart';

import '../theme/game_card_art.dart';
import '../theme/hub_theme.dart';
import 'game_prep.dart';
import 'game_runner_screen.dart';
import 'game_session_config.dart';
import 'hub_game.dart';
import 'widgets/game_help_dialog.dart';

/// Tela intermediária: opções de dificuldade + botão Jogar + ajuda (?).
class GamePrepScreen extends StatefulWidget {
  const GamePrepScreen({super.key, required this.game});

  final HubGame game;

  @override
  State<GamePrepScreen> createState() => _GamePrepScreenState();
}

class _GamePrepScreenState extends State<GamePrepScreen> {
  late final GamePrepDefinition _prep;
  late Map<String, Object?> _selectedValues;

  @override
  void initState() {
    super.initState();
    _prep = widget.game.prep!;
    _selectedValues = Map<String, Object?>.from(_prep.defaultConfig().values);
  }

  GameSessionConfig get _config => GameSessionConfig(values: _selectedValues);

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameRunnerScreen(
          game: widget.game,
          config: _config,
        ),
      ),
    );
  }

  void _showHelp() {
    showGameHelpDialog(
      context,
      gameId: widget.game.metadata.id,
      gameTitle: widget.game.metadata.title,
      theme: HubTheme.themeFor(widget.game.metadata),
      help: _prep.help,
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.game.metadata;
    final theme = HubTheme.themeFor(meta);

    return Scaffold(
      backgroundColor: HubTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _HelpButton(onTap: _showHelp),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GameCatalogHero(
                      gameId: meta.id,
                      title: meta.title,
                      theme: theme,
                      height: 210,
                      showFeaturedBadge: meta.featured,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      meta.category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: HubTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                    for (var i = 0; i < _prep.optionGroups.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      _OptionGroupPanel(
                        group: _prep.optionGroups[i],
                        cardColor: theme.cardColor,
                        accentColor: theme.accentColor,
                        selectedValue:
                            _selectedValues[_prep.optionGroups[i].optionKey],
                        onSelected: (value) {
                          setState(() {
                            _selectedValues[
                                _prep.optionGroups[i].optionKey] = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: _startGame,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shadowColor: theme.cardColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                child: const Text('JOGAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8E0D5), width: 2),
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: HubTheme.removeAdsPurple,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _OptionGroupPanel extends StatelessWidget {
  const _OptionGroupPanel({
    required this.group,
    required this.cardColor,
    required this.accentColor,
    required this.selectedValue,
    required this.onSelected,
  });

  final GamePrepOptionGroup group;
  final Color cardColor;
  final Color accentColor;
  final Object? selectedValue;
  final ValueChanged<Object> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                group.label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.7,
                  color: HubTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < group.choices.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _OptionTile(
                    choice: group.choices[i],
                    selected: group.choices[i].value == selectedValue,
                    cardColor: cardColor,
                    onTap: () => onSelected(group.choices[i].value),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.choice,
    required this.selected,
    required this.cardColor,
    required this.onTap,
  });

  final GamePrepChoice choice;
  final bool selected;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Material(
        color: selected ? cardColor : HubTheme.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? cardColor : const Color(0xFFE8E0D5),
                width: selected ? 2.5 : 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.28),
                        blurRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  choice.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1,
                    color: selected ? Colors.white : HubTheme.textPrimary,
                  ),
                ),
                if (choice.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    choice.subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : HubTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
