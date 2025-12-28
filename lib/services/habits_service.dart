import 'package:pocketbase/pocketbase.dart';

import '../config/environment.dart';
import '../models/habit.dart';

class HabitsService {
  final PocketBase _pb;

  HabitsService() : _pb = PocketBase(Environment.pocketbaseUrl);

  Future<List<Habit>> getHabits(String userId) async {
    final records = await _pb.collection('habits').getFullList(
          filter: 'userId = "$userId"',
          sort: 'name',
        );

    return records.map((record) => Habit.fromJson(record.toJson())).toList();
  }

  Future<Habit> createHabit({
    required String userId,
    required String name,
    String? description,
    String? type,
    required int points,
  }) async {
    final record = await _pb.collection('habits').create(body: {
      'userId': userId,
      'name': name,
      'description': description,
      'type': type,
      'points': points,
    });

    return Habit.fromJson(record.toJson());
  }

  Future<Habit> updateHabit({
    required String id,
    required String name,
    String? description,
    String? type,
    required int points,
  }) async {
    final record = await _pb.collection('habits').update(id, body: {
      'name': name,
      'description': description,
      'type': type,
      'points': points,
    });

    return Habit.fromJson(record.toJson());
  }

  Future<void> deleteHabit(String id) async {
    await _pb.collection('habits').delete(id);
  }
}
