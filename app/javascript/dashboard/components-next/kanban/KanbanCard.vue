<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import ConversationCard from 'dashboard/components-next/Conversation/ConversationCard/ConversationCard.vue';

const props = defineProps({
  conversation: { type: Object, required: true },
});

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
</script>

<template>
  <div
    class="cursor-grab active:cursor-grabbing rounded-xl bg-[#0d1117] border border-[#1a2035] hover:border-[#2a3050] transition-colors duration-150 overflow-hidden"
  >
    <ConversationCard
      :conversation="conversation"
      :contact="contact"
      :state-inbox="stateInbox"
      :account-labels="accountLabels"
    />
  </div>
</template>
