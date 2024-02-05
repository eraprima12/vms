import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyListPage extends StatelessWidget {
  const CompanyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company List'),
      ),
      body: const CompanyList(),
    );
  }
}

class CompanyList extends StatelessWidget {
  const CompanyList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('company').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var companies = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: companies.length,
          itemBuilder: (context, index) {
            var company = companies[index].data();
            return CompanyCard(company: company);
          },
        );
      },
    );
  }
}

Future<void> _updateApprovalStatus(bool newStatus, String uid) async {
  try {
    await FirebaseFirestore.instance
        .collection('company')
        .doc(uid) // Assuming 'uid' is the unique identifier for each company
        .update({'approved': newStatus});

    // Perform any additional actions after the update, if needed
  } catch (error) {
    print('Error updating approval status: $error');
    // Handle error, show snackbar, etc.
  }
}

class CompanyCard extends StatelessWidget {
  final Map<String, dynamic> company;

  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(company['name']),
        subtitle: Text(
            'Created at: ${(company['created_at'] as Timestamp).toDate()}'),
        trailing: ElevatedButton(
          onPressed: () {
            _updateApprovalStatus(!company['approved'], company['uid']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: company['approved'] ? Colors.green : Colors.red,
          ),
          child: Text(company['approved'] ? 'Approved' : 'Not Approved'),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CompanyListPage(),
  ));
}
