# Speech-to-Text Testing Guide

## 🎯 How to Test the Live Session Speech-to-Text Functionality

The SIGNEASE live session speech-to-text feature is now working! Here's how to test it:

### 1. **Access the Live Session Page**
- Open your browser and go to: `http://localhost:4000`
- Navigate to the learner live sessions page: `http://localhost:4000/learner/live-sessions`

### 2. **Test the Recording Functionality**

#### **Step 1: Start Recording**
- Click the large circular **Record Button** (microphone icon)
- Your browser will ask for microphone permission - **click "Allow"**
- The button will turn red and show "Recording in progress..."
- You'll see a pulsing animation indicating active recording

#### **Step 2: Speak into Your Microphone**
- Speak clearly into your microphone for 3-5 seconds
- Say something like: "Hello, this is a test of the speech-to-text functionality"
- The system will capture your audio

#### **Step 3: Stop Recording**
- Click the **Record Button** again to stop recording
- The button will return to blue (microphone icon)
- You'll see "Processing transcription..." message

#### **Step 4: View Results**
- After 1-2 seconds, you should see the transcribed text appear in the **Live Transcription** panel
- The text will show up in the current transcription area
- It will also be added to the transcription history below

### 3. **What You Should See**

#### **Without Google Speech API Key (Mock Mode)**
- The system will use mock transcription
- You'll see pre-written educational phrases like:
  - "Hello, welcome to today's sign language lesson."
  - "We will be learning basic greetings today."
  - "Let's start with the sign for hello."

#### **With Google Speech API Key (Real Transcription)**
- Set the environment variable: `export GOOGLE_SPEECH_API_KEY="your_api_key_here"`
- Restart the server: `mix phx.server`
- You'll get real transcription of your actual speech

### 4. **Additional Features to Test**

#### **Accessibility Settings**
- Toggle **High Contrast** mode
- Enable **Large Text** for better readability
- Test **Screen Reader** compatibility

#### **Animation Features**
- Click **"Show Signs"** to enable sign language animation
- Click **"Stop Signs"** to disable animation

#### **Quick Actions**
- Click **"Ask Question"** to simulate asking a class question
- Use **"Clear"** to clear the transcription history

### 5. **Troubleshooting**

#### **If Recording Doesn't Work:**
1. Check browser console for errors (F12 → Console)
2. Ensure microphone permission is granted
3. Try refreshing the page
4. Check if your microphone is working in other applications

#### **If Transcription Doesn't Appear:**
1. Check the server console for error messages
2. Ensure you spoke clearly and loudly enough
3. Try recording for a longer duration (5+ seconds)
4. Check browser console for JavaScript errors

#### **Browser Compatibility:**
- **Chrome/Edge**: Full support
- **Firefox**: Full support
- **Safari**: Limited support (may need different audio format)

### 6. **Expected Console Output**

When working correctly, you should see these messages in the browser console:
```
AudioRecorder hook mounted
Requesting microphone access...
Microphone access granted
Using MIME type: audio/webm;codecs=opus
Recording started successfully!
Recording stopped, processing audio...
Audio blob created: [size] bytes
Audio converted to base64, sending to server...
```

And in the server console:
```
🎤 Starting recording for user: [User Name]
🎵 Received audio data from frontend
🎵 Audio data size: [size] characters
🔄 Task started - attempting transcription...
⚠️ No Google Speech API key found, using mock transcription
🎉 Mock transcription successful!
📨 Received transcription result in handle_info
📝 Adding transcription to UI: "[transcribed text]"
```

### 7. **Next Steps**

Once you've confirmed the basic functionality works:

1. **Get a Google Speech API Key** for real transcription:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable the Speech-to-Text API
   - Create credentials (API key)
   - Set: `export GOOGLE_SPEECH_API_KEY="your_key"`

2. **Test with Real Speech**:
   - Restart the server with the API key
   - Record actual speech and verify accurate transcription

3. **Customize Settings**:
   - Modify language codes in the code
   - Adjust audio quality settings
   - Add more accessibility features

## 🎉 Success Indicators

You'll know it's working when:
- ✅ Microphone permission is granted
- ✅ Recording button changes color and shows animation
- ✅ Audio is captured (check console logs)
- ✅ Transcription appears after stopping recording
- ✅ Text is added to the transcription history
- ✅ Session stats update (words transcribed counter)

The speech-to-text functionality is now fully operational! 🚀