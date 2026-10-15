import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/dialog_form_controller.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/fieldsets.dart';
import 'package:serverpod_admin_dashboard/src/widgets/dialog_form_field.dart';
import 'package:serverpod_admin_dashboard/src/widgets/fieldset_section.dart';

/// The fields of a create or edit form for [resource], grouped by its
/// fieldsets.
class DialogFormFields extends StatelessWidget {
  const DialogFormFields({
    required this.resource,
    required this.formController,
    required this.adminController,
    super.key,
  });

  final AdminResource resource;
  final DialogFormController formController;
  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in columnGroups(resource))
          FieldsetSection(
            key: ValueKey(group.name),
            group: group,
            expand: formController.showAllFields,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final column in group.columns)
                  DialogFormField(
                    column: column,
                    formController: formController,
                    adminController: adminController,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
