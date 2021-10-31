import 'package:flutter/material.dart';
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  void submitForm() {
    if (_formKey.currentState.validate()) {
      removeFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
    }
  }
  void removeFocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/04.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              removeFocus();
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 10,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: Colors.blueGrey.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 40),
                          child: Text(
                            "Search Location",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Icon(
                            Icons.location_pin,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            maxLength: 20,
                            decoration: InputDecoration(
                              filled: true,
                              
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(),
                              hintText: "Search Location",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white.withOpacity(0.8),
                        textStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      child: Text(
                        "Get Weather",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24
                        ),
                      ),
                      onPressed: () {submitForm();},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}