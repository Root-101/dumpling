import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class PipelineScreen extends StatelessWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return BlocProvider(
      create: (_) => PipelineCubit(),
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppRail(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: colors.surface.surface1,
                      border: Border(
                        bottom: BorderSide(
                          color: colors.surface.border.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Production › Canvas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.text.subtle,
                                ),
                              ),
                              const Text(
                                'Database backups',
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 26 / 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const AppButton(
                          label: 'Test run',
                          type: AppButtonType.secondary,
                        ),
                        const SizedBox(width: 12),
                        const AppButton(label: 'Save pipeline'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(child: PipelineCanvas()),
                        BlocBuilder<PipelineCubit, PipelineState>(
                          builder: (context, s) {
                            final sel = s.selected;
                            return sel == null
                                ? const SizedBox.shrink()
                                : ConfigInspector(state: s, config: sel);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
