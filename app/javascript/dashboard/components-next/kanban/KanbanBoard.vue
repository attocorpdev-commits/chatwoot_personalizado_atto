<script setup>
import { computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useMapGetter, useStore } from 'dashboard/composables/store';
import KanbanColumn from './KanbanColumn.vue';

const store = useStore();
const { t } = useI18n();

// conversations module is NOT namespaced in this project
const allConversations = useMapGetter('getAllConversations');

onMounted(() => {
  store.dispatch('fetchAllConversations');
});

const COLUMNS = computed(() => [
  {
    status: 'open',
    label: t('KANBAN.COLUMNS.OPEN'),
    icon: 'i-lucide-circle-dot',
    colorClass: 'text-[#3B63A8]',
  },
  {
    status: 'pending',
    label: t('KANBAN.COLUMNS.PENDING'),
    icon: 'i-lucide-clock',
    colorClass: 'text-amber-400',
  },
  {
    status: 'snoozed',
    label: t('KANBAN.COLUMNS.SNOOZED'),
    icon: 'i-lucide-bell-off',
    colorClass: 'text-violet-400',
  },
  {
    status: 'resolved',
    label: t('KANBAN.COLUMNS.RESOLVED'),
    icon: 'i-lucide-check-circle',
    colorClass: 'text-teal-400',
  },
]);

const conversationsByStatus = computed(() => {
  const convs = allConversations.value ?? [];
  return {
    open: convs.filter(c => c.status === 'open'),
    pending: convs.filter(c => c.status === 'pending'),
    snoozed: convs.filter(c => c.status === 'snoozed'),
    resolved: convs.filter(c => c.status === 'resolved'),
  };
});

const onCardMoved = ({ conversationId, newStatus }) => {
  store.dispatch('toggleStatus', {
    conversationId,
    status: newStatus,
  });
};
</script>

<template>
  <div class="flex flex-col h-full w-full bg-n-background overflow-hidden">
    <!-- Cabeçalho -->
    <div
      class="flex items-center gap-3 px-6 py-4 border-b border-[#1a2035] flex-shrink-0"
    >
      <span class="i-lucide-layout-dashboard size-5 text-[#3B63A8]" />
      <h1 class="text-base font-semibold text-n-slate-12">
        {{ $t('KANBAN.TITLE') }}
      </h1>
    </div>

    <!-- Colunas -->
    <div class="flex gap-4 p-4 overflow-x-auto flex-1 items-start h-full">
      <KanbanColumn
        v-for="col in COLUMNS"
        :key="col.status"
        :status="col.status"
        :label="col.label"
        :icon="col.icon"
        :color-class="col.colorClass"
        :conversations="conversationsByStatus[col.status]"
        @card-moved="onCardMoved"
      />
    </div>
  </div>
</template>
