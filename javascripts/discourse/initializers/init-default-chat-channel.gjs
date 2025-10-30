import { withPluginApi } from "discourse/lib/plugin-api";
import { later } from "@ember/runloop";

function openDefaultChatChannel(chat, api) {
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
}

function initializeDefaultChatChannel(api) {
  const currentUser = api.container.lookup('current-user:main');
  if (!currentUser) {
    return; // not logged in
  }

  const chat = api.container.lookup("service:chat");
  if (!chat) {
    return; // chat not enabled
  }

  chat.loadChannels().then(() => {
    if (chat.activeChannel) {
      return; // chat already open
    }
    // at this point .has-full-page-chat is not present yet
    const site = api.container.lookup("service:site");
    if (site.mobileView) {
      return; // in mobile view, chat would take full page
    }
    openDefaultChatChannel(chat, api);
  });
}

export default {
  name: "init-default-chat-channel",

  initialize() {
    withPluginApi("0.8.7", initializeDefaultChatChannel);
  },
};
