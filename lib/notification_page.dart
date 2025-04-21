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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: StreamBuilder<QuerySnapshot>(
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
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text("Error loading notifications", style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final docs = snapshot.data!.docs;
            docs.sort((a, b) {
              final aTimestamp = (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              final bTimestamp = (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              return bTimestamp.compareTo(aTimestamp);
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
                    statusIcon = Icons.local_shipping_outlined;
                    statusMessage = 'Your order #$orderId is on the way!';
                    break;
                  case 'delivered':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle_outline;
                    statusMessage = 'Order #$orderId delivered successfully!';
                    break;
                  case 'cancelled':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel_outlined;
                    statusMessage = 'Order #$orderId was cancelled';
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.sync;
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
              return _buildEmptyState();
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Latest Updates",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ...notifications,
              ],
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          if (onReviewPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onReviewPressed,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Add Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "No order updates yet",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "You’ll see shipping and delivery updates for your orders here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
