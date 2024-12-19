import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/AppFunction/global_variables.dart';
import 'package:flutter_app/provider/event_provider.dart';
import 'package:flutter_app/provider/pole_provider.dart';
import 'package:flutter_app/provider/page_controller_provider.dart';
import 'package:flutter_app/widgets/navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'AppFunction/mqtt_manager.dart';
import 'package:flutter_app/AppFunction/global_helper_function.dart';

// import 'pages/home_page.dart';
// import 'pages/light_control_page.dart';
// import 'pages/lighting_schedule_page.dart';
// import 'pages/security_cameras_page.dart';
// import 'pages/advertisement_schedule_page.dart';
// import 'pages/environmental_sensors_page.dart';
// import 'pages/historical_data_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  MqttManager();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    global_databaseReference = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DATABASE_URL,
    ).ref();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PoleProvider()..initializePoles(),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomAppointmentProvider(),
        ),
        ChangeNotifierProvider(create: (_) => PageControllerProvider())
      ],
      child: MaterialApp(
        navigatorKey:
            GlobalHelper.navigatorKey, // Assign the global navigator key
        theme: ThemeData(
          textTheme: GoogleFonts.mulishTextTheme(
            Theme.of(context).textTheme,
          ),
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageControllerProvider>(
      builder: (context, pageControllerProvider, child) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    const Expanded(
                      flex: 126,
                      child:
                          SizedBox(), // Replace this with your desired widget
                    ),
                    Expanded(
                      flex: 889,
                      child: Container(
                        // Margin = navigation drawer before expanding 103 + padding 20
                        margin: USE_BORDER_RADIUS
                            ? const EdgeInsets.only(
                                left: 123, right: 10, top: 0, bottom: 10)
                            : const EdgeInsets.only(
                                left: 113, right: 10, top: 0, bottom: 10),
                        // Add border radius everywhere = drawer border radius = 31 for child: _pages.elementAt(_selectedIndex),
                        child: Container(
                          //border with color #E6E5F2 width 10
                          decoration: BoxDecoration(
                            borderRadius: USE_BORDER_RADIUS
                                ? BorderRadius.circular(31)
                                : BorderRadius.circular(0),
                            // border: Border.all(
                            //     color: PRIMARY_PAGE_BORDER_COLOR, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: USE_BORDER_RADIUS
                                ? BorderRadius.circular(31)
                                : BorderRadius.circular(0),
                            child: pageControllerProvider.pages.elementAt(
                                pageControllerProvider.selectedIndex),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: CustomNavigationDrawer(
                  selectedIndex: pageControllerProvider.selectedIndex,
                  onDestinationSelected: pageControllerProvider.setIndex,
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      //Icon settings white with black stroke
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Add your settings page navigation here
                      },
                    ),
                    const SizedBox(width: 23),
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        // Add your notifications page navigation here
                      },
                    ),
                    const SizedBox(width: 23),
                    // Logo with rounded border corner white background and black stroke total width of Container = 35
                    Container(
                      decoration: BoxDecoration(
                        color: PRIMARY_WHITE_COLOR,
                        borderRadius: BorderRadius.circular(31),
                        border: Border.all(color: PRIMARY_BLACK_COLOR),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(
                          'lib/assets/icons/Logo-DH-Bach-Khoa-HCMUT.png',
                          height: 25),
                    ),
                    const SizedBox(width: 23),
                    Container(
                      // CSE, BOLD
                      child: const Text('CSE',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 38)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
