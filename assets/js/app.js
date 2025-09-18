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
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

import "../css/app.css";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/neko_frame"
import topbar from "../vendor/topbar"
import html2canvas from "html2canvas";

// Image resizing function
function resizeImage(file, maxWidth = 1200, maxHeight = 1800, quality = 0.95) {
  return new Promise((resolve) => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();

    img.onload = () => {
      // Calculate new dimensions maintaining aspect ratio
      let { width, height } = img;

      if (width > height) {
        if (width > maxWidth) {
          height = (height * maxWidth) / width;
          width = maxWidth;
        }
      } else {
        if (height > maxHeight) {
          width = (width * maxHeight) / height;
          height = maxHeight;
        }
      }

      canvas.width = width;
      canvas.height = height;

      // Draw and compress
      ctx.drawImage(img, 0, 0, width, height);

      canvas.toBlob(resolve, file.type, quality);
    };

    img.src = URL.createObjectURL(file);
  });
}

// Simple upload visual feedback - let LiveView handle the rest
function initializeUploadHandlers() {
  const uploadZones = document.querySelectorAll('.upload-zone');

  uploadZones.forEach(uploadZone => {
    const fileInput = uploadZone.querySelector('input[type=file]');

    if (fileInput) {
      // Only handle visual feedback for drag and drop
      ['dragenter', 'dragover'].forEach(eventName => {
        uploadZone.addEventListener(eventName, (e) => {
          e.preventDefault();
          uploadZone.classList.add('dragover');
        });
      });

      ['dragleave', 'drop'].forEach(eventName => {
        uploadZone.addEventListener(eventName, (e) => {
          e.preventDefault();
          uploadZone.classList.remove('dragover');
        });
      });

      // Simple loading state feedback
      fileInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (file && file.type.startsWith('image/')) {
          uploadZone.classList.add('uploading');

          // Remove loading state after upload should be done
          setTimeout(() => {
            uploadZone.classList.remove('uploading');
          }, 2000);
        }
      });
    }
  });
}

// Initialize on DOM ready and LiveView updates
document.addEventListener('DOMContentLoaded', initializeUploadHandlers);
document.addEventListener('phx:update', initializeUploadHandlers);

export async function exportCard(format = "png") {
  const cardElement = document.querySelector(".card-frame");

  // Final resolution for the exported card
  const CARD_WIDTH = 1500;
  const CARD_HEIGHT = 2100;

  // Internal render scale: bigger = sharper, but also bigger file size
  const RENDER_SCALE = 6;

  // 1) Clone card without altering layout or ratio
  const clone = cardElement.cloneNode(true);
  clone.style.position = "absolute";
  clone.style.top = "-9999px"; // offscreen
  document.body.appendChild(clone);

  // 2) Render at high resolution using scale
  const rawCanvas = await html2canvas(clone, {
    backgroundColor: null,
    useCORS: true,
    scrollX: 0,
    scrollY: 0,
    scale: RENDER_SCALE // this is the key for sharpness
  });

  document.body.removeChild(clone);

  // 3) Create final canvas at exact Magic size
  const finalCanvas = document.createElement("canvas");
  finalCanvas.width = CARD_WIDTH;
  finalCanvas.height = CARD_HEIGHT;
  const ctx = finalCanvas.getContext("2d");

  // Downscale high-res render → sharp final image
  ctx.drawImage(rawCanvas, 0, 0, CARD_WIDTH, CARD_HEIGHT);

  // 4) Export as PNG/JPEG
  finalCanvas.toBlob((blob) => {
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `card-${Date.now()}.${format}`;
    a.click();
    URL.revokeObjectURL(url);
  }, `image/${format}`, format === "jpeg" ? 0.95 : 1);
}


window.exportCard = exportCard.bind(this);

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

