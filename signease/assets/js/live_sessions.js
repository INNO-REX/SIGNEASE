// Live Sessions JavaScript functionality
// Handles recording simulation, transcription updates, and accessibility features

let transcriptionInterval;
let animationInterval;
let recordingState = false;

// Initialize live sessions functionality
document.addEventListener('DOMContentLoaded', function() {
  // Small delay to ensure LiveView is fully initialized
  setTimeout(initializeLiveSessions, 100);
});

// Initialize all live sessions features
function initializeLiveSessions() {
  // Only initialize if we're on the live sessions page and not already initialized
  if (document.querySelector('[phx-click="toggle-recording"]') && !window.liveSessionsInitialized) {
    setupRecordingSimulation();
    setupTranscriptionUpdates();
    setupAccessibilityFeatures();
    setupAnimationControls();
    setupRealTimeTranscription();
    window.liveSessionsInitialized = true;
  }
}

// Setup recording simulation
function setupRecordingSimulation() {
  const recordButton = document.querySelector('[phx-click="toggle-recording"]');
  
  if (recordButton) {
    recordButton.addEventListener('click', function() {
      recordingState = !recordingState;
      
      if (recordingState) {
        console.log("Recording state:", recordingState);
        // startRecordingSimulation();
      } else {
        console.log("Recording state:", recordingState);
        // stopRecordingSimulation();
      }
    });
  }
}

// Start recording simulation
function startRecordingSimulation() {
  console.log('Starting recording simulation...');
  
  // Add visual feedback
  const recordButton = document.querySelector('[phx-click="toggle-recording"]');
  if (recordButton) {
    recordButton.classList.add('recording-active');
  }
  
  // Start transcription simulation
  // startTranscriptionSimulation();
}

// Stop recording simulation
function stopRecordingSimulation() {
  console.log('Stopping recording simulation...');
  
  // Remove visual feedback
  const recordButton = document.querySelector('[phx-click="toggle-recording"]');
  if (recordButton) {
    recordButton.classList.remove('recording-active');
  }
  
  // Stop transcription simulation
  // stopTranscriptionSimulation();
}

// Setup transcription updates
function setupTranscriptionUpdates() {
  // Listen for LiveView updates
  document.addEventListener('phx:update', function() {
    if (recordingState) {
      updateTranscriptionDisplay();
    }
  });
}

// Start transcription simulation
function startTranscriptionSimulation() {
  const sampleTexts = [
    "Welcome to today's sign language lesson.",
    "We'll be learning basic greetings today.",
    "Let's start with the sign for 'hello'.",
    "Make sure to follow along with the hand movements.",
    "This is an important foundation for your learning journey.",
    "Practice makes perfect, so don't be afraid to make mistakes.",
    "Remember to maintain eye contact during conversations.",
    "The facial expressions are just as important as the hand signs.",
    "Let's practice the sign for 'thank you'.",
    "Great job everyone! You're making excellent progress."
  ];
  
  let currentIndex = 0;
  
  transcriptionInterval = setInterval(() => {
    if (currentIndex < sampleTexts.length) {
      updateTranscriptionText(sampleTexts[currentIndex]);
      currentIndex++;
    } else {
      // Loop back to start
      currentIndex = 0;
    }
  }, 4000); // Update every 4 seconds
}

// Stop transcription simulation
function stopTranscriptionSimulation() {
  if (transcriptionInterval) {
    clearInterval(transcriptionInterval);
    transcriptionInterval = null;
  }
}

// Update transcription text
function updateTranscriptionText(text) {
  // Find the transcription text element using the specific ID
  const el = document.getElementById("current-transcription");

  if (el instanceof HTMLElement) {
    // Update the text content, preserving any existing structure
    if (text && text.trim() !== "") {
      el.textContent = text;
    } else {
      el.innerHTML = '<span class="text-gray-400 italic">Waiting for speech input...</span>';
    }
    console.log("Transcription updated:", text);
  } else {
    console.warn("Transcription element not found:", el);
  }
}



// Type text effect
function typeText(element, text) {
  element.textContent = '';
  let index = 0;
  
  const typeInterval = setInterval(() => {
    if (index < text.length) {
      element.textContent += text.charAt(index);
      index++;
    } else {
      clearInterval(typeInterval);
    }
  }, 50); // Type speed
}

// Update transcription display
function updateTranscriptionDisplay() {
  const transcriptionContainer = document.querySelector('.transcription-history');
  
  if (transcriptionContainer) {
    // Auto-scroll to bottom
    transcriptionContainer.scrollTop = transcriptionContainer.scrollHeight;
  }
}

// Setup accessibility features
function setupAccessibilityFeatures() {
  // High contrast toggle
  document.addEventListener('click', function(e) {
    if (e.target.closest('[phx-click="toggle-accessibility"]')) {
      const setting = e.target.closest('[phx-click="toggle-accessibility"]').getAttribute('phx-value-setting');
      applyAccessibilitySetting(setting);
    }
  });
}

// Apply accessibility setting
function applyAccessibilitySetting(setting) {
  const body = document.body;
  
  switch (setting) {
    case 'high_contrast':
      body.classList.toggle('high-contrast');
      break;
    case 'large_text':
      body.classList.toggle('large-text');
      break;
    case 'screen_reader':
      body.classList.toggle('screen-reader-friendly');
      break;
  }
}

// Setup animation controls
function setupAnimationControls() {
  document.addEventListener('click', function(e) {
    if (e.target.closest('[phx-click="toggle-animation"]')) {
      toggleSignLanguageAnimation();
    }
  });
}

// Toggle sign language animation
function toggleSignLanguageAnimation() {
  const animationContainer = document.querySelector('.sign-animation-container');
  
  if (animationContainer) {
    const isVisible = animationContainer.style.display !== 'none';
    
    if (isVisible) {
      stopSignLanguageAnimation();
    } else {
      startSignLanguageAnimation();
    }
  }
}

// Start sign language animation
function startSignLanguageAnimation() {
  console.log('Starting sign language animation...');
  
  // Create animation container if it doesn't exist
  let animationContainer = document.querySelector('.sign-animation-container');
  
  if (!animationContainer) {
    animationContainer = document.createElement('div');
    animationContainer.className = 'sign-animation-container fixed bottom-4 right-4 w-64 h-48 bg-white rounded-lg shadow-lg border border-gray-200 z-50';
    animationContainer.innerHTML = `
      <div class="p-4">
        <h4 class="text-sm font-semibold text-gray-900 mb-2">Sign Language Animation</h4>
        <div class="w-full h-32 bg-gradient-to-br from-purple-100 to-indigo-100 rounded-lg flex items-center justify-center">
          <div class="text-center">
            <div class="w-16 h-16 bg-purple-500 rounded-full flex items-center justify-center mx-auto mb-2">
              <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
              </svg>
            </div>
            <p class="text-xs text-gray-600">3D Avatar Animation</p>
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(animationContainer);
  }
  
  animationContainer.style.display = 'block';
  
  // Add animation effects
  animationContainer.classList.add('animate-pulse');
}

// Stop sign language animation
function stopSignLanguageAnimation() {
  console.log('Stopping sign language animation...');
  
  const animationContainer = document.querySelector('.sign-animation-container');
  
  if (animationContainer) {
    animationContainer.style.display = 'none';
    animationContainer.classList.remove('animate-pulse');
  }
}

// Handle LiveView events
document.addEventListener('phx:update', function() {
  // Initialize if not already done (for LiveView navigation)
  if (!window.liveSessionsInitialized) {
    initializeLiveSessions();
    window.liveSessionsInitialized = true;
  }
  
  // Update recording state based on LiveView
  const recordButton = document.querySelector('[phx-click="toggle-recording"]');
  if (recordButton) {
    const isRecording = recordButton.classList.contains('bg-red-500');
    if (isRecording !== recordingState) {
      recordingState = isRecording;
      
      if (recordingState) {

        console.log("Recording state:", recordingState);
        // startRecordingSimulation();
      } else {
        console.log("Recording state:", recordingState);
        // stopRecordingSimulation();
      }
    }
  }
});

// Setup real-time transcription handling
function setupRealTimeTranscription() {
  // Handle transcription updates from LiveView
  window.addEventListener("transcription-update", (event) => {
    const transcription = event.detail.transcription;
    console.log("Transcription update received:", transcription);
    
    // Add to transcription history
    addTranscriptionToHistory(transcription);
    
    // Update statistics
    updateTranscriptionStats();
  });

  // Handle real-time transcription updates
  window.addEventListener("update-current-transcription", (event) => {
    const text = event.detail.text;
    console.log("Real-time transcription:", text);
    
    // Update the current transcription display
    const currentTranscriptionEl = document.getElementById("current-transcription");
    if (currentTranscriptionEl) {
      currentTranscriptionEl.textContent = text;
      currentTranscriptionEl.style.opacity = "0.7"; // Make it slightly transparent to show it's interim
      // Add CSS classes for better text wrapping
      currentTranscriptionEl.classList.add("leading-relaxed", "break-words", "whitespace-pre-wrap");
    }
  });

  // Handle clearing current transcription
  window.addEventListener("clear-current-transcription", (event) => {
    console.log("Clearing current transcription");
    
    const currentTranscriptionEl = document.getElementById("current-transcription");
    if (currentTranscriptionEl) {
      currentTranscriptionEl.textContent = "";
      currentTranscriptionEl.style.opacity = "1";
    }
  });
}

// Add transcription to history
function addTranscriptionToHistory(transcription) {
  const historyContainer = document.getElementById("transcription-history");
  if (!historyContainer) return;

  const transcriptionItem = document.createElement("div");
  transcriptionItem.className = "transcription-item p-3 border-b border-gray-200";
  
  const timestamp = new Date(transcription.timestamp).toLocaleTimeString();
  const confidence = Math.round(transcription.confidence * 100);
  
  // Check if grammar correction is available
  const hasGrammarCorrection = transcription.corrected && transcription.corrected !== transcription.text;
  const grammarConfidence = transcription.grammar_confidence ? Math.round(transcription.grammar_confidence * 100) : null;
  
  transcriptionItem.innerHTML = `
    <div class="flex justify-between items-start">
      <div class="flex-1">
        <p class="text-gray-800 leading-relaxed break-words whitespace-pre-wrap">${transcription.text}</p>
        ${hasGrammarCorrection ? `
          <div class="mt-2 p-2 bg-green-50 border-l-4 border-green-400 rounded">
            <p class="text-sm text-green-800 font-medium">Grammar Corrected:</p>
            <p class="text-green-700 leading-relaxed break-words whitespace-pre-wrap">${transcription.corrected}</p>
            ${grammarConfidence ? `<span class="text-xs text-green-600">${grammarConfidence}% grammar confidence</span>` : ''}
          </div>
        ` : ''}
        <div class="text-sm text-gray-500 mt-1">
          <span>${transcription.speaker}</span> • 
          <span>${timestamp}</span> • 
          <span>${confidence}% confidence</span>
          ${grammarConfidence && !hasGrammarCorrection ? ` • ${grammarConfidence}% grammar` : ''}
        </div>
      </div>
    </div>
  `;
  
  // Add to top of history
  historyContainer.insertBefore(transcriptionItem, historyContainer.firstChild);
}

// Update transcription statistics
function updateTranscriptionStats() {
  const historyContainer = document.getElementById("transcription-history");
  if (!historyContainer) return;
  
  const items = historyContainer.querySelectorAll(".transcription-item");
  const wordCountEl = document.getElementById("words-transcribed");
  const sessionCountEl = document.getElementById("session-count");
  
  if (wordCountEl) {
    let totalWords = 0;
    items.forEach(item => {
      const text = item.querySelector("p").textContent;
      totalWords += text.split(" ").length;
    });
    wordCountEl.textContent = totalWords;
  }
  
  if (sessionCountEl) {
    sessionCountEl.textContent = items.length;
  }
}

// Export functions for global access
// window.LiveSessions = {
//   startRecording: startRecordingSimulation,
//   stopRecording: stopRecordingSimulation,
//   toggleAnimation: toggleSignLanguageAnimation,
//   applyAccessibility: applyAccessibilitySetting
// }; 