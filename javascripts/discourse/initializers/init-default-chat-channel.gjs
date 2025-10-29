import { withPluginApi } from "discourse/lib/plugin-api";
import { later } from "@ember/runloop";

function initializeDefaultChatChannel(api) {
  later(() => {
    var currentUser = api.container.lookup('current-user:main');
    if (!currentUser) {
      return; // not logged in
    }
    var chat = api.container.lookup("service:chat");
    if (!chat || chat.activeChannel) { // if chat disabled, or already open
      return;
    }

    const publicChannels = chat?.chatChannelsManager?.publicMessageChannels;
    if (!publicChannels) {
      console.log("DefaultChatChannel: No public channels configured.");
      return;
    }
    const targetChannelName = settings.default_chat_channel_name;
    if (!targetChannelName) {
      console.log("DefaultChatChannel: No default chat channel name configured. Available channels:");
      publicChannels.forEach(channel => {
        console.log("- " + channel.unicodeTitle);
      });
      return;
    }

    const targetChannel = publicChannels.find(
      channel => channel.unicodeTitle === targetChannelName
    );
    if (targetChannel) {
      var router = api.container.lookup("service:router");
      router.transitionTo('chat.channel', ...targetChannel.routeModels);
    } else {
      console.log("DefaultChatChannel: Target channel '" + targetChannelName + "' not found. Available channels:");
      publicChannels.forEach(channel => {
        console.log("- " + channel.unicodeTitle);
      });
    }
  }, 1000);
}

export default {
  name: "init-default-chat-channel",

  initialize() {
    withPluginApi("0.8.7", initializeDefaultChatChannel);
  },
};
