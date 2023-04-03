import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AgreementPage extends StatelessWidget {
  const AgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( Get.parameters['source'] == 'privacy' ? '隐私政策' : '用户协议'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '欢迎使用我们的应用程序。本隐私政策旨在向您介绍我们如何收集、使用和共享关于您的信息。我们会尊重您的隐私并保护您的数据。如果您有任何问题，请随时联系我们。我们会尽力为你解答疑问。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 25),
              Text(
                '信息收集和使用',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '我们不会收集、存储、分享或使用您的个人身份信息。我们仅收集您的匿名数据以改进您的应用体验。例如，我们可能会记录您访问应用程序中的哪些页面，使用了哪些功能，并记录一些设备信息，例如您的操作系统版本和移动设备型号。这些数据与您的身份信息是分离的，不会被用于任何其他目的。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 25),
              Text(
                '数据安全',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '我们会采取合理的措施来保护您的数据，并确保其完整性。我们将尽力防止未经授权访问、使用、更改或泄露您的数据。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 25),
              Text(
                '法律信息',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '我们将尽力遵守适用的隐私法律。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 25),
              Text(
                '变更与更新',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '我们保留随时更新或修改本隐私政策的权利。如果我们对本隐私政策进行重大更改，我们将通过向您发送电子邮件或在我们的网站上发布通知来通知您。为了确保您了解我们如何收集和使用您的数据，我们建议您定期查看此页面以获取最新信息。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 25),
              Text(
                '联系我们',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '如果您对本隐私政策有任何疑问或意见，请与我们联系。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text('Email: guozhigq@outlook.com'),
              SizedBox(height: 25),
              Text('感谢您使用我们的应用！', style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
