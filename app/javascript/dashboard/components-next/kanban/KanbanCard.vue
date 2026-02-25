<script setup>
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useMapGetter } from 'dashboard/composables/store';
import { frontendURL, conversationUrl } from 'dashboard/helper/URLHelper.js';
import ConversationCard from 'dashboard/components-next/Conversation/ConversationCard/ConversationCard.vue';

const props = defineProps({
  conversation: { type: Object, required: true },
});

const router = useRouter();
const route = useRoute();

const getInbox = useMapGetter('inboxes/getInbox');
const accountLabels = useMapGetter('labels/getLabels');

const contact = computed(() => ({
  name: props.conversation.meta?.sender?.name || '',
  thumbnail: props.conversation.meta?.sender?.thumbnail || '',
  availabilityStatus: props.conversation.meta?.sender?.availability_status,
}));

const stateInbox = computed(
  () => getInbox.value(props.conversation.inbox_id) || {}
);

const conversationPath = computed(() =>
  frontendURL(
    conversationUrl({
      accountId: route.params.accountId,
      id: props.conversation.id,
    })
  )
);

const openConversation = () => router.push({ path: conversationPath.value });

const openInNewTab = () => {
  window.open(
    window.chatwootConfig.hostURL + conversationPath.value,
    '_blank',
    'noopener noreferrer nofollow'
  );
};
</script>

<template>
  <div
    class="group cursor-grab active:cursor-grabbing rounded-xl bg-[#0d1117] border border-[#1a2035] hover:border-[#2a3050] transition-colors duration-150 overflow-hidden"
  >
    <ConversationCard
      :conversation="conversation"
      :contact="contact"
      :state-inbox="stateInbox"
      :account-labels="accountLabels"
    />

    <!-- Quick actions — visible on hover -->
    <div
      class="flex items-center gap-1 px-3 pb-2 opacity-0 group-hover:opacity-100 transition-opacity duration-150"
    >
      <button
        v-tooltip="$t('KANBAN.ACTIONS.OPEN_CONVERSATION')"
        class="flex items-center justify-center size-6 rounded-md hover:bg-[#1a2035] text-n-slate-9 hover:text-n-slate-12 transition-colors"
        @click.stop="openConversation"
      >
        <span class="i-ph-chat-circle-fill size-3.5" />
      </button>
      <button
        v-tooltip="$t('KANBAN.ACTIONS.OPEN_IN_NEW_TAB')"
        class="flex items-center justify-center size-6 rounded-md hover:bg-[#1a2035] text-n-slate-9 hover:text-n-slate-12 transition-colors"
        @click.stop="openInNewTab"
      >
        <span class="i-ph-arrow-square-out size-3.5" />
      </button>
    </div>
  </div>
</template>
