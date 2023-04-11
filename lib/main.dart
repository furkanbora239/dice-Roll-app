// ignore_for_file: camel_case_types
import 'package:dice_remix/provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

ValueNotifier isPressed = ValueNotifier([false, false, false]);
bool vibration = true;

final Uri _url = Uri.parse(
    'https://doc-hosting.flycricket.io/dice-roller-privacy-policy/297751e0-e537-4bd2-8eef-33213355c340/privacy');
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

Future<void> vibPref(data) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('vib', data);
}

Future<void> chackVib() async {
  final prefs = await SharedPreferences.getInstance();
  vibration = prefs.getBool('vib') ?? true;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MultiProvider(
            providers: [ChangeNotifierProvider(create: (_) => pro())],
            child: const MyApp(),
          )));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: const diceScreen(),
    );
  }
}

int diceNumberSum = 0;

int diceRoll() {
  return Random().nextInt(6) + 1;
}

class diceScreen extends StatefulWidget {
  const diceScreen({super.key});

  @override
  State<diceScreen> createState() => _diceScreenState();
}

class _diceScreenState extends State<diceScreen> {
  @override
  void initState() {
    chackVib();
    diceNumberSum = context.read<pro>().diceList.first;
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      // Do stuff on phone shake
      context.read<pro>().reRollDices();
      if (vibration) {
        HapticFeedback.mediumImpact();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'haptic feedback',
                      textAlign: TextAlign.center,
                    ),
                    Switch(
                        value: vibration,
                        onChanged: (value) {
                          setState(() {
                            vibration = value;

                            vibPref(vibration);
                          });
                        }),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    const Duration(milliseconds: 100);
                    showAboutDialog(
                        applicationVersion: '2.0.0',
                        context: context,
                        applicationName: 'Roll The Dice',
                        applicationLegalese:
                            "we do not collect your personal data in any way. this is just a dice rolling application. ",
                        children: [
                          TextButton(
                              onPressed: () => _launchUrl(),
                              child: const Text(
                                  'for more about privacy policy look here.'))
                        ]);
                  },
                  child: const Text('More Info')),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('sum of dice $diceNumberSum'),
      ),
      bottomNavigationBar: const myBottomNavBar(),
      body: GridView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: context.watch<pro>().diceList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.read<pro>().diceList.length > 6
                  ? 3
                  : context.read<pro>().diceList.length > 2
                      ? 2
                      : 1,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5),
          itemBuilder: (context, index) {
            return GestureDetector(
              onDoubleTap: () => setState(
                  () => context.read<pro>().diceList[index] = diceRoll()),
              child: Image.asset(
                  'images/dice${context.read<pro>().diceList[index]}.png',
                  color: Colors.black),
            );
          }),
    );
  }
}

class myBottomNavBar extends StatefulWidget {
  const myBottomNavBar({super.key});

  @override
  State<myBottomNavBar> createState() => _myBottomNavBarState();
}

class _myBottomNavBarState extends State<myBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 9.5,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, -5),
              color: Colors.grey.shade500,
              blurRadius: 20,
              spreadRadius: 15)
        ],
        color: Theme.of(context).primaryColor,
      ),
      child: ValueListenableBuilder(
        valueListenable: isPressed,
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              neoButton(
                listBool: value[0],
                listKey: 0,
                onTap: () {
                  setState(() {
                    context.read<pro>().diceAdd();
                    if (vibration) {
                      HapticFeedback.lightImpact();
                    }
                  });
                },
                onLongPress: () {
                  setState(() {
                    for (int i = 0; i <= 10; i++) {
                      context.read<pro>().diceAdd();
                    }
                    if (vibration) {
                      HapticFeedback.mediumImpact();
                    }
                  });
                },
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).canvasColor,
                  size: MediaQuery.of(context).size.height / 17,
                ),
              ),
              neoButton(
                listBool: value[1],
                listKey: 1,
                onTap: () {
                  setState(() {
                    context.read<pro>().reRollDices();
                    if (vibration) {
                      HapticFeedback.lightImpact();
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        'Roll Dice',
                        style: TextStyle(
                            color: Theme.of(context).canvasColor,
                            fontSize: MediaQuery.of(context).size.height / 30),
                      ),
                      Icon(
                        Icons.refresh,
                        color: Theme.of(context).canvasColor,
                        size: MediaQuery.of(context).size.height / 17,
                      ),
                    ],
                  ),
                ),
              ),
              neoButton(
                listBool: value[2],
                listKey: 2,
                onTap: () {
                  setState(() {
                    context.read<pro>().diceRemove();
                    if (vibration) {
                      HapticFeedback.lightImpact();
                    }
                  });
                },
                onLongPress: () {
                  setState(() {
                    for (int i = 0; i <= 10; i++) {
                      context.read<pro>().diceRemove();
                    }
                    if (vibration) {
                      HapticFeedback.mediumImpact();
                    }
                  });
                },
                child: Icon(
                  Icons.remove,
                  color: Theme.of(context).canvasColor,
                  size: MediaQuery.of(context).size.height / 17,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class neoButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap, onLongPress;
  final int listKey;
  final bool listBool;
  const neoButton(
      {super.key,
      required this.child,
      this.onLongPress,
      this.onTap,
      required this.listKey,
      required this.listBool});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 13),
      duration: const Duration(milliseconds: 90),
      decoration: BoxDecoration(
          boxShadow: listBool
              ? [
                  // button basılıyken gölge olmaması için boş
                ]
              : [
                  const BoxShadow(
                      color: Color.fromARGB(56, 255, 255, 255),
                      offset: Offset(-4, -4),
                      blurRadius: 10,
                      spreadRadius: 1),
                  const BoxShadow(
                      color: Color.fromARGB(152, 33, 33, 33),
                      offset: Offset(4, 4),
                      blurRadius: 10,
                      spreadRadius: 1)
                ],
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6)),
      child: GestureDetector(
          onTap: onTap,
          onTapUp: (details) {
            isPressed.value = List.from(isPressed.value)..[listKey] = false;
          },
          onLongPress: onLongPress,
          onLongPressDown: (details) {
            isPressed.value = List.from(isPressed.value)..[listKey] = true;
          },
          onLongPressUp: () {
            isPressed.value = List.from(isPressed.value)..[listKey] = false;
          },
          child: child),
    );
  }
}
