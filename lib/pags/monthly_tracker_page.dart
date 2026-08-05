import 'package:flutter/material.dart';
import 'package:todo1/db/db.dart';

class MonthlyTrackerPage extends StatelessWidget {
  final ToDoDB db;

  const MonthlyTrackerPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final tags = db.allTags;
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tags.isEmpty
            ? const Center(
                child: Text(
                  'No tags found. Add tags to tasks and set monthly targets to see tracker summaries.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final planned = db.plannedThisMonthForTag(tag);
                  final completed = db.completedThisMonthForTag(tag);
                  final target = db.getTagTarget(tag);
                  final label = target > 0
                      ? '$completed/$target'
                      : '$completed/$planned';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(tag),
                      subtitle: Text(
                        target > 0
                            ? 'Completed $label this month'
                            : 'Completed $label tasks this month',
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
