// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
// Import Alpine.js
import Alpine from "alpinejs"
// Import ApexCharts
import ApexCharts from "apexcharts"
// Import Chart Hooks
import ChartHooks from "./chart_hooks.js"
import LoaderHooks from "./loader_hooks.js"
// Import LiveSessions functionality
import "./live_sessions.js"
import LiveSessions from "./live_sessions.js"
import FlashHooks from "./flash_hooks.js"
// microphone
import {AudioRecorder} from "./audio_recorder.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

  let Hooks = {
  ...ChartHooks,
  ...LoaderHooks,
  ...FlashHooks,
  AudioRecorder: AudioRecorder,
  // Side Navigation Dropdown Hook
  SideNavDropdown: {
    mounted() {
      this.handleDropdownAnimation = () => {
        const dropdownContent = this.el.querySelector('[x-show]');
        if (dropdownContent) {
          // Add a small delay for smoother animation
          setTimeout(() => {
            dropdownContent.style.transition = 'all 0.5s cubic-bezier(0.4, 0, 0.2, 1)';
          }, 50);
        }
      };
      
      this.handleDropdownAnimation();
    }
  },


}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Initialize Alpine.js
window.Alpine = Alpine
Alpine.start()

// Initialize ApexCharts
window.ApexCharts = ApexCharts

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

