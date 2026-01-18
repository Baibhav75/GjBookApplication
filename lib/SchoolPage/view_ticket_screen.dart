import 'package:flutter/material.dart';


class ViewTicketScreen extends StatelessWidget {
  const ViewTicketScreen({super.key});

  // 🔹 Dummy data (replace with API response)
  List<Ticket> get tickets => [
    Ticket(
      ticketNo: "TCK1001",
      date: "12 Jan 2026",
      status: "Open",
    ),
    Ticket(
      ticketNo: "TCK1002",
      date: "13 Jan 2026",
      status: "In Progress",
    ),
    Ticket(
      ticketNo: "TCK1003",
      date: "14 Jan 2026",
      status: "Closed",
    ),
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Ticket"),
        backgroundColor: Colors.teal,
      ),
      body: tickets.isEmpty
          ? const Center(child: Text("No Tickets Found"))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: tickets.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final ticket = tickets[index];

          return Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                _statusColor(ticket.status),
                child: const Icon(
                  Icons.confirmation_number,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Ticket No: ${ticket.ticketNo}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("Date: ${ticket.date}"),
                  const SizedBox(height: 4),
                  Text(
                    "Status: ${ticket.status}",
                    style: TextStyle(
                      color: _statusColor(ticket.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              /// 🔹 ACTION ICONS
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility,
                        color: Colors.blue),
                    tooltip: "View Details",
                    onPressed: () {
                      // Navigate to Ticket Details
                      debugPrint(
                          "View ${ticket.ticketNo}");
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.reply,
                        color: Colors.green),
                    tooltip: "Reply",
                    onPressed: () {
                      // Navigate to Reply Screen
                      debugPrint(
                          "Reply ${ticket.ticketNo}");
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class Ticket {
  final String ticketNo;
  final String date;
  final String status;

  Ticket({
    required this.ticketNo,
    required this.date,
    required this.status,
  });
}
