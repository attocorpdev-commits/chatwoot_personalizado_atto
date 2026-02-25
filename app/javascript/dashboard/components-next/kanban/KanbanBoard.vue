<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useMapGetter, useStore } from 'dashboard/composables/store';
import { useAccount } from 'dashboard/composables/useAccount';
import { LocalStorage } from 'shared/helpers/localStorage';
import getUuid from 'widget/helpers/uuid';
import { emitter } from 'shared/helpers/mitt';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import KanbanColumn from './KanbanColumn.vue';
import KanbanSettingsPanel from './KanbanSettingsPanel.vue';

const store = useStore();
const { t } = useI18n();
const { accountId } = useAccount();

const allConversations = useMapGetter('getAllConversations');
const getLabels = useMapGetter('labels/getLabels');

onMounted(() => {
  store.dispatch('fetchAllConversations');
});

// ─── Column definitions ───────────────────────────────────────────────────────

const COLUMN_DEFS = {
  open: { icon: 'i-lucide-circle-dot', colorClass: 'text-[#3B63A8]' },
  pending: { icon: 'i-lucide-clock', colorClass: 'text-amber-400' },
  snoozed: { icon: 'i-lucide-bell-off', colorClass: 'text-violet-400' },
  resolved: { icon: 'i-lucide-check-circle', colorClass: 'text-teal-400' },
};

const makeDefaultTemplate = () => ({
  id: 'default',
  name: t('KANBAN.TITLE'),
  columns: [
    {
      id: 'col_open',
      type: 'status',
      status: 'open',
      name: t('KANBAN.COLUMNS.OPEN'),
      ...COLUMN_DEFS.open,
      visible: true,
    },
    {
      id: 'col_pending',
      type: 'status',
      status: 'pending',
      name: t('KANBAN.COLUMNS.PENDING'),
      ...COLUMN_DEFS.pending,
      visible: true,
    },
    {
      id: 'col_snoozed',
      type: 'status',
      status: 'snoozed',
      name: t('KANBAN.COLUMNS.SNOOZED'),
      ...COLUMN_DEFS.snoozed,
      visible: true,
    },
    {
      id: 'col_resolved',
      type: 'status',
      status: 'resolved',
      name: t('KANBAN.COLUMNS.RESOLVED'),
      ...COLUMN_DEFS.resolved,
      visible: true,
    },
  ],
});

const makeInfoprodutoTemplate = () => ({
  id: 'infoproduto',
  name: t('KANBAN.TEMPLATES.INFOPRODUTO'),
  columns: [
    {
      id: 'col_ip_lead',
      type: 'label',
      labelTitle: 'novo-lead',
      name: t('KANBAN.TEMPLATES.INFOPRODUTO_COLS.LEAD'),
      icon: 'i-lucide-user-plus',
      colorClass: 'text-blue-400',
      visible: true,
    },
    {
      id: 'col_ip_qualif',
      type: 'label',
      labelTitle: 'qualificado',
      name: t('KANBAN.TEMPLATES.INFOPRODUTO_COLS.QUALIFIED'),
      icon: 'i-lucide-star',
      colorClass: 'text-yellow-400',
      visible: true,
    },
    {
      id: 'col_ip_proposta',
      type: 'label',
      labelTitle: 'proposta',
      name: t('KANBAN.TEMPLATES.INFOPRODUTO_COLS.PROPOSAL'),
      icon: 'i-lucide-file-text',
      colorClass: 'text-orange-400',
      visible: true,
    },
    {
      id: 'col_ip_negoc',
      type: 'label',
      labelTitle: 'negociacao',
      name: t('KANBAN.TEMPLATES.INFOPRODUTO_COLS.NEGOTIATION'),
      icon: 'i-lucide-handshake',
      colorClass: 'text-purple-400',
      visible: true,
    },
    {
      id: 'col_ip_upsell',
      type: 'label',
      labelTitle: 'upsell',
      name: t('KANBAN.TEMPLATES.INFOPRODUTO_COLS.UPSELL'),
      icon: 'i-lucide-trending-up',
      colorClass: 'text-pink-400',
      visible: true,
    },
    {
      id: 'col_ip_fechado',
      type: 'status',
      status: 'resolved',
      name: t('KANBAN.TEMPLATES.INFOPRODUTO_COLS.CLOSED'),
      icon: 'i-lucide-check-circle',
      colorClass: 'text-teal-400',
      visible: true,
    },
  ],
});

const makeEducacaoTemplate = () => ({
  id: 'educacao',
  name: t('KANBAN.TEMPLATES.EDUCATION'),
  columns: [
    {
      id: 'col_ed_interesse',
      type: 'label',
      labelTitle: 'interesse',
      name: t('KANBAN.TEMPLATES.EDUCATION_COLS.INTEREST'),
      icon: 'i-lucide-lightbulb',
      colorClass: 'text-yellow-400',
      visible: true,
    },
    {
      id: 'col_ed_inscricao',
      type: 'label',
      labelTitle: 'inscricao',
      name: t('KANBAN.TEMPLATES.EDUCATION_COLS.ENROLLMENT'),
      icon: 'i-lucide-clipboard-list',
      colorClass: 'text-blue-400',
      visible: true,
    },
    {
      id: 'col_ed_curso',
      type: 'label',
      labelTitle: 'em-curso',
      name: t('KANBAN.TEMPLATES.EDUCATION_COLS.IN_PROGRESS'),
      icon: 'i-lucide-book-open',
      colorClass: 'text-green-400',
      visible: true,
    },
    {
      id: 'col_ed_retencao',
      type: 'label',
      labelTitle: 'retencao',
      name: t('KANBAN.TEMPLATES.EDUCATION_COLS.RETENTION'),
      icon: 'i-lucide-repeat',
      colorClass: 'text-purple-400',
      visible: true,
    },
    {
      id: 'col_ed_concluido',
      type: 'status',
      status: 'resolved',
      name: t('KANBAN.TEMPLATES.EDUCATION_COLS.COMPLETED'),
      icon: 'i-lucide-graduation-cap',
      colorClass: 'text-teal-400',
      visible: true,
    },
  ],
});

const makeClinicasTemplate = () => ({
  id: 'clinicas',
  name: t('KANBAN.TEMPLATES.HEALTH_CLINIC'),
  columns: [
    {
      id: 'col_cl_agenda',
      type: 'label',
      labelTitle: 'agendamento',
      name: t('KANBAN.TEMPLATES.HEALTH_CLINIC_COLS.SCHEDULING'),
      icon: 'i-lucide-calendar-plus',
      colorClass: 'text-blue-400',
      visible: true,
    },
    {
      id: 'col_cl_confirm',
      type: 'label',
      labelTitle: 'confirmado',
      name: t('KANBAN.TEMPLATES.HEALTH_CLINIC_COLS.CONFIRMED'),
      icon: 'i-lucide-calendar-check',
      colorClass: 'text-green-400',
      visible: true,
    },
    {
      id: 'col_cl_atend',
      type: 'label',
      labelTitle: 'em-atendimento',
      name: t('KANBAN.TEMPLATES.HEALTH_CLINIC_COLS.IN_CARE'),
      icon: 'i-lucide-stethoscope',
      colorClass: 'text-orange-400',
      visible: true,
    },
    {
      id: 'col_cl_pos',
      type: 'label',
      labelTitle: 'pos-consulta',
      name: t('KANBAN.TEMPLATES.HEALTH_CLINIC_COLS.POST_VISIT'),
      icon: 'i-lucide-clipboard-check',
      colorClass: 'text-purple-400',
      visible: true,
    },
    {
      id: 'col_cl_retorno',
      type: 'label',
      labelTitle: 'retorno',
      name: t('KANBAN.TEMPLATES.HEALTH_CLINIC_COLS.RETURN'),
      icon: 'i-lucide-rotate-ccw',
      colorClass: 'text-teal-400',
      visible: true,
    },
  ],
});

// ─── Board state (persisted in localStorage) ─────────────────────────────────

const boardKey = computed(() => `kanban_boards_${accountId.value}`);

const loadBoardData = () => {
  const saved = LocalStorage.get(boardKey.value);
  if (saved && saved.templates && saved.activeTemplateId) return saved;
  const def = makeDefaultTemplate();
  return {
    templates: [
      def,
      makeInfoprodutoTemplate(),
      makeEducacaoTemplate(),
      makeClinicasTemplate(),
    ],
    activeTemplateId: def.id,
  };
};

const boardData = ref(loadBoardData());

watch(boardData, val => LocalStorage.set(boardKey.value, val), { deep: true });

const activeTemplate = computed(() =>
  boardData.value.templates.find(
    tpl => tpl.id === boardData.value.activeTemplateId
  )
);

const activeColumns = computed(() => activeTemplate.value?.columns ?? []);
const visibleColumns = computed(() =>
  activeColumns.value.filter(c => c.visible)
);

// ─── Template actions ─────────────────────────────────────────────────────────

const showTemplateMenu = ref(false);

const switchTemplate = id => {
  boardData.value.activeTemplateId = id;
  showTemplateMenu.value = false;
};

const addTemplate = () => {
  const current = activeTemplate.value;
  const newTpl = {
    id: getUuid(),
    name: `${current.name} (copy)`,
    columns: current.columns.map(c => ({ ...c })),
  };
  boardData.value.templates.push(newTpl);
  boardData.value.activeTemplateId = newTpl.id;
  showTemplateMenu.value = false;
};

const deleteTemplate = () => {
  if (boardData.value.templates.length <= 1) return;
  const idx = boardData.value.templates.findIndex(
    tpl => tpl.id === boardData.value.activeTemplateId
  );
  boardData.value.templates.splice(idx, 1);
  boardData.value.activeTemplateId = boardData.value.templates[0].id;
  showTemplateMenu.value = false;
};

// ─── Settings panel ───────────────────────────────────────────────────────────

const showSettings = ref(false);

const onColumnsUpdate = columns => {
  if (activeTemplate.value) {
    activeTemplate.value.columns = columns;
  }
};

const onTemplateNameUpdate = name => {
  if (activeTemplate.value) {
    activeTemplate.value.name = name;
  }
};

// ─── Date filter ─────────────────────────────────────────────────────────────

const dateFilter = ref('all');

const DATE_FILTERS = [
  { key: 'all', label: t('KANBAN.FILTERS.ALL') },
  { key: 'today', label: t('KANBAN.FILTERS.TODAY') },
  { key: '7d', label: t('KANBAN.FILTERS.LAST_7_DAYS') },
  { key: '30d', label: t('KANBAN.FILTERS.LAST_30_DAYS') },
];

const filteredConversations = computed(() => {
  const convs = allConversations.value ?? [];
  if (dateFilter.value === 'all') return convs;
  const ms = { today: 86400000, '7d': 604800000, '30d': 2592000000 };
  const cutoff = Date.now() - ms[dateFilter.value];
  return convs.filter(c => c.created_at >= cutoff);
});

// ─── Conversations by column ──────────────────────────────────────────────────

const conversationsByColumn = computed(() => {
  const convs = filteredConversations.value;
  return Object.fromEntries(
    activeColumns.value.map(col => [
      col.id,
      col.type === 'status'
        ? convs.filter(c => c.status === col.status)
        : convs.filter(c => (c.labels ?? []).includes(col.labelTitle)),
    ])
  );
});

// ─── Card moved ───────────────────────────────────────────────────────────────

const onCardMoved = ({ conversationId, newStatus }) => {
  store.dispatch('toggleStatus', { conversationId, status: newStatus });
};

// ─── Available labels for settings panel ─────────────────────────────────────

const availableLabels = computed(() => getLabels.value ?? []);

// ─── New conversation ─────────────────────────────────────────────────────────

const onAddConversation = () => {
  emitter.emit(BUS_EVENTS.NEW_CONVERSATION_MODAL, true);
};
</script>

<template>
  <div
    class="flex flex-col h-full w-full bg-n-background overflow-hidden relative"
  >
    <!-- Header -->
    <div
      class="flex items-center gap-3 px-6 py-3 border-b border-[#1a2035] flex-shrink-0"
    >
      <!-- Title -->
      <span class="i-lucide-layout-dashboard size-5 text-[#3B63A8]" />
      <h1 class="text-base font-semibold text-n-slate-12">
        {{ $t('KANBAN.TITLE') }}
      </h1>

      <!-- Template selector -->
      <div class="relative ml-2">
        <button
          class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#0d1117] border border-[#1a2035] text-xs text-n-slate-11 hover:border-[#2a3050] hover:text-n-slate-12 transition-colors"
          @click="showTemplateMenu = !showTemplateMenu"
        >
          <span class="i-lucide-layers size-3.5" />
          <span class="max-w-[120px] truncate">{{ activeTemplate?.name }}</span>
          <span class="i-lucide-chevron-down size-3" />
        </button>

        <!-- Template dropdown -->
        <div
          v-if="showTemplateMenu"
          class="absolute top-full left-0 mt-1 w-52 bg-[#080d18] border border-[#1a2035] rounded-xl shadow-2xl z-30 overflow-hidden"
        >
          <div class="py-1">
            <button
              v-for="tpl in boardData.templates"
              :key="tpl.id"
              class="w-full flex items-center gap-2 px-3 py-2 text-xs transition-colors"
              :class="
                tpl.id === boardData.activeTemplateId
                  ? 'text-n-slate-12 bg-[#1a2035]'
                  : 'text-n-slate-10 hover:bg-[#0d1117] hover:text-n-slate-12'
              "
              @click="switchTemplate(tpl.id)"
            >
              <span
                class="size-3 rounded-full flex-shrink-0"
                :class="
                  tpl.id === boardData.activeTemplateId
                    ? 'bg-[#3B63A8]'
                    : 'bg-[#1a2035]'
                "
              />
              <span class="flex-1 truncate text-left">{{ tpl.name }}</span>
            </button>
          </div>
          <div class="border-t border-[#1a2035] py-1">
            <button
              class="w-full flex items-center gap-2 px-3 py-2 text-xs text-n-slate-9 hover:text-n-slate-12 hover:bg-[#0d1117] transition-colors"
              @click="addTemplate"
            >
              <span class="i-lucide-copy-plus size-3.5" />
              {{ $t('KANBAN.TEMPLATES.NEW') }}
            </button>
            <button
              v-if="boardData.templates.length > 1"
              class="w-full flex items-center gap-2 px-3 py-2 text-xs text-red-400 hover:bg-[#0d1117] transition-colors"
              @click="deleteTemplate"
            >
              <span class="i-lucide-trash-2 size-3.5" />
              {{ $t('KANBAN.TEMPLATES.DELETE') }}
            </button>
          </div>
        </div>
      </div>

      <!-- Edit board button -->
      <button
        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border text-xs transition-colors"
        :class="
          showSettings
            ? 'bg-[#1a2035] border-[#3B63A8] text-n-slate-12'
            : 'bg-transparent border-[#1a2035] text-n-slate-9 hover:border-[#2a3050] hover:text-n-slate-11'
        "
        @click="showSettings = !showSettings"
      >
        <span class="i-lucide-settings-2 size-3.5" />
        <span class="hidden sm:inline">{{ $t('KANBAN.SETTINGS.TITLE') }}</span>
      </button>

      <!-- Spacer -->
      <div class="flex-1" />

      <!-- Date filter pills -->
      <div
        class="flex items-center gap-1 bg-[#0d1117] border border-[#1a2035] rounded-lg p-0.5"
      >
        <button
          v-for="f in DATE_FILTERS"
          :key="f.key"
          class="px-3 py-1 rounded-md text-xs font-medium transition-colors"
          :class="
            dateFilter === f.key
              ? 'bg-[#1a2035] text-n-slate-12'
              : 'text-n-slate-9 hover:text-n-slate-11'
          "
          @click="dateFilter = f.key"
        >
          {{ f.label }}
        </button>
      </div>
    </div>

    <!-- Board area -->
    <div class="flex gap-4 p-4 overflow-x-auto flex-1 items-start h-full">
      <KanbanColumn
        v-for="col in visibleColumns"
        :key="col.id"
        :status="col.status || ''"
        :label="col.name"
        :icon="col.icon"
        :color-class="col.colorClass"
        :conversations="conversationsByColumn[col.id] ?? []"
        :readonly="col.type === 'label'"
        @card-moved="onCardMoved"
        @add-conversation="onAddConversation"
      />
    </div>

    <!-- Settings panel (overlay) -->
    <KanbanSettingsPanel
      v-if="showSettings"
      :template-name="activeTemplate?.name ?? ''"
      :columns="activeColumns"
      :available-labels="availableLabels"
      @update:columns="onColumnsUpdate"
      @update:template-name="onTemplateNameUpdate"
      @close="showSettings = false"
    />

    <!-- Backdrop to close dropdowns -->
    <div
      v-if="showTemplateMenu"
      class="fixed inset-0 z-20"
      @click="showTemplateMenu = false"
    />
  </div>
</template>
