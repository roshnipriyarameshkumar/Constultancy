import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample_app/review_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Please log in to view notifications",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Updates",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: StreamBuilder<QuerySnapshot>(
          // Modified query - removed orderBy to avoid needing the index
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "Error loading notifications",
                      style: TextStyle(fontSize: 16),
                    ),
                    if (snapshot.error.toString().contains('index'))
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Please create the required Firestore index',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No order updates available",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            // Get all docs and sort them locally
            final docs = snapshot.data!.docs;
            docs.sort((a, b) {
              final aTimestamp = (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              final bTimestamp = (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              return bTimestamp.compareTo(aTimestamp); // Descending order
            });

            final notifications = <Widget>[];

            for (final doc in docs) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                final deliveryStatus = (data['deliveryStatus'] ?? 'Placed').toString();
                if (deliveryStatus == 'Placed') continue;

                final orderId = data['orderId']?.toString() ?? 'Unknown';
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                final formattedDate = DateFormat('MMM dd, yyyy · hh:mm a').format(timestamp);
                final productMap = (data['products'] as Map<String, dynamic>? ?? {});

                Color statusColor;
                IconData statusIcon;
                String statusMessage;

                switch (deliveryStatus.toLowerCase()) {
                  case 'shipped':
                    statusColor = Colors.blue;
                    statusIcon = Icons.local_shipping;
                    statusMessage = 'Order #$orderId has been shipped';
                    break;
                  case 'delivered':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    statusMessage = 'Order #$orderId has been delivered';
                    break;
                  case 'cancelled':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    statusMessage = 'Order #$orderId was cancelled';
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.pending;
                    statusMessage = 'Order #$orderId is being processed';
                }

                notifications.add(
                  _buildNotificationCard(
                    statusColor,
                    statusIcon,
                    statusMessage,
                    formattedDate,
                    deliveryStatus,
                    deliveryStatus.toLowerCase() == 'delivered'
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(
                            orderId: orderId,
                            products: productMap,
                          ),
                        ),
                      );
                    }
                        : null,
                  ),
                );
              } catch (e) {
                debugPrint('Error processing document: $e');
              }
            }

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "All your orders are currently being processed",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              children: notifications,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      Color statusColor,
      IconData statusIcon,
      String message,
      String date,
      String status,
      VoidCallback? onReviewPressed,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            title: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (onReviewPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReviewPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ADD REVIEW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}