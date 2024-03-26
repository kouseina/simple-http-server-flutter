import 'package:flutter/material.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HttpServer? server;
  String statusText = "Start Server";
  String? url;

  startServer() async {
    setState(() {
      statusText = "Starting server on Port : 8080";
    });

    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

    print(
        "Server running on IP : ${server?.address} On Port : ${server?.port}");

    setState(() {
      url = "http://${server?.address.address}:${server?.port}";
    });

    if (server != null) {
      await for (var request in server!) {
        request.response
          ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
          ..write('Hello, world')
          ..close();
      }
    }

    setState(() {
      statusText =
          "Server running on IP : ${server?.address} On Port : ${server?.port}";
    });
  }

  stopServer() {
    server?.close(force: true);

    setState(() {
      statusText = "Start Server";
      url = null;
    });
  }

  void onLaunch() async {
    if (url == null) return;

    try {
      if (await canLaunchUrl(Uri.parse(url!))) {
        await launchUrl(Uri.parse(url!));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print("error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              startServer();
            },
            child: Text(statusText),
          ),
          const SizedBox(height: 50),
          if (url != null)
            InkWell(
              onTap: onLaunch,
              child: Text(url!),
            ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red.shade500),
            ),
            onPressed: () {
              stopServer();
            },
            child: const Text("Stop server"),
          )
        ],
      ),
    ));
  }
}
