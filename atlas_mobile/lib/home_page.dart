import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors/colors.dart';
import 'diary_page.dart';
import 'google_maps_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}






class _HomePageWidgetState extends State<HomePageWidget> {
  String? name;
  String? email;
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
    print(name);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
      email = prefs.getString('email');
      
    });
  }


















  @override
  Widget build(BuildContext context) {
    return Scaffold(
     


      
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
        
        
        Image.asset(
  'assets/images/banner.png',
  
  width: MediaQuery.of(context).size.width,
  fit: BoxFit.fitWidth,
),
      
      // Add other widgets or components here if needed
    ],
  ),
),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Align(
                      alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 0, 0),
                      
                      
                      
                      child: Text(
                        'Hello',
                       style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight:FontWeight.w400,
                        
                     color: Colors.black,
                    fontSize: 36,
                      
            ),
                      ),
                    
                  
                    ),
                  ],),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children:  [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 0, 0),
                      child: Align(
                       
                      child: Text(
                         name ?? '',
                         style: TextStyle(fontFamily:'Outfit',color:AppColors.primaryColor
                                                ,fontSize: 28,fontWeight:FontWeight.bold
                                                )
                         
                      ),
                    ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                     
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 45, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Material(
                            color: Colors.transparent,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.86,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0, 0.2),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GoogleMapsPage(),
                                  ),
                                );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                15, 0, 0, 0),
                                        child: Image.asset(
                                           
                                          'assets/images/marcador.png',
                                          color: AppColors.backgroundColor,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(

                                          
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(10, 15, 10, 0),
                                              
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                                
                                            children: const [
                                              Text(
                                                'Find Our Location',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(fontFamily:'Outfit',color:AppColors.backgroundColor 
                                                ,fontSize: 19
                                                )
                                                
                                                
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                              0, 0, 0, 8),
                                                  child: Text(
                                                    'Path to your destination',
                                                    textAlign: TextAlign.start,
                                                  style: TextStyle(fontFamily:'Outfit',color:Color(0xB4FFFFFF) 
                                                    
                                                )
                                                       
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryPage(),
                                  ),
                                );
                              },
                              child: Material(
                                color: Colors.transparent,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.86,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                15, 0, 0, 0),
                                        child: Image.asset(
                                          'assets/images/lapis.png',
                                          color: AppColors.backgroundColor,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(10, 15, 10, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Add diary entry',
                                                 textAlign: TextAlign.start,
                                                style: TextStyle(fontFamily:'Outfit',color:AppColors.backgroundColor 
                                                ,fontSize: 19
                                                )
                                                
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                              0, 0, 0, 8),
                                                  child: Text(
                                                    'Send us diary entry, audio, video or text',
                                                     textAlign: TextAlign.start,
                                                    style: TextStyle(fontFamily:'Outfit',color:Color(0xB4FFFFFF) )
                                                        
                                                     
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'atlas.mobile.otp@outlook.pt',
    queryParameters: {
      'subject': 'Atlas',
    },
  );
  //final String emailUrl = emailUri.toString();
 
    await launchUrl(emailUri);

},
                              child: Material(
                                color: Colors.transparent,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.86,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                15, 0, 0, 0),
                                        child: Image.asset(
                                          'assets/images/envelope.png',
                                          color: AppColors.backgroundColor,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(10, 15, 10, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Email Us',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(fontFamily:'Outfit',color:AppColors.backgroundColor 
                                                ,fontSize: 19
                                                )
                                                
                                                    
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                              0, 0, 0, 8),
                                                  child: Text(
                                                    'Send us an email and we will get back to you within 2 days.',
                                                     textAlign: TextAlign.start,
                                                  style: TextStyle(fontFamily:'Outfit',color:Color(0xB4FFFFFF))
                                                        
                                                    
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Demo',
      theme: ThemeData(
        
      ),
      home: HomePageWidget(),
    );
  }
}