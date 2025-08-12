import 'dart:io';
import 'package:workmanager/workmanager.dart';

class Scheduler {
  static const String backupTask = 'mohasib_backup_task';

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == backupTask) {
        // هنا يمكن استدعاء منطق النسخ الاحتياطي الفعلي
        print('Running scheduled backup...');
        // TODO: call DriveService to create and upload backup
      }
      return Future.value(true);
    });
  }

  static Future<void> init() async {
    if (Platform.isAndroid) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    }
  }

  static Future<void> scheduleDailyBackup() async {
    await Workmanager().registerPeriodicTask('1', backupTask, frequency: Duration(days: 1));
  }

  static Future<void> cancelBackup() async {
    await Workmanager().cancelByUniqueName('1');
  }
}