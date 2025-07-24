// Live Sessions JavaScript functionality
// Handles recording simulation, transcription updates, and accessibility features

let transcriptionInterval;
let animationInterval;
let recordingState = false;

// Initialize live sessions functionality
document.addEventListener('DOMContentLoaded', function() {
  initializeLiveSessions();
});

// Initialize all live sessions features
function initializeLiveSessions() {
  setupRecordingSimulation();
  setupTranscriptionUpdates();
  setupAccessibilityFeatures();
  setupAnimationControls();
}

// Setup recording simulation
function setupRecordingSimulation() {
  const recordButton = document.querySelector('[phx-click="toggle-recording"]');
  
  if (recordButton) {
    recordButton.addEventListener('click', function() {
      recordingState = !recordingState;
      
      if (recordingState) {
        startRecordingSimulation();
      } else {
        stopRecordingSimulation();
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
  startTranscriptionSimulation();
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
  stopTranscriptionSimulation();
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
  // Find the transcription display element
  const transcriptionDisplay = document.querySelector('.transcription-current');
  
  if (transcriptionDisplay) {
    // Add typing effect
    typeText(transcriptionDisplay, text);
  }
  
  // Send to LiveView
  if (window.liveSocket) {
    window.liveSocket.execJS(document, "update-transcription", {text: text});
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
  // Update recording state based on LiveView
  const recordButton = document.querySelector('[phx-click="toggle-recording"]');
  if (recordButton) {
    const isRecording = recordButton.classList.contains('bg-red-500');
    if (isRecording !== recordingState) {
      recordingState = isRecording;
      
      if (recordingState) {
        startRecordingSimulation();
      } else {
        stopRecordingSimulation();
      }
    }
  }
});

// Export functions for global access
window.LiveSessions = {
  startRecording: startRecordingSimulation,
  stopRecording: stopRecordingSimulation,
  toggleAnimation: toggleSignLanguageAnimation,
  applyAccessibility: applyAccessibilitySetting
}; 