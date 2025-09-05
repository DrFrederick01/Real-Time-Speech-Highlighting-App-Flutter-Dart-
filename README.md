# 🎤 Real-Time Speech Highlighting App  

When I do any form of public speaking e.g. giving talks or presentations, I sometimes found myself losing my lines 
I’d look down at my notes and waste time searching for where I left off, this would break my rhythm and made me feel disconnected from the audience.  

So I built this app: a simple **speech-to-text highlighter** that listens as I speak and **highlights the words in my notes in real time**.  
That way, when I glance down, I instantly know exactly where to pick up.  

I’m also new to **Android Studio** and wanted a hands-on way to practice building Android apps with **Flutter** and explore a bit of **Kotlin** later. This project was a way of solving my own problem while learning something new.  

---

## Objective  

- Prevent losing my place while speaking  
- Visually highlight text as I read it out loud  
- Build something useful while practicing Flutter and Dart  

---

## Tech Stack  

- **Flutter (Dart)**  
- **speech_to_text** → live speech recognition  
- **highlight_text** → text styling for specific words  
- **avatar_glow** → mic glow animation  

---

## How It Works  

1. Paste your notes into the text field.  
2. Tap the glowing mic button to start listening.  
3. Speak the words from your notes.  
4. The app compares what you say to your notes and **highlights the spoken words in blue**.  
5. If you stop the mic, you can reset and paste new notes.  

---

## Example Code  

A few blocks that show how I tackled this:

### 🎯 Listening to speech
```dart
_speech.listen(
  onResult: (val) {
    setState(() {
      _text = val.recognizedWords;
      spokenWords.add(val.recognizedWords);
      if (val.hasConfidenceRating && val.confidence > 0) {
        _confidence = val.confidence;
      }
    });
  },
);
```
🎯 Highlighting the spoken words
```RichText(
  text: TextSpan(
    children: noteWords.map((noteWord) {
      Color textColor = Colors.black;
      if (spokenWords.join(' ').contains(noteWord)) {
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
);
```
🎯 Hiding the text field when mic is active

```Visibility(
  visible: showNotesTextField,
  child: TextField(
    onChanged: (text) {
      noteWords = text.split(' ');
    },
  ),
);
```
---

## Challenges  

- **Matching words**: speech recognition sometimes returns full phrases, not single words.  
- **Repeated words**: if a word appears multiple times, all get highlighted at once.  
- **Managing UI state**: keeping track of when to hide notes, reset, and resume listening.  
- **Speech recognition quirks**: different confidence levels and inconsistent results.  

---

## What I Learned  

- Integrating **third-party packages** into a Flutter project.  
- Using **setState** effectively for live UI updates.  
- How widgets like **RichText**, **Visibility**, and **AvatarGlow** can create smooth interactive experiences.  
- Debugging **real-time interactions** is trickier than static apps — but also much more rewarding.  

---

## Next Steps  

- Improve matching so only the **next correct word** is highlighted (instead of all matches).  
- Save and load **notes locally** for easier re-use.  
- Experiment with **Kotlin** to create a native version for comparison.  
- Polish the **UI with animations** and progress indicators.  

---

## Screenshots  

👉 Add your screenshots to `/screenshots/` and reference them like this:  

```markdown
<img src="screenshots/app_notes.png" height="50%" width="50%" />
<img src="screenshots/app_highlighting.png" height="50%" width="50%" />

