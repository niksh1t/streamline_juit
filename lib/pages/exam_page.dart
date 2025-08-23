import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/exam_provider.dart';
import '../../widgets/exam_card.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExamProvider>(context, listen: false);
      if (provider.exams.isEmpty) {
        provider.loadExams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          child: Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Exam Schedule',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Could not load exams.\nError: ${provider.errorMessage}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.exams.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No exams scheduled.', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          // ✨ REMOVED GROUPING LOGIC AND DATE HEADERS ✨
          return RefreshIndicator(
            onRefresh: () => provider.loadExams(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.exams.length,
              itemBuilder: (context, index) {
                final exam = provider.exams[index];
                // Directly return the card without any headers
                return ExamCard(exam: exam);
              },
            ),
          );
        },
      ),
    );
  }
}