import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_model.dart';
import '../../../core/storage/seed_data.dart';

class FamilyConnectState {
  final List<FamilyMember> members;
  final List<SharedActivityLog> activityLogs;

  FamilyConnectState({
    required this.members,
    required this.activityLogs,
  });

  FamilyConnectState copyWith({
    List<FamilyMember>? members,
    List<SharedActivityLog>? activityLogs,
  }) {
    return FamilyConnectState(
      members: members ?? this.members,
      activityLogs: activityLogs ?? this.activityLogs,
    );
  }
}

class FamilyConnectNotifier extends StateNotifier<FamilyConnectState> {
  FamilyConnectNotifier()
      : super(FamilyConnectState(
          members: SeedData.initialFamilyMembers,
          activityLogs: SeedData.initialActivityLogs,
        ));

  void inviteFamilyMember({
    required String fullName,
    required String relationship,
    required String phone,
    required String email,
    required FamilyPermissionLevel permission,
  }) {
    final initials = fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    
    final newMember = FamilyMember(
      id: 'fam_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      relationship: relationship,
      phoneNumber: phone,
      email: email,
      permission: permission,
      invitedAt: DateTime.now(),
      avatarInitials: initials.isEmpty ? 'FM' : initials,
    );

    final log = SharedActivityLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      memberName: 'You',
      actionDescription: 'Sent care invitation to $fullName ($relationship)',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      members: [newMember, ...state.members],
      activityLogs: [log, ...state.activityLogs],
    );
  }

  void updateMemberPermission(String memberId, FamilyPermissionLevel level) {
    final updated = state.members.map((m) {
      if (m.id == memberId) {
        return m.copyWith(permission: level);
      }
      return m;
    }).toList();

    state = state.copyWith(members: updated);
  }

  void toggleMissedDoseAlert(String memberId, bool enabled) {
    final updated = state.members.map((m) {
      if (m.id == memberId) {
        return m.copyWith(alertOnMissedMedicine: enabled);
      }
      return m;
    }).toList();

    state = state.copyWith(members: updated);
  }

  void revokeAccess(String memberId) {
    final member = state.members.firstWhere((m) => m.id == memberId, orElse: () => state.members.first);
    final log = SharedActivityLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      memberName: 'You',
      actionDescription: 'Revoked caregiver access for ${member.fullName}',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      members: state.members.where((m) => m.id != memberId).toList(),
      activityLogs: [log, ...state.activityLogs],
    );
  }
}

final familyConnectProvider =
    StateNotifierProvider<FamilyConnectNotifier, FamilyConnectState>((ref) {
  return FamilyConnectNotifier();
});
