import 'package:flutter/material.dart';

class BackupCompanionCard extends StatelessWidget {
  const BackupCompanionCard(
      {super.key,
      required this.name,
      required this.phoneNumber,
      required this.address,
      required this.relationship,
      required this.imageUrl});
  final String name;
  final String phoneNumber;
  final String address;
  final String relationship;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phoneNumber,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            Text(
              'Address: $address',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            Text(
              'Relationship: $relationship',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.phone, color: Colors.deepPurpleAccent),
          onPressed: () {
            // Call action
          },
        ),
      ),
    );
  }
}
