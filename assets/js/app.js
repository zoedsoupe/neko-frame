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
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { hooks as colocatedHooks } from "phoenix-colocated/neko_frame";
import topbar from "../vendor/topbar";
import { snapdom } from "@zumer/snapdom";

// Simple upload visual feedback - let LiveView handle the rest
function initializeUploadHandlers() {
  const uploadZones = document.querySelectorAll(".upload-zone");

  uploadZones.forEach((uploadZone) => {
    const fileInput = uploadZone.querySelector("input[type=file]");

    if (fileInput) {
      // Only handle visual feedback for drag and drop
      ["dragenter", "dragover"].forEach((eventName) => {
        uploadZone.addEventListener(eventName, (e) => {
          e.preventDefault();
          uploadZone.classList.add("dragover");
        });
      });

      ["dragleave", "drop"].forEach((eventName) => {
        uploadZone.addEventListener(eventName, (e) => {
          e.preventDefault();
          uploadZone.classList.remove("dragover");
        });
      });

      // Simple loading state feedback
      fileInput.addEventListener("change", (e) => {
        const file = e.target.files[0];
        if (file && file.type.startsWith("image/")) {
          uploadZone.classList.add("uploading");

          // Remove loading state after upload should be done
          setTimeout(() => {
            uploadZone.classList.remove("uploading");
          }, 2000);
        }
      });
    }
  });
}

// Initialize on DOM ready and LiveView updates
document.addEventListener("DOMContentLoaded", initializeUploadHandlers);
document.addEventListener("phx:update", initializeUploadHandlers);

function normalizecardname(cardname) {
  return cardname
    .toLower()
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s/, "-")
    .trim();
}

export async function exportCard(cardname) {
  const cardElement = document.querySelector(".card-frame");
  const img = await snapdom(cardElement, { cache: "soft" });
  const name = normalizecardname(cardname || "generic");
  await img.download({ format: "png", filename: `neko-${name}.png` });
}

window.exportCard = exportCard.bind(this);

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener(
    "phx:live_reload:attached",
    ({ detail: reloader }) => {
      // Enable server log streaming to client.
      // Disable with reloader.disableServerLogs()
      reloader.enableServerLogs();

      // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
      //
      //   * click with "c" key pressed to open at caller location
      //   * click with "d" key pressed to open at function component definition location
      let keyDown;
      window.addEventListener("keydown", (e) => (keyDown = e.key));
      window.addEventListener("keyup", (e) => (keyDown = null));
      window.addEventListener(
        "click",
        (e) => {
          if (keyDown === "c") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtCaller(e.target);
          } else if (keyDown === "d") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtDef(e.target);
          }
        },
        true,
      );

      window.liveReloader = reloader;
    },
  );
}
