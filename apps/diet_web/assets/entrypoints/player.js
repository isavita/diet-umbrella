import Player from "../js/player";

const video = document.getElementById("video");
Player.init(video.id, video.getAttribute("data-player-id"), () => {
  console.log("player ready!");
});
