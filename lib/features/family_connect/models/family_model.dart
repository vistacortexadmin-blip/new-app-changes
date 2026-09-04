enum FamilyPermissionLevel {
  reminderOnly,      // Can only see medicine & test reminders
  selectedReports,   // Can view specific shared reports
  fullCareSupport,   // Can view all vitals, care plans & receive emergency missed-dose alerts
}

class FamilyMember {
  final String id;
  final String fullName;
  final String relationship; // e.g. "Spouse", "Daughter", "Primary Caregiver"
  final String phoneNumber;
  final String email;
  final FamilyPermissionLevel permission;
  final DateTime invitedAt;
  final bool isInviteAccepted;
  final bool alertOnMissedMedicine;
  final String avatarInitials;

  FamilyMember({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
    required this.email,
    required this.permission,
    required this.invitedAt,
    this.isInviteAccepted = true,
    this.alertOnMissedMedicine = true,
    required this.avatarInitials,
  });

  String get permissionDisplayName {
    switch (permission) {
      case FamilyPermissionLevel.reminderOnly:
        return 'Reminder Notifications Only';
      case FamilyPermissionLevel.selectedReports:
        return 'Selected Medical Reports Access';
      case FamilyPermissionLevel.fullCareSupport:
        return 'Full Caregiver & Emergency Access';
    }
  }

  FamilyMember copyWith({
    FamilyPermissionLevel? permission,
    bool? alertOnMissedMedicine,
  }) {
    return FamilyMember(
      id: id,
      fullName: fullName,
      relationship: relationship,
      phoneNumber: phoneNumber,
      email: email,
      permission: permission ?? this.permission,
      invitedAt: invitedAt,
      isInviteAccepted: isInviteAccepted,
      alertOnMissedMedicine: alertOnMissedMedicine ?? this.alertOnMissedMedicine,
      avatarInitials: avatarInitials,
    );
  }
}

class SharedActivityLog {
  final String id;
  final String memberName;
  final String actionDescription;
  final DateTime timestamp;

  SharedActivityLog({
    required this.id,
    required this.memberName,
    required this.actionDescription,
    required this.timestamp,
  });
}
