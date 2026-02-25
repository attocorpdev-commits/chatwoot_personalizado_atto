<script setup>
import { ref, watch } from 'vue';
import Draggable from 'vuedraggable';
import KanbanCard from './KanbanCard.vue';

const props = defineProps({
  status: { type: String, default: '' },
  label: { type: String, required: true },
  icon: { type: String, required: true },
  colorClass: { type: String, required: true },
  conversations: { type: Array, default: () => [] },
  readonly: { type: Boolean, default: false },
});

const emit = defineEmits(['cardMoved', 'addConversation']);

const localConversations = ref([...props.conversations]);

watch(
  () => props.conversations,
  val => {
    localConversations.value = [...val];
  }
);

const onColumnChange = event => {
  if (event.added) {
    emit('cardMoved', {
      conversationId: event.added.element.id,
      newStatus: props.status,
    });
  }
};
</script>

<template>
  <div
    class="flex flex-col flex-shrink-0 w-[300px] h-full rounded-xl bg-[#080d18] border border-[#1a2035] overflow-hidden"
  >
    <!-- Header da coluna -->
    <div
      class="flex items-center gap-2 px-4 py-3 border-b border-[#1a2035] flex-shrink-0"
    >
      <span class="size-4" :class="[icon, colorClass]" />
      <span class="font-medium text-sm text-n-slate-12">{{ label }}</span>
      <span
        class="ml-auto text-xs font-medium px-2 py-0.5 rounded-full bg-[#161b2e] text-n-slate-10"
      >
        {{ localConversations.length }}
      </span>
    </div>

    <!-- Lista de cards com drag-and-drop -->
    <Draggable
      v-model="localConversations"
      :group="{ name: 'kanban', pull: true, put: !readonly }"
      item-key="id"
      tag="div"
      ghost-class="kanban-ghost"
      drag-class="kanban-drag"
      class="flex flex-col gap-2 p-2 overflow-y-auto flex-1 min-h-[80px]"
      @change="onColumnChange"
    >
      <template #item="{ element }">
        <div>
          <KanbanCard :conversation="element" />
        </div>
      </template>
    </Draggable>

    <!-- Empty state -->
    <div
      v-if="localConversations.length === 0"
      class="flex flex-col items-center justify-center gap-2 py-10 text-center pointer-events-none"
    >
      <span class="size-8 opacity-20" :class="[icon, colorClass]" />
      <p class="text-xs text-n-slate-9">
        {{ $t('KANBAN.EMPTY_STATE') }}
      </p>
    </div>

    <!-- Rodapé: botão nova conversa -->
    <button
      class="flex items-center gap-1.5 w-full px-4 py-2.5 text-xs text-n-slate-9 hover:text-n-slate-11 hover:bg-[#0d1117] border-t border-[#1a2035] transition-colors flex-shrink-0"
      @click="emit('addConversation')"
    >
      <span class="i-lucide-plus size-3.5" />
      {{ $t('KANBAN.ADD_CONVERSATION') }}
    </button>
  </div>
</template>

<style scoped>
.kanban-ghost {
  @apply opacity-40 bg-[#1a2035] rounded-xl;
}
.kanban-drag {
  @apply opacity-90 rotate-1 shadow-xl;
}
</style>
