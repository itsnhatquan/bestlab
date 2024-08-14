import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode: false),
      child: AboutUsApp(),
    ),
  );
}

class AboutUsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.themeData,
      home: AboutUsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromRGBO(75, 117, 198, 1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              'Project Overview',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to our project, where innovation meets functionality. Our goal is to create an intuitive and robust system that enhances user experience and streamlines operations. By integrating the latest technologies, we aim to deliver a seamless platform that caters to both the front-end and back-end needs of our users. Our focus is on creating user-friendly interfaces coupled with powerful back-end solutions to ensure that the system is both efficient and easy to use.',
              style: TextStyle(fontSize: 18.0, color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
            SizedBox(height: 30),
            Text(
              'Our Team',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Behind this project is a team of dedicated and skilled developers who bring together their expertise in both front-end and back-end development.',
              style: TextStyle(fontSize: 18.0, color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
            SizedBox(height: 20),
            buildTeamMember(
              name: 'Tran Khanh Duc',
              ID: "(s3907087)",
              role: 'UI Developer',
              description:
                  'Tran Khanh Duc is one of our talented UI developers. With a keen eye for design and a passion for creating user-centric interfaces, Duc ensures that our platform is visually appealing and easy to navigate. His work focuses on making sure that users have a pleasant and intuitive experience while interacting with the system.',
              isDarkMode: isDarkMode,
            ),
            buildTeamMember(
              name: 'Nguyen Duc Dai',
              ID: "(s3878023)",
              role: 'UI Developer',
              description:
                  'Nguyen Duc Dai, another key member of our UI development team, brings creativity and technical expertise to the project. Dai works closely with the design and development teams to implement user interfaces that are not only functional but also aesthetically pleasing. His attention to detail helps make the user experience smooth and enjoyable.',
              isDarkMode: isDarkMode,
            ),
            buildTeamMember(
              name: 'Trinh Viet Quy',
              ID: "(s3915202)",
              role: 'Back-End Developer',
              description:
                  'Trinh Viet Quy is a back-end developer who ensures that the server-side of our application is robust and reliable. Quy works tirelessly to implement the logic and database solutions that power our platform, making sure everything runs smoothly behind the scenes.',
              isDarkMode: isDarkMode,
            ),
            buildTeamMember(
              name: 'Tong Nhat Quan',
              ID: "(s3819347)",
              role: 'Back-End Developer',
              description:
                  'Tong Nhat Quan is another crucial member of our back-end team. Quan specializes in optimizing performance and ensuring that our systems can handle high volumes of data efficiently. His expertise ensures that our application remains scalable and efficient.',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Change background color
    );
  }

  Widget buildTeamMember({
    required String name,
    required String ID,
    required String role,
    required String description,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(width: 5), // Add spacing between name and ID
            Text(
              ID,
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        Text(
          role,
          style: TextStyle(
            fontSize: 18.0,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.white54 : Colors.black54,
          ),
        ),
        SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(fontSize: 18.0, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
      ],
    );
  }
}
