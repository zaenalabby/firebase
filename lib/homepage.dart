import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BiodataService.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Biodataservice? service;

  @override
  void initState() {
    service = Biodataservice(FirebaseFirestore.instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(hintText: 'Age'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(hintText: 'Address'),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: service?.getBiodata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error fetching data: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data?.docs.isEmpty == true) {
                      return const Center(child: Text('Empty documents'));
                    }

                    final documents = snapshot.data?.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents?.length,
                      itemBuilder: (context, index) {
                        final doc = documents?[index];
                        return ListTile(
                          title: Text(doc?['name'] ?? 'No Name'),
                          subtitle: Text(doc?['age'] ?? 'No Age'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  nameController.text = doc?['name'] ?? '';
                                  ageController.text = doc?['age'] ?? '';
                                  addressController.text = doc?['address'] ?? '';

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Update Data"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(hintText: 'Name'),
                                          ),
                                          TextField(
                                            controller: ageController,
                                            decoration: const InputDecoration(hintText: 'Age'),
                                          ),
                                          TextField(
                                            controller: addressController,
                                            decoration: const InputDecoration(hintText: 'Address'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (doc?.id != null) {
                                              service?.update(doc!.id, {
                                                'name': nameController.text.trim(),
                                                'age': ageController.text.trim(),
                                                'address': addressController.text.trim(),
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Update"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (doc?.id != null) {
                                    service?.delete(doc!.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final name = nameController.text.trim();
          final age = ageController.text.trim();
          final address = addressController.text.trim();
          service?.add({'name': name, 'age': age, 'address': address});
          nameController.clear();
          ageController.clear();
          addressController.clear();
        },
      ),
    );
  }
}
