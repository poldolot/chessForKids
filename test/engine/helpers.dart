import 'package:chess_for_kids/engine/engine.dart';

/// Sorted UCI strings of the pseudo-legal moves of the piece on [from].
List<String> ucis(
  Position position,
  String from, {
  GameRules rules = GameRules.standard,
}) => pseudoLegalMoves(
  position,
  from: Square.parse(from),
  rules: rules,
).map((m) => m.uci).toList()..sort();

/// Sorted UCI strings of all legal moves, optionally only from one square.
List<String> legal(String fen, [String? from]) => legalMoves(
  Position.fromFen(fen),
  from: from == null ? null : Square.parse(from),
).map((m) => m.uci).toList()..sort();
