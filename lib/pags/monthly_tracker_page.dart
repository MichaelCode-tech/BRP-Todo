import 'package:flutter/material.dart';
import 'package:todo1/db/db.dart';

class MonthlyTrackerPage extends StatelessWidget {
  final ToDoDB db;

  const MonthlyTrackerPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final tags = db.allTags;
    final primaryColor = Theme.of(context).primaryColor;
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
                  final denominator = target > 0
                      ? target
                      : (planned > 0 ? planned : 1);
                  final progress = (completed / denominator).clamp(0.0, 1.0);
                  final percentLabel = '${(progress * 100).round()}%';
                  final subtitle = target > 0
                      ? 'Completed $completed of $target planned tasks this month'
                      : planned > 0
                      ? 'Completed $completed of $planned planned tasks this month'
                      : 'Completed $completed tasks this month';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 8,
                                  color: primaryColor,
                                  backgroundColor: primaryColor.withOpacity(
                                    0.18,
                                  ),
                                ),
                                Text(
                                  percentLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tag,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(subtitle),
                                const SizedBox(height: 12),
                                Text(
                                  target > 0
                                      ? 'Target: $target'
                                      : 'Planned: ${planned > 0 ? planned : 'N/A'}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
