import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/auth_provider.dart';
import '../providers/habits_provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final authProvider = context.read<AuthProvider>();
    final habitsProvider = context.read<HabitsProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      await habitsProvider.loadHabits(userId);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(_SettingsPageRoute());
  }

  Widget _buildAvatar(String? avatarUrl, double radius) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.person, size: radius * 1.25),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final avatarUrl = authProvider.avatarUrl;

    final pages = [
      const _HomePage(),
      const _ProgressPage(),
      const _ScorePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: _buildAvatar(avatarUrl, 16),
              onPressed: _openSettings,
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Score',
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.watch<HabitsProvider>();
    final habits = habitsProvider.habits;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: habitsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : habits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.checklist,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add habits in Settings',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        final isCompleted = habitsProvider.isHabitCompleted(
                          habit.id,
                          _selectedDate,
                        );

                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: isCompleted,
                              onChanged: (_) {
                                habitsProvider.toggleHabitCompletion(
                                  habit.id,
                                  _selectedDate,
                                );
                              },
                            ),
                            title: Text(
                              habit.name,
                              style: TextStyle(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: habit.description != null
                                ? Text(habit.description!)
                                : null,
                            trailing: _buildHabitBadge(habit),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildHabitBadge(Habit habit) {
    final color = habit.type == HabitType.good
        ? Colors.green
        : habit.type == HabitType.bad
            ? Colors.red
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '${habit.points > 0 ? '+' : ''}${habit.points}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProgressPage extends StatelessWidget {
  const _ProgressPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Progress'),
    );
  }
}

class _ScorePage extends StatelessWidget {
  const _ScorePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Score'),
    );
  }
}

class _SettingsPageRoute extends PageRouteBuilder {
  _SettingsPageRoute()
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const _SettingsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final avatarUrl = authProvider.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: _buildSettingsAvatar(avatarUrl, user?.getStringValue('email')),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.getStringValue('email') ?? 'User',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Manage Habits'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const _ManageHabitsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () => authProvider.logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsAvatar(String? avatarUrl, String? email) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: 48,
      child: Text(
        email?.substring(0, 1).toUpperCase() ?? 'U',
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}

class _ManageHabitsPage extends StatelessWidget {
  const _ManageHabitsPage();

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.watch<HabitsProvider>();
    final habits = habitsProvider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Habits'),
      ),
      body: habitsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : habits.isEmpty
              ? const Center(child: Text('No habits yet'))
              : ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return ListTile(
                      title: Text(habit.name),
                      subtitle: Text(
                        '${habit.type?.name ?? 'neutral'} • ${habit.points} points',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showHabitDialog(context, habit: habit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, habit),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showHabitDialog(BuildContext context, {Habit? habit}) async {
    final authProvider = context.read<AuthProvider>();
    final habitsProvider = context.read<HabitsProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    final nameController = TextEditingController(text: habit?.name);
    final descriptionController = TextEditingController(text: habit?.description);
    final pointsController = TextEditingController(
      text: habit?.points.toString() ?? '1',
    );
    HabitType? selectedType = habit?.type;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(habit == null ? 'Add Habit' : 'Edit Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<HabitType?>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Neutral')),
                    DropdownMenuItem(value: HabitType.good, child: Text('Good')),
                    DropdownMenuItem(value: HabitType.bad, child: Text('Bad')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(habit == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final description = descriptionController.text.trim();
      final points = int.tryParse(pointsController.text) ?? 1;

      if (name.isEmpty) return;

      if (habit == null) {
        await habitsProvider.createHabit(
          userId: userId,
          name: name,
          description: description.isEmpty ? null : description,
          type: selectedType,
          points: points,
        );
      } else {
        await habitsProvider.updateHabit(
          id: habit.id,
          name: name,
          description: description.isEmpty ? null : description,
          type: selectedType,
          points: points,
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final habitsProvider = context.read<HabitsProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await habitsProvider.deleteHabit(habit.id);
    }
  }
}
