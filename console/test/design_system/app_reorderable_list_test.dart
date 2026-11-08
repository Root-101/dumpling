import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<List<(int, int)>> pump(WidgetTester tester, List<String> items) async {
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeConfig.theme,
        home: Scaffold(
          body: AppReorderableList<String>(
            items: items,
            keyOf: (item) => item,
            // like a cubit: the new list doesn't come back in this frame
            onReorder: (from, to) => moves.add((from, to)),
            itemBuilder: (_, item) => SizedBox(height: 40, child: Text(item)),
          ),
        ),
      ),
    );
    return moves;
  }

  double top(WidgetTester tester, String item) =>
      tester.getTopLeft(find.text(item)).dy;

  testWidgets('A drop shows the new order in its own frame', (tester) async {
    final moves = await pump(tester, ['a', 'b', 'c']);

    tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .onReorderItem!(0, 2);
    await tester.pump();

    expect(moves, [(0, 2)]);
    expect(top(tester, 'b'), lessThan(top(tester, 'c')));
    expect(top(tester, 'c'), lessThan(top(tester, 'a')));
  });

  testWidgets('New items from above replace the local order', (tester) async {
    await pump(tester, ['a', 'b']);
    tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .onReorderItem!(0, 1);
    await tester.pump();

    // e.g. the save failed and the cubit went back to the order before
    await pump(tester, ['a', 'b']);

    expect(top(tester, 'a'), lessThan(top(tester, 'b')));
  });
}
