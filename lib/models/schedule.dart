class Schedule {
  final int scheduleId;
  final String roomName;
  final String switchName;
  final String jobName;
  final String startTime;
  final String endTime;
  final String jobGroup;
  final String repeatRadio;
  final String status;
  final String deviceName;
  final String type;
  final int userId;
  final String userUuid;
  final String startDays;
  final String endDays;

  Schedule({
    required this.scheduleId,
    required this.roomName,
    required this.switchName,
    required this.jobName,
    required this.startTime,
    required this.endTime,
    required this.jobGroup,
    required this.repeatRadio,
    required this.status,
    required this.deviceName,
    required this.type,
    required this.userId,
    required this.userUuid,
    this.startDays = '',
    this.endDays = '',
  });

  /// Factory constructor to create a Schedule from JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['schedule_id'] as int? ?? 0,
      roomName: json['room_name'] as String? ?? '',
      switchName: json['switch_name'] as String? ?? '',
      jobName: json['job_name'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      jobGroup: json['job_group'] as String? ?? '',
      repeatRadio: json['repeat_radio'] as String? ?? '',
      status: json['status'] as String? ?? '',
      deviceName: json['device_name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      userUuid: json['user_uuid'] as String? ?? '',
      startDays: json['start_days'] as String? ?? '',
      endDays: json['end_days'] as String? ?? '',
    );
  }

  /// Convert Schedule to JSON
  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'room_name': roomName,
      'switch_name': switchName,
      'job_name': jobName,
      'start_time': startTime,
      'end_time': endTime,
      'job_group': jobGroup,
      'repeat_radio': repeatRadio,
      'status': status,
      'device_name': deviceName,
      'type': type,
      'user_id': userId,
      'user_uuid': userUuid,
      'start_days': startDays,
      'end_days': endDays,
    };
  }

  @override
  String toString() {
    return 'Schedule(scheduleId: $scheduleId, roomName: $roomName, switchName: $switchName, jobName: $jobName, startTime: $startTime, endTime: $endTime, status: $status)';
  }
}
