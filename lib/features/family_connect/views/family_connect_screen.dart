import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../providers/family_connect_provider.dart';
import '../models/family_model.dart';

class FamilyConnectScreen extends ConsumerWidget {
  const FamilyConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyConnectProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Family Connect & Caregivers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            tooltip: 'Invite Family Member',
            onPressed: () => _showInviteModal(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD8B4FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppColors.accentPurple, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You control all sharing. Access can be revoked anytime.',
                      style: TextStyle(fontSize: 12, color: AppColors.accentPurple, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Authorized Family Members',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${state.members.length} connected',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...state.members.map((member) => _buildMemberCard(context, ref, member)),

            const SizedBox(height: 20),

            ExpansionTile(
              title: const Text('Access Audit Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.activityLogs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final log = state.activityLogs[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.history_toggle_off_rounded, size: 18, color: AppColors.textMuted),
                        title: Text(log.actionDescription, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        subtitle: Text('${log.memberName} · ${DateFormat('dd MMM, hh:mm a').format(log.timestamp)}', style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentPurple,
        icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
        label: const Text('Invite Caregiver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showInviteModal(context, ref),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, WidgetRef ref, FamilyMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accentPurple.withOpacity(0.15),
                child: Text(
                  member.avatarInitials,
                  style: const TextStyle(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${member.relationship} · ${member.phoneNumber}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                tooltip: 'Revoke Access',
                onPressed: () {
                  _showRevokeConfirmDialog(context, ref, member);
                },
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Permission Level:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              DropdownButton<FamilyPermissionLevel>(
                value: member.permission,
                underline: const SizedBox(),
                dropdownColor: AppColors.surface,
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(
                    value: FamilyPermissionLevel.reminderOnly,
                    child: Text('Reminder Only'),
                  ),
                  DropdownMenuItem(
                    value: FamilyPermissionLevel.selectedReports,
                    child: Text('Selected Reports'),
                  ),
                  DropdownMenuItem(
                    value: FamilyPermissionLevel.fullCareSupport,
                    child: Text('Full Care & Alerts'),
                  ),
                ],
                onChanged: (newLevel) {
                  if (newLevel != null) {
                    ref
                        .read(familyConnectProvider.notifier)
                        .updateMemberPermission(member.id, newLevel);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRevokeConfirmDialog(
      BuildContext context, WidgetRef ref, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Revoke Family Access?'),
          content: Text(
            'Are you sure you want to revoke all permissions for ${member.fullName}? They will no longer receive medicine reminders or view shared health documents.',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Revoke Access'),
              onPressed: () {
                Navigator.pop(context);
                ref.read(familyConnectProvider.notifier).revokeAccess(member.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Access revoked for ${member.fullName}.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showInviteModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    FamilyPermissionLevel selectedLevel = FamilyPermissionLevel.reminderOnly;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite Family Caregiver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connected family members will receive a secure consent link to assist with your health reminders.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name (e.g. Ramesh Sharma)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: relationCtrl,
                    decoration: const InputDecoration(labelText: 'Relationship (e.g. Father, Daughter)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number (+91...)'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Permission Tier:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<FamilyPermissionLevel>(
                    value: selectedLevel,
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(
                        value: FamilyPermissionLevel.reminderOnly,
                        child: Text('Reminder Notifications Only'),
                      ),
                      DropdownMenuItem(
                        value: FamilyPermissionLevel.selectedReports,
                        child: Text('Selected Reports Viewing'),
                      ),
                      DropdownMenuItem(
                        value: FamilyPermissionLevel.fullCareSupport,
                        child: Text('Full Caregiver & Emergency Access'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedLevel = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        ref.read(familyConnectProvider.notifier).inviteFamilyMember(
                              fullName: nameCtrl.text.trim(),
                              relationship: relationCtrl.text.trim().isEmpty ? 'Caregiver' : relationCtrl.text.trim(),
                              phone: phoneCtrl.text.trim().isEmpty ? '+91 99999 88888' : phoneCtrl.text.trim(),
                              email: 'invite@example.com',
                              permission: selectedLevel,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invitation sent to ${nameCtrl.text.trim()}!')),
                        );
                      },
                      child: const Text('Send Caregiver Invitation'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
