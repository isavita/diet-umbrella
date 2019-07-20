import Player from "../js/player";
import css from "../css/player.css";

const video = document.getElementById("video");
Player.init(video.id, video.getAttribute("data-player-id"), () => {
  console.log("player ready!");
});
