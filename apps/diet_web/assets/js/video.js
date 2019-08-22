import Player from "./player";
import { Presence } from "phoenix";

let Video = {
  init(socket, element) {
    if (!element) { return; }

    const playerId = element.getAttribute("data-player-id");
    const videoId = element.getAttribute("data-id");
    socket.connect();
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket);
    });
  },

  onReady(videoId, socket) {
    const msgContainer = document.getElementById("msg-container");
    const msgInput = document.getElementById("msg-input");
    const postButton = document.getElementById("msg-submit");
    const userList = document.getElementById("user-list");
    let lastSeenId = 0;
    const videoChannel = socket.channel("videos:" + videoId, () => {
      return {
        last_seen_id: lastSeenId
      };
    });

    const presence = new Presence(videoChannel);
    presence.onSync(() => {
      userList.innerHTML = presence.list((id, {user: user, metas: [first, ...rest]}) => {
        const count = rest.length + 1;
        return `<li class="list-group-item d-flex justify-content-between align-items-center">
          ${user.username} <span class="badge badge-secondary badge-pill">${count}</span>
        </li>`;
      }).join("")
    });

    postButton.addEventListener("click", ev => {
      const payload = {body: msgInput.value, at: Player.getCurrentTime()};
      videoChannel
        .push("new_annotation", payload)
        .receive("error", resp => console.log(resp));

      msgInput.value = "";
    });

    videoChannel.on("new_annotation", (resp) => {
      lastSeenId = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    msgContainer.addEventListener("click", ev => {
      ev.preventDefault()
      const seconds = ev.target.getAttribute("data-seek") || ev.target.parentNode.getAttribute("data-seek");
      if (!seconds) { return; }

      Player.seekTo(seconds);
    });

    videoChannel
      .join()
      .receive("ok", resp => {
        const ids = resp.annotations.map(ann => ann.id);
        if (ids.length > 0) {
          lastSeenId = Math.max(...ids);
        };
        this.renderInitAll(resp.annotations, msgContainer);
      })
      .receive("error", resp => console.log("join failed", resp));
  },

  esc(str) {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    const template = document.createElement("div");
    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `;

    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },

  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.scheduleTimer);
    this.schedulerTimer = setTimeout(() => {
      const ctime = Player.getCurrentTime();
      const remaining = this.renderAtTime(annotations, ctime, msgContainer);
      this.scheduleMessages(msgContainer, remaining);
    }, 1000);
  },

  renderInitAll(annotations, msgContainer) {
    annotations.forEach(ann => this.renderAnnotation(msgContainer, ann));
  },

  renderAtTime(annotations, seconds, msgContainer){
    return annotations.filter(ann => {
      if (ann.at > seconds) {
        return true;
      } else {
        this.renderAnnotation(msgContainer, ann);
        return false;
      }
    });
  },

  formatTime(at){
    const date = new Date(null);
    date.setSeconds(at / 1000);

    return date.toISOString().substr(14, 5);
  }
};

export default Video;
