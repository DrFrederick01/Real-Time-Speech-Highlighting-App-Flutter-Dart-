import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'voice': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'subscribe': HighlightedWord(
      onTap: () => print('subscribe'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'like': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'comment': HighlightedWord(
      onTap: () => print('comment'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  List<String> noteWords = [];
  List<String> spokenWords = [];
  bool showNotesTextField = true;
  String currentSpokenWord = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void resetLists() {
    setState(() {
      noteWords.clear();
      spokenWords.clear();
    });
  }
  Color _getWordColor(String word, int index) {
    if (spokenWords.isNotEmpty && word == spokenWords.last) {
      int lastHighlightedIndex = spokenWords.indexOf(spokenWords.last);
      return (index == lastHighlightedIndex + 1) ? Colors.blue : Colors.black;
    } else {
      return Colors.black;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16.0, right: 16.0), // Adjust the margin as needed
        child: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
      ),

      body: Column(
        children: [
          Visibility(
            visible: showNotesTextField,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                maxLines: null,
                onChanged: (text) {
                  // Step 2: Split the text into words and populate the noteWords list
                  noteWords = text
                      .toLowerCase() // Convert all words to lowercase
                      .split(RegExp(r'\s|(?=[.,;!?])')) // Split on whitespace or before punctuation
                      .where((word) => word.isNotEmpty) // Filter out empty strings
                      .toList();
                },
                decoration: InputDecoration(
                  hintText: 'Paste your notes here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(26.0),
            child: RichText(
              text: TextSpan(
                children: noteWords.map((noteWord) {
                  var spokenWordsList = spokenWords.join(' ');

                  Color textColor = Colors.black;
                  if (spokenWordsList.contains(noteWord)) {
                    textColor = Colors.blue;
                  }

                  return TextSpan(
                    text: '$noteWord ',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 50,
                    ),
                  );
                }).toList(),
              ),
            ),



          ),



          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextHighlight(
                  text: _text,
                  words: _highlights,
                  textStyle: const TextStyle(
                    fontSize: 16.0, // Adjust the font size to your preference
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),



        ],
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _text = ''; // Clear the displayed text when starting to listen
          showNotesTextField = false; // Hide the text field
        });

        _speech.listen(
          onResult: (val) {
            String newWord = val.recognizedWords.split(' ').last;
            // Print debug information
            print('New Word: $newWord');
            print('Current Spoken Word: $currentSpokenWord');
            print('Spoken Words: $spokenWords');
            // Check if the new word is different from the last spoken word
            if (newWord != currentSpokenWord) {
              setState(() {
                _text = val.recognizedWords;
                currentSpokenWord = newWord;
                spokenWords.add(currentSpokenWord);
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                }
              });
            }
          },
          onSoundLevelChange: (val) {
            // Handle sound level change if needed
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        showNotesTextField = true; // Bring back the text field
        resetLists(); // Call the function to reset the lists
      });
      _speech.stop();
    }
  }

}
