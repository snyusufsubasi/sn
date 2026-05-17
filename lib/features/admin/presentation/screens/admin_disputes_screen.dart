import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_card.dart';

class AdminDisputesScreen extends StatelessWidget {
  const AdminDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDisputes)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        children: [
          AppCard(
            child: ListTile(
              title: Text(l10n.adminDisputeDemo),
              subtitle: Text(l10n.adminDisputeDemoBody),
            ),
          ),
        ],
      ),
    );
  }
}
