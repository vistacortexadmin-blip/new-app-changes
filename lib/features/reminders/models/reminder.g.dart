// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final typeId = 0;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as String,
      scheduledTime: fields[4] as DateTime,
      isRecurring: fields[5] == null ? false : fields[5] as bool,
      recurringSlot: fields[6] as String?,
      source: fields[7] == null ? 'manual' : fields[7] as String,
      status: fields[8] == null ? 'pending' : fields[8] as String,
      relatedTestId: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      isSynced: fields[12] == null ? false : fields[12] as bool,
      isEnabled: fields[13] == null ? true : fields[13] as bool,
      foodRelation: fields[14] as String?,
      doctorName: fields[15] as String?,
      soundLevel: fields[16] == null ? 'high' : fields[16] as String,
      vibrationLevel: fields[17] == null ? 'medium' : fields[17] as String,
      flashLed: fields[18] == null ? true : fields[18] as bool,
      screenAlert: fields[19] == null ? false : fields[19] as bool,
      showDetailsOnLockScreen: fields[20] == null ? false : fields[20] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.isRecurring)
      ..writeByte(6)
      ..write(obj.recurringSlot)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.relatedTestId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.isEnabled)
      ..writeByte(14)
      ..write(obj.foodRelation)
      ..writeByte(15)
      ..write(obj.doctorName)
      ..writeByte(16)
      ..write(obj.soundLevel)
      ..writeByte(17)
      ..write(obj.vibrationLevel)
      ..writeByte(18)
      ..write(obj.flashLed)
      ..writeByte(19)
      ..write(obj.screenAlert)
      ..writeByte(20)
      ..write(obj.showDetailsOnLockScreen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
