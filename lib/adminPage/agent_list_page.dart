import 'package:flutter/material.dart';
import '../Model/agent_list_model.dart';
import '../Service/agent_list_service.dart';

class AgentListPage extends StatefulWidget {
  const AgentListPage({Key? key}) : super(key: key);

  @override
  State<AgentListPage> createState() => _AgentListPageState();
}

class _AgentListPageState extends State<AgentListPage> {
  late Future<AgentListResponse> _futureAgents;

  @override
  void initState() {
    super.initState();
    _futureAgents = AgentListService.fetchAgentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Agent List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: FutureBuilder<AgentListResponse>(
        future: _futureAgents,
        builder: (context, snapshot) {
          // 🔹 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔹 Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load agent list",
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          // 🔹 Data check
          final response = snapshot.data;
          if (response == null || response.employeeList.isEmpty) {
            return const Center(
              child: Text(
                "No agents found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 🔹 Success UI
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: response.employeeList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _agentCard(response.employeeList[index]);
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 AGENT CARD (Classic Professional Design)
  // ---------------------------------------------------------------------------

  Widget _agentCard(AgentEmployee agent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade700,
                ],
              ),
            ),
            child: Center(
              child: Text(
                agent.employeeName.isNotEmpty
                    ? agent.employeeName[0].toUpperCase()
                    : "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 🔹 Agent Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.employeeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: ${agent.employeeId}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  agent.designation,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Contact
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.phone, color: Colors.green),
              const SizedBox(height: 4),
              Text(
                agent.contactNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
