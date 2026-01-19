import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final Task? taskSummary;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.taskSummary,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Task> _future;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _future = TaskApiService.fetchTaskDetail(widget.taskId);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa task?"),
        content: const Text("Bạn có chắc muốn xóa không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      setState(() => _deleting = true);
      await TaskApiService.deleteTask(widget.taskId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Widget _build(Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title.isEmpty ? "(No title)" : task.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            task.description.isEmpty ? "(No description)" : task.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                    Icons.category, "Category\n${task.category}"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _buildInfoCard(Icons.access_time, "Status\n${task.status}"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                    Icons.priority_high, "Priority\n${task.priority}"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Subtasks",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (task.subtasks.isEmpty)
            const Text("(No subtasks)")
          else
            ...task.subtasks.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        s.done ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.title)),
                    ],
                  ),
                )),
          const SizedBox(height: 20),
          const Text("Attachments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (task.attachments.isEmpty)
            const Text("(No attachments)")
          else
            ...task.attachments.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          a.name.isEmpty ? 'document_1_b.pdf' : a.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail", style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        actions: [
          if (_deleting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete, color: Colors.orange),
                tooltip: "Xóa",
              ),
            ),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (snapshot.error.toString().contains("DETAIL_NOT_FOUND") &&
                widget.taskSummary != null) {
              return _build(widget.taskSummary!);
            }
            return Center(
                child: Text("Load detail failed:\n${snapshot.error}"));
          }

          return _build(snapshot.data!);
        },
      ),
    );
  }
}
