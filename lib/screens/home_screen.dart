import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prismaerd/providers/services_provider.dart';
import 'package:prismaerd/widgets/show_toast.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? errorString;
  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, child) => Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: const Text('PrismaErd'),
          titleTextStyle: TextStyle(
            fontSize: 20.sp,
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            servicesProvider.isLoading
                ? const SizedBox()
                : Padding(
                    padding: EdgeInsets.only(right: 16.h),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      onPressed: () => servicesProvider.inputController.clear(),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ],
        ),
        body: servicesProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8.0.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0.r),
                          child: TextField(
                            autocorrect: false,
                            controller: servicesProvider.inputController,
                            textAlign: TextAlign.start,
                            expands: true,
                            maxLines: null,
                            decoration: InputDecoration(
                              errorText: errorString,
                              hintText: 'Enter prisma schema',
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.all(8.0),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0.r),
                          ),
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: () {
                          if (servicesProvider.inputController.text.isEmpty) {
                            showToast('Schema cannot be empty');
                          } else {
                            servicesProvider.generate(
                                context,
                                servicesProvider.inputController.text
                                    .toString());
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: const Text(
                            'Generate',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
