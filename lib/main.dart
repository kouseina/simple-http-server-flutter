import 'package:flutter/material.dart';
import 'package:simple_http_server/utils/connectivity_utils.dart';
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
  List<String> urlList = [];

  startServer() async {
    setState(() {
      statusText = "Starting server on Port : 8080";
    });

    server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);

    print(
        "Server running on IP : ${server?.address} On Port : ${server?.port}");

    String? wifiIp = await ConnectivityUtils.getIPAddress();

    setState(() {
      urlList = [
        "http://${server?.address.address}:${server?.port}",
        "http://127.0.0.1:${server?.port}",
      ];

      if (wifiIp != null) urlList.add("http://$wifiIp:${server?.port}");
    });

    if (server != null) {
      await for (var request in server!) {
        request.response
          ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
          ..write('Hello, world from http server')
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
      urlList = [];
    });
  }

  void onLaunch(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: urlList.length,
            itemBuilder: (context, index) {
              final url = urlList[index];

              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => onLaunch(url),
                      child: Text(
                        url,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
