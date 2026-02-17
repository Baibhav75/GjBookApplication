import 'package:flutter/material.dart';
import 'package:bookworld/Model/publication_merge_order_list_get_club_model.dart';
import '../../Service/publication_merge_order_list_get_club_service.dart';
import 'merge_order_details_page.dart';

class PublicationMergeOrderListGetClubPage extends StatefulWidget {
  const PublicationMergeOrderListGetClubPage({super.key});

  @override
  State<PublicationMergeOrderListGetClubPage> createState() =>
      _PublicationMergeOrderListGetClubPageState();
}

class _PublicationMergeOrderListGetClubPageState
    extends State<PublicationMergeOrderListGetClubPage> {

  late Future<List<PublicationMergeOrderListGetClubModel>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders =
        PublicationMergeOrderListGetClubService.fetchClubOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // back button white
        title: const Text(
          "Marge Order List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<List<PublicationMergeOrderListGetClubModel>>(
        future: futureOrders,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600 ? MediaQuery.of(context).size.width : 600, // Ensure enough width for horizontal scroll
              child: Column(
                children: [

                  /// HEADER ROW
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    color: Colors.blueGrey.shade100,
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Sr No",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Publication",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Action",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// DATA LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {

                        final order = orders[index];

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [

                              /// SR NO
                              Expanded(
                                flex: 1,
                                child: Text("${index + 1}"),
                              ),

                              /// PUBLICATION
                              Expanded(
                                flex: 4,
                                child: Text(
                                  order.publication,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),

                              /// ACTION BUTTON
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: () {

                                    /// 👇 NEXT PAGE ME publicationId PASS KAR RAHE HAIN
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>  MergeOrderDetailsPage (
                                          publicationId: order.publicationId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("View"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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


