import 'package:fight_climate_war/screens/user_auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;
import 'package:firebase_core/firebase_core.dart';


// STAGE 1:

// TODO: - fix BottomTabBar bugs
// TODO: - organise stuff into files + organise classes
// TODO: - add actual searching functionality
// TODO: - set up backend (we can already parse JSON from a google example)
// TODO: - let user add locations + information
// TODO: - make something prettier happen when user clicks locations
// TODO: - make main page & styling
// TODO: - comments (sorry)

void main() async  {
  // We have to load Flutter widgets before initializing Firebase app.
  // There would be an error if we don't do this step.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase app.
  await Firebase.initializeApp();

  runApp(const SearchPage());
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the MainPage widget.
        //'/': (context) => const MainPage(),
        // When navigating to the "/second" route, build the SecondRoute widget.
        '/second': (context) => const SecondRoute(),

      },
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ),
            );
          },
          child: Text("Sign up")
        ),
          appBar: AppBar(
            title: const Text('Search Google Locations...'),
            backgroundColor: Colors.green[700],
          ),
          body: Scaffold(
            body: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              markers: _markers.values.toSet(),
            ),
            bottomNavigationBar: DefaultTabController(
              length: 2,
              child: _OptionBottomBar(
              ),
              initialIndex: 1,
            ),
          )
      ),
    );
  }
}

class _OptionBottomBar extends StatelessWidget{
  const _OptionBottomBar({
    this.fabLocation = FloatingActionButtonLocation.endDocked,
  });

  final FloatingActionButtonLocation fabLocation;

  static final List<FloatingActionButtonLocation> centerLocations =
  <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  //late final _tabController = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.blue,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: TabBar( //TabBar at bottom of appbar
          onTap: (index){
            if(index == 0 && !Navigator.canPop(context)) {
              Navigator.pushNamed(context, '/second');
            }
            if(index == 1 && Navigator.canPop(context)) {
              Navigator.pop(context);
              //SearchPage.
            }
          },
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.search))
            //more tabs here
          ],
        ),

      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("This will be the main page"),
        backgroundColor: Colors.green,
      ), // AppBar
      body: Scaffold(
        body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back!'),
            ), // ElevatedButton
          ),
        bottomNavigationBar: DefaultTabController(
        length: 2,
        child: _OptionBottomBar(
          ),
            initialIndex: 0
        ),
      ), // Center
    ); // Scaffold
  }
}