import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_dimens.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUsers)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Text(l10n.adminUsersBody),
      ),
    );
  }
}
