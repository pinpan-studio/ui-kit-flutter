import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/theme_controller.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'kit_nav.dart';
import 'kit_shell.dart';

/// `/components` — index des galeries de composants.
class ComponentsIndexPage extends StatefulWidget {
  const ComponentsIndexPage({super.key, this.onMenu});
  final VoidCallback? onMenu;

  @override
  State<ComponentsIndexPage> createState() => _ComponentsIndexPageState();
}

class _ComponentsIndexPageState extends State<ComponentsIndexPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final total = kCategories.fold<int>(0, (n, k) => n + k.sections.length);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenu, tooltip: 'Catalogue'),
        title: const Text('Composants'),
        actions: const [ThemeToggleButton(), ThemePickerButton(), SizedBox(width: 4)],
      ),
      body: ScrollToTopOnReselect(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(Space.m, Space.s, Space.m, Space.xl),
          children: [
            Text('${kCategories.length} galeries · $total sections documentées', style: context.t.bodySm),
            const SizedBox(height: Space.m),
            ResponsiveGrid(
              minItemWidth: 300,
              children: [
                for (final cat in kCategories)
                  KitCard(
                    onTap: () => openCategory(context, cat),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: c.primaryLight, borderRadius: Radii.rm),
                          child: Icon(cat.icon, color: c.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(cat.label, style: context.t.cardTitle)),
                                  Text(
                                    '${cat.sections.length}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted),
                                  ),
                                  Icon(Icons.chevron_right, size: 18, color: c.textMuted),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(cat.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: context.t.bodySm.copyWith(fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
