import 'package:flutter/material.dart';
import 'package:herfay/model/item_model.dart';
import 'package:provider/provider.dart';
import '../../../data/db/auth.dart';
import 'controller/employer_controller.dart';

class EmployerScreen extends StatelessWidget {
  const EmployerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => EmployerController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Auth.currentUser()!.userMetadata!['name'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () => Auth.signOut(),
            child: Icon(Icons.logout_outlined, size: 24, color: Colors.red),
          ),
        ),

        // -------------------- BODY --------------------
        body: CustomScrollView(
          slivers: [
            // Space before grid
            SliverToBoxAdapter(child: SizedBox(height: 70)),

            // Product Grid
            Consumer<EmployerController>(
              builder: (context, value, child) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: 0.56,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final ItemModel item = value.items[index];

                      return Card(
                        color: Colors.blueAccent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              SizedBox(height: 20),

                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.20,

                                width: double.infinity,

                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      child: Image.network(
                                        "https://tqqyzwxhikysljtvxjhl.supabase.co/storage/v1/object/public/image_item/easy_chocolate_cake_slice.webp",
                                      ),
                                    ),

                                    Text(
                                      item.item_name,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => value.incrementItem(index),
                                    child: Text("+"),
                                  ),
                                  CircleAvatar(
                                    child: Text(
                                      value.itemCount[index].toString(),
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () => value.decrementItem(index),
                                    child: Text("-"),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Confirme"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: value.items.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
