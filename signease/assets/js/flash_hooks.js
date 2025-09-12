// Flash message auto-dismiss functionality
const FlashHooks = {
  mounted() {
    // Auto-dismiss this specific flash message after 5 seconds
    setTimeout(() => {
      this.dismissFlash();
    }, 5000);
  },

  dismissFlash() {
    // Fade out this specific flash message
    this.el.style.transition = 'opacity 0.5s ease-out';
    this.el.style.opacity = '0';
    setTimeout(() => {
      if (this.el.parentNode) {
        this.el.parentNode.removeChild(this.el);
      }
    }, 500);
  }
};

export default FlashHooks; 