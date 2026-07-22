import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchTheFollowingScreen extends StatefulWidget {
  const MatchTheFollowingScreen({super.key});

  @override
  State createState() => _MatchTheFollowingScreenState();
}

class _MatchTheFollowingScreenState extends State<MatchTheFollowingScreen> {
  List leftItems = [];
  List rightItems = [];
  Map correctPairs = {};
  Map userPairs = {};
  bool loading = true;
  String questionText = 'Match the Sentences';
  int score = 0;
  int total = 0;
  int currentIndex = 0;
  List allQuestions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('https://your-backend-url/match_the_following_questions/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        allQuestions = (data is List) ? List.from(data) : [data];
        loadCurrentQuestion();
      } else {
        setState(() {
          loading = false;
          questionText = 'Failed to load questions';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        questionText = 'Error: $e';
      });
    }
  }

  void loadCurrentQuestion() {
    if (currentIndex >= allQuestions.length) {
      setState(() {
        loading = false;
        questionText = 'No more questions!';
      });
      return;
    }
    final question = allQuestions[currentIndex];
    questionText = 'Match the Sentences';
    leftItems = List.from(question['pairs']['telugu']);
    rightItems = List.from(question['pairs']['english']);
    correctPairs = {};
    for (int i = 0; i < leftItems.length; i++) {
      correctPairs[leftItems[i]] = rightItems[i];
    }
    rightItems.shuffle();
    userPairs = {};
    score = 0;
    total = leftItems.length;
    setState(() {
      loading = false;
    });
  }

  void checkAnswers() {
    int correct = 0;
    for (var entry in userPairs.entries) {
      if (correctPairs[entry.key] == entry.value) correct++;
    }
    setState(() {
      score = correct;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Result'),
        content: Text('You matched $score out of $total correctly!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (currentIndex < allQuestions.length - 1) {
                setState(() {
                  currentIndex++;
                  loading = true;
                });
                loadCurrentQuestion();
              }
            },
            child: Text(currentIndex < allQuestions.length - 1 ? 'Next' : 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match the Sentences'),
        backgroundColor: Colors.orange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Drag Telugu phrases to match with their English translations',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'తెలుగు (Telugu)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                          child: Icon(Icons.compare_arrows, color: Colors.grey),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'English',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Telugu column (left side)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: leftItems.map((item) {
                                final matched = userPairs.containsKey(item);
                                return Opacity(
                                  opacity: matched ? 0.4 : 1.0,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: Draggable(
                                      data: item,
                                      feedback: Material(
                                        elevation: 4,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.orange.shade200),
                                        ),
                                        child: Text(
                                          item,
                                          style: const TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      maxSimultaneousDrags: matched ? 0 : 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        // Center divider
                        const SizedBox(
                          width: 40,
                          child: VerticalDivider(
                            color: Colors.grey,
                            thickness: 1,
                            width: 40,
                          ),
                        ),
                        // English column (right side)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: rightItems.map((target) {
                                final matchedKey = userPairs.entries.firstWhere(
                                  (e) => e.value == target,
                                  orElse: () => const MapEntry('', ''),
                                ).key;
                                return DragTarget(
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: matchedKey.isNotEmpty
                                            ? (correctPairs[matchedKey] == target
                                                ? Colors.green.shade100
                                                : Colors.red.shade100)
                                            : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: matchedKey.isNotEmpty
                                              ? (correctPairs[matchedKey] == target
                                                  ? Colors.green
                                                  : Colors.red)
                                              : Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            target,
                                            style: const TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (matchedKey.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                matchedKey,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: correctPairs[matchedKey] == target
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                  onWillAcceptWithDetails: (details) {
                                    final data = details.data;
                                    return !userPairs.containsKey(data) && !userPairs.containsValue(target);
                                  },
                                  onAcceptWithDetails: (details) {
                                    setState(() {
                                      userPairs[details.data] = target;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Check Answers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: userPairs.length == leftItems.length ? checkAnswers : null,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

