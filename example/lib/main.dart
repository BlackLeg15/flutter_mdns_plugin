import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';

void main() => runApp(const MyApp());

const String discoveryService = "_googlecast._tcp";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterMdnsPlugin _mdnsPlugin;
  List<String> messageLog = <String>[];
  late DiscoveryCallbacks discoveryCallbacks;

  @override
  initState() {
    super.initState();

    discoveryCallbacks = DiscoveryCallbacks(
      onDiscovered: (ServiceInfo info) {
        debugPrint("Discovered ${info.toString()}");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Discovered ${info.toString()}");
        });
      },
      onDiscoveryStarted: () {
        debugPrint("Discovery started");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Discovery Running");
        });
      },
      onDiscoveryStopped: () {
        debugPrint("Discovery stopped");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Discovery Not Running");
        });
      },
      onResolved: (ServiceInfo info) {
        debugPrint("Resolved Service ${info.toString()}");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Resolved ${info.toString()}");
        });
      },
    );

    messageLog.add("Starting mDNS for service [$discoveryService]");
    startMdnsDiscovery(discoveryService);
  }

  startMdnsDiscovery(String serviceType) {
    _mdnsPlugin = FlutterMdnsPlugin(discoveryCallbacks: discoveryCallbacks);
    // cannot directly start discovery, have to wait for ios to be ready first...
    Timer(const Duration(seconds: 3), () => _mdnsPlugin.startDiscovery(serviceType));
//    mdns.startDiscovery(serviceType);
  }

  @override
  void reassemble() {
    super.reassemble();
    _mdnsPlugin.restartDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: ListView.builder(
        reverse: true,
        itemCount: messageLog.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(messageLog[index]);
        },
      )),
    );
  }
}
