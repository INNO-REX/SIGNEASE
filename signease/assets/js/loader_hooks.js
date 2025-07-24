const LoaderHooks = {
  LoaderHook: {
    mounted() {
      this.showLoader = () => {
        this.el.classList.add('active');
        this.startProgressAnimation();
      };

      this.hideLoader = () => {
        this.el.classList.remove('active');
        this.stopProgressAnimation();
      };

      this.startProgressAnimation = () => {
        const progressBar = this.el.querySelector('.loader-progress-bar');
        if (progressBar) {
          let progress = 0;
          this.progressInterval = setInterval(() => {
            progress += Math.random() * 15;
            if (progress > 90) progress = 90;
            progressBar.style.width = `${progress}%`;
          }, 200);
        }
      };

      this.stopProgressAnimation = () => {
        if (this.progressInterval) {
          clearInterval(this.progressInterval);
          this.progressInterval = null;
        }
        const progressBar = this.el.querySelector('.loader-progress-bar');
        if (progressBar) {
          progressBar.style.width = '0%';
        }
      };

      // Listen for custom events
      this.handleEvent("show-loader", ({ message, subtext, progress }) => {
        if (message) this.el.querySelector('.loader-text').textContent = message;
        if (subtext) this.el.querySelector('.loader-subtext').textContent = subtext;
        if (progress) this.el.querySelector('.loader-progress-bar').style.width = `${progress}%`;
        this.showLoader();
      });

      this.handleEvent("hide-loader", () => {
        this.hideLoader();
      });

      this.handleEvent("update-progress", ({ progress }) => {
        const progressBar = this.el.querySelector('.loader-progress-bar');
        if (progressBar && progress !== undefined) {
          progressBar.style.width = `${progress}%`;
        }
      });

      // Cleanup on destroy
      this.destroyed = () => {
        this.stopProgressAnimation();
      };
    }
  },

  // Hook for form submissions
  FormLoaderHook: {
    mounted() {
      this.originalText = this.el.textContent;
      this.originalDisabled = this.el.disabled;

      this.showFormLoader = (text = "Processing...") => {
        this.el.disabled = true;
        this.el.innerHTML = `
          <div class="loader-compact">
            <div class="loader-compact-spinner"></div>
            <span>${text}</span>
          </div>
        `;
      };

      this.hideFormLoader = () => {
        this.el.disabled = this.originalDisabled;
        this.el.textContent = this.originalText;
      };

      // Listen for form events
      this.handleEvent("show-form-loader", ({ text }) => {
        this.showFormLoader(text);
      });

      this.handleEvent("hide-form-loader", () => {
        this.hideFormLoader();
      });

      // Handle form submission
      this.el.addEventListener('submit', () => {
        this.showFormLoader();
      });
    }
  },

  // Hook for page transitions
  PageLoaderHook: {
    mounted() {
      this.showPageLoader = () => {
        this.el.classList.add('active');
      };

      this.hidePageLoader = () => {
        this.el.classList.remove('active');
      };

      // Listen for page loading events
      window.addEventListener('phx:page-loading-start', () => {
        this.showPageLoader();
      });

      window.addEventListener('phx:page-loading-stop', () => {
        this.hidePageLoader();
      });
    }
  }
};

export default LoaderHooks; 