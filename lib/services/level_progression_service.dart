import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LevelProgressionService {
  static const String _unlockedLevelsKey = 'unlocked_levels';
  static const String _completedLevelsKey = 'completed_levels';
  static const String _lastOpenedLevelKey = 'last_opened_level';
  static const int _defaultUnlockedLevels = 1; // Only level 1 is unlocked by default

  /// Get the list of unlocked levels
  static Future<List<int>> getUnlockedLevels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? unlockedLevelsJson = prefs.getString(_unlockedLevelsKey);
      
      if (unlockedLevelsJson != null) {
        final List<dynamic> unlockedLevelsList = json.decode(unlockedLevelsJson);
        return unlockedLevelsList.cast<int>();
      } else {
        // Initialize with only level 1 unlocked
        await setUnlockedLevels([_defaultUnlockedLevels]);
        return [_defaultUnlockedLevels];
      }
    } catch (e) {
      // If there's an error, return default unlocked levels
      return [_defaultUnlockedLevels];
    }
  }

  /// Set the list of unlocked levels
  static Future<void> setUnlockedLevels(List<int> unlockedLevels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String unlockedLevelsJson = json.encode(unlockedLevels);
      await prefs.setString(_unlockedLevelsKey, unlockedLevelsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check if a specific level is unlocked
  static Future<bool> isLevelUnlocked(int level) async {
    final unlockedLevels = await getUnlockedLevels();
    return unlockedLevels.contains(level);
  }

  /// Unlock a specific level (and all previous levels if not already unlocked)
  static Future<void> unlockLevel(int level) async {
    final unlockedLevels = await getUnlockedLevels();
    
    // Ensure all levels from 1 to the target level are unlocked
    for (int i = 1; i <= level; i++) {
      if (!unlockedLevels.contains(i)) {
        unlockedLevels.add(i);
      }
    }
    
    // Sort the list to maintain order
    unlockedLevels.sort();
    
    await setUnlockedLevels(unlockedLevels);
  }

  /// Unlock the next level after completing the current level
  static Future<void> unlockNextLevel(int completedLevel) async {
    final nextLevel = completedLevel + 1;
    await unlockLevel(nextLevel);
  }

  /// Reset all progress (unlock only level 1)
  static Future<void> resetProgress() async {
    await setUnlockedLevels([_defaultUnlockedLevels]);
    await resetCompletedLevels();
  }

  /// Get the highest unlocked level
  static Future<int> getHighestUnlockedLevel() async {
    final unlockedLevels = await getUnlockedLevels();
    return unlockedLevels.isNotEmpty ? unlockedLevels.last : _defaultUnlockedLevels;
  }

  /// Get the list of completed levels
  static Future<List<int>> getCompletedLevels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? completedLevelsJson = prefs.getString(_completedLevelsKey);
      
      if (completedLevelsJson != null) {
        final List<dynamic> completedLevelsList = json.decode(completedLevelsJson);
        return completedLevelsList.cast<int>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Set the list of completed levels
  static Future<void> setCompletedLevels(List<int> completedLevels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String completedLevelsJson = json.encode(completedLevels);
      await prefs.setString(_completedLevelsKey, completedLevelsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Mark a level as completed
  static Future<void> markLevelCompleted(int level) async {
    final completedLevels = await getCompletedLevels();
    if (!completedLevels.contains(level)) {
      completedLevels.add(level);
      completedLevels.sort();
      await setCompletedLevels(completedLevels);
    }
  }

  /// Check if a specific level is completed
  static Future<bool> isLevelCompleted(int level) async {
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(level);
  }

  /// Reset completed levels
  static Future<void> resetCompletedLevels() async {
    await setCompletedLevels([]);
  }

  /// Get the last opened level
  static Future<int> getLastOpenedLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_lastOpenedLevelKey) ?? 1;
    } catch (e) {
      return 1;
    }
  }

  /// Set the last opened level
  static Future<void> setLastOpenedLevel(int level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastOpenedLevelKey, level);
    } catch (e) {
      // Handle error silently
    }
  }
}
