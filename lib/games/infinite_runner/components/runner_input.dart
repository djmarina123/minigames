import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Camada transparente que captura arrastes em toda a tela do jogo.
///
/// Garante que gestos cheguem ao handler mesmo quando o dedo está sobre o
/// personagem ou obstáculos — importante no browser, onde o hit-test pode falhar.
class RunnerInputLayer extends PositionComponent with DragCallbacks {
  RunnerInputLayer({
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragFinished,
  }) : super(
          priority: 10000,
          anchor: Anchor.topLeft,
        );

  final void Function(DragStartEvent event) onDragStarted;
  final void Function(DragUpdateEvent event) onDragMoved;
  final void Function() onDragFinished;

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    onDragStarted(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    onDragMoved(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    onDragFinished();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    onDragFinished();
  }
}
