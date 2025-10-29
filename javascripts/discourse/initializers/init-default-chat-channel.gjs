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

    const targetChannelName = settings.default_chat_channel_name;
    if (!targetChannelName) {
      console.log("No default chat channel name configured");
      return;
    }

    const publicChannels = chat?.chatChannelsManager?.publicMessageChannels;
    const targetChannel = publicChannels.find(
      channel => channel.unicodeTitle === targetChannelName
    );
    if (targetChannel) {
      var router = api.container.lookup("service:router");
      router.transitionTo('chat.channel', ...targetChannel.routeModels);
    } else {
      console.log("Target channel not found: " + targetChannelName);
      console.log("Available channels:");
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
