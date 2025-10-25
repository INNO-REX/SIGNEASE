export const AudioRecorder = {
  mounted() {
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.audioStream = null;
    this.speechRecognition = null;

    console.log("AudioRecorder hook mounted");

    this.handleEvent("start-recording", async () => {
      console.log("Received start-recording event");
      await this.startRecording();
    });

    this.handleEvent("stop-recording", async () => {
      console.log("Received stop-recording event");
      await this.stopRecording();
    });
  },

  async startRecording() {
    try {
      console.log("Requesting microphone access...");
      this.audioStream = await navigator.mediaDevices.getUserMedia({ 
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 16000
        } 
      });

      console.log("Microphone access granted");

      // Prioritize speech recognition for real-time transcription
      if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
        console.log("Starting browser speech recognition for real-time transcription...");
        this.startSpeechRecognition();
      } else {
        console.log("Speech recognition not available, using audio recording...");
        this.startAudioRecording();
      }
      
    } catch (err) {
      console.error("Error starting recording:", err);
      this.pushEvent("recording-error", { error: err.message });
    }
  },

  startSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    this.speechRecognition = new SpeechRecognition();
    
    this.speechRecognition.continuous = true;
    this.speechRecognition.interimResults = true;
    this.speechRecognition.lang = 'en-US';
    this.speechRecognition.maxAlternatives = 1;

    // Store accumulated final transcript
    this.finalTranscript = '';

    this.speechRecognition.onresult = (event) => {
      let interimTranscript = '';

      for (let i = event.resultIndex; i < event.results.length; i++) {
        const transcript = event.results[i][0].transcript;
        const confidence = event.results[i][0].confidence;
        
        if (event.results[i].isFinal) {
          // Add to final transcript
          this.finalTranscript += transcript + ' ';
          console.log("Final transcript added:", transcript);
        } else {
          // Show interim results in real-time
          interimTranscript += transcript;
        }
      }

      // Send interim results for real-time display
      if (interimTranscript) {
        console.log("Interim transcription:", interimTranscript);
        this.pushEvent("interim-transcription", { text: interimTranscript });
      }
    };

    this.speechRecognition.onerror = (event) => {
      console.warn("Speech recognition error:", event.error);
      // If speech recognition fails, fall back to audio recording
      if (event.error === 'network' || event.error === 'not-allowed') {
        console.log("Falling back to audio recording...");
        this.startAudioRecording();
      }
    };

    this.speechRecognition.onend = () => {
      console.log("Speech recognition ended");
      // Send the accumulated final transcript when recognition ends
      if (this.finalTranscript.trim()) {
        console.log("Sending final accumulated transcript:", this.finalTranscript.trim());
        this.pushEvent("final-transcription", { 
          text: this.finalTranscript.trim(),
          confidence: 0.95,
          language: "en-US"
        });
        this.finalTranscript = ''; // Reset for next recording
      }
    };

    this.speechRecognition.start();
    console.log("Speech recognition started!");
  },

  startAudioRecording() {
    // Determine the best supported audio format
    let mimeType = "audio/webm";
    if (MediaRecorder.isTypeSupported("audio/webm;codecs=opus")) {
      mimeType = "audio/webm;codecs=opus";
    } else if (MediaRecorder.isTypeSupported("audio/mp4")) {
      mimeType = "audio/mp4";
    } else if (MediaRecorder.isTypeSupported("audio/wav")) {
      mimeType = "audio/wav";
    }

    console.log("Using MIME type:", mimeType);

    this.mediaRecorder = new MediaRecorder(this.audioStream, {
      mimeType: mimeType,
      audioBitsPerSecond: 128000
    });

    this.audioChunks = [];

    this.mediaRecorder.ondataavailable = (event) => {
      console.log("Audio data available:", event.data.size, "bytes");
      if (event.data.size > 0) {
        this.audioChunks.push(event.data);
      }
    };

    this.mediaRecorder.onstop = () => {
      console.log("Recording stopped, processing audio...");
      const completeBlob = new Blob(this.audioChunks, { type: mimeType });
      console.log("Audio blob created:", completeBlob.size, "bytes");

      const reader = new FileReader();
      reader.onloadend = () => {
        const base64data = reader.result;
        console.log("Audio converted to base64, sending to server...");
        this.pushEvent("audio-recorded", { audio: base64data });
      };
      reader.readAsDataURL(completeBlob);
    };

    this.mediaRecorder.onerror = (event) => {
      console.error("MediaRecorder error:", event.error);
      this.pushEvent("recording-error", { error: event.error.message });
    };

    // Start recording with time slices for better real-time processing
    this.mediaRecorder.start(1000); // 1 second intervals
    console.log("Audio recording started!");
  },

  async stopRecording() {
    // Stop speech recognition if active
    if (this.speechRecognition) {
      console.log("Stopping speech recognition...");
      this.speechRecognition.stop();
      
      // Send final transcript if we have one
      if (this.finalTranscript && this.finalTranscript.trim()) {
        console.log("Sending final transcript on stop:", this.finalTranscript.trim());
        this.pushEvent("final-transcription", { 
          text: this.finalTranscript.trim(),
          confidence: 0.95,
          language: "en-US"
        });
        this.finalTranscript = '';
      }
      
      this.speechRecognition = null;
    }

    // Stop audio recording if active
    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      console.log("Stopping audio recording...");
      this.mediaRecorder.stop();
    }
    
    // Stop all tracks to release microphone
    if (this.audioStream) {
      this.audioStream.getTracks().forEach(track => {
        track.stop();
        console.log("Audio track stopped");
      });
      this.audioStream = null;
    }
    
    console.log("Recording stopped!");
  },

  destroyed() {
    // Cleanup when component is destroyed
    if (this.audioStream) {
      this.audioStream.getTracks().forEach(track => track.stop());
    }
  }
};
