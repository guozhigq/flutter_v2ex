import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/string.dart';

class NetworkCheckPage extends StatefulWidget {
  const NetworkCheckPage({Key? key}) : super(key: key);

  @override
  State<NetworkCheckPage> createState() => _NetworkCheckPageState();
}

class _NetworkCheckPageState extends State<NetworkCheckPage> {
  String response = '';
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    try {
      final res = await Dio().get('${Strings.v2exHost}/');
      response = res.data.toString();
    } on DioException catch (e) {
      response = e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(letterSpacing: 1),
            children: [
              TextSpan(
                  text: '网络信息', style: Theme.of(context).textTheme.titleLarge),
              const TextSpan(text: ' '),
              if (response != '' && response.startsWith('<!DOCTYPE'))
                TextSpan(
                    text: '正常',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),

              if(response != '' && !response.startsWith('<!DOCTYPE'))
                TextSpan(
                    text: '异常',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error)),

            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Text('加载中...'),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                child: Text(response),
              ),
            ),
    );
  }
}
