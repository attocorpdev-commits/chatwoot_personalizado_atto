<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Draggable from 'vuedraggable';

const props = defineProps({
  templateName: { type: String, required: true },
  columns: { type: Array, required: true },
  availableLabels: { type: Array, default: () => [] },
});

const emit = defineEmits(['update:columns', 'update:templateName', 'close']);

const { t } = useI18n();

const localColumns = ref(props.columns.map(c => ({ ...c })));
const localName = ref(props.templateName);

const renamingId = ref(null);
const renameValue = ref('');

const showAddMenu = ref(false);
const addTab = ref('status'); // 'status' | 'label' | 'custom'
const labelSearch = ref('');
const customColumnName = ref('');

const STATUS_DEFS = [
  { status: 'open', icon: 'i-lucide-circle-dot', colorClass: 'text-[#3B63A8]' },
  { status: 'pending', icon: 'i-lucide-clock', colorClass: 'text-amber-400' },
  {
    status: 'snoozed',
    icon: 'i-lucide-bell-off',
    colorClass: 'text-violet-400',
  },
  {
    status: 'resolved',
    icon: 'i-lucide-check-circle',
    colorClass: 'text-teal-400',
  },
];

const STATUS_LABELS = computed(() => ({
  open: t('KANBAN.COLUMNS.OPEN'),
  pending: t('KANBAN.COLUMNS.PENDING'),
  snoozed: t('KANBAN.COLUMNS.SNOOZED'),
  resolved: t('KANBAN.COLUMNS.RESOLVED'),
}));

const usedStatuses = computed(() =>
  localColumns.value.filter(c => c.type === 'status').map(c => c.status)
);

const availableStatuses = computed(() =>
  STATUS_DEFS.filter(s => !usedStatuses.value.includes(s.status))
);

const filteredLabels = computed(() => {
  const q = labelSearch.value.toLowerCase();
  return props.availableLabels.filter(l => l.title.toLowerCase().includes(q));
});

const usedLabelTitles = computed(() =>
  localColumns.value.filter(c => c.type === 'label').map(c => c.labelTitle)
);

const slugify = name =>
  name
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '');

const startRename = col => {
  renamingId.value = col.id;
  renameValue.value = col.name;
};

const commitRename = col => {
  if (renameValue.value.trim()) {
    col.name = renameValue.value.trim();
    emit(
      'update:columns',
      localColumns.value.map(c => ({ ...c }))
    );
  }
  renamingId.value = null;
};

const toggleVisible = col => {
  col.visible = !col.visible;
  emit(
    'update:columns',
    localColumns.value.map(c => ({ ...c }))
  );
};

const deleteColumn = col => {
  const idx = localColumns.value.findIndex(c => c.id === col.id);
  if (idx !== -1) {
    localColumns.value.splice(idx, 1);
    emit(
      'update:columns',
      localColumns.value.map(c => ({ ...c }))
    );
  }
};

const onDragEnd = () => {
  emit(
    'update:columns',
    localColumns.value.map(c => ({ ...c }))
  );
};

const addStatusColumn = def => {
  const col = {
    id: `col_${def.status}`,
    type: 'status',
    status: def.status,
    name: STATUS_LABELS.value[def.status],
    icon: def.icon,
    colorClass: def.colorClass,
    visible: true,
  };
  localColumns.value.push(col);
  emit(
    'update:columns',
    localColumns.value.map(c => ({ ...c }))
  );
  showAddMenu.value = false;
};

const addLabelColumn = label => {
  const col = {
    id: `col_label_${label.title}`,
    type: 'label',
    labelTitle: label.title,
    name: label.title,
    icon: 'i-lucide-tag',
    colorClass: 'text-purple-400',
    visible: true,
  };
  localColumns.value.push(col);
  emit(
    'update:columns',
    localColumns.value.map(c => ({ ...c }))
  );
  showAddMenu.value = false;
  labelSearch.value = '';
};

const addCustomColumn = () => {
  const name = customColumnName.value.trim();
  if (!name) return;
  const labelTitle = slugify(name);
  const col = {
    id: `col_custom_${labelTitle}_${Date.now()}`,
    type: 'label',
    labelTitle,
    name,
    icon: 'i-lucide-layout-list',
    colorClass: 'text-slate-400',
    visible: true,
  };
  localColumns.value.push(col);
  emit(
    'update:columns',
    localColumns.value.map(c => ({ ...c }))
  );
  customColumnName.value = '';
  showAddMenu.value = false;
};

const onNameInput = () => {
  emit('update:templateName', localName.value);
};
</script>

<template>
  <div
    class="absolute top-0 right-0 h-full w-72 bg-[#080d18] border-l border-[#1a2035] flex flex-col z-20 shadow-2xl"
  >
    <!-- Header -->
    <div
      class="flex items-center gap-2 px-4 py-3 border-b border-[#1a2035] flex-shrink-0"
    >
      <span class="i-lucide-settings-2 size-4 text-[#3B63A8]" />
      <span class="font-semibold text-sm text-n-slate-12 flex-1">
        {{ $t('KANBAN.SETTINGS.TITLE') }}
      </span>
      <button
        class="size-6 flex items-center justify-center rounded hover:bg-[#1a2035] text-n-slate-9 hover:text-n-slate-12 transition-colors"
        @click="$emit('close')"
      >
        <span class="i-lucide-x size-4" />
      </button>
    </div>

    <!-- Template name -->
    <div class="px-4 py-3 border-b border-[#1a2035] flex-shrink-0">
      <input
        v-model="localName"
        class="w-full bg-[#0d1117] border border-[#1a2035] rounded-lg px-3 py-1.5 text-sm text-n-slate-12 placeholder:text-n-slate-9 focus:outline-none focus:border-[#3B63A8] transition-colors"
        :placeholder="$t('KANBAN.SETTINGS.TEMPLATE_NAME_PLACEHOLDER')"
        @input="onNameInput"
      />
    </div>

    <!-- Column list -->
    <div class="flex-1 overflow-y-auto py-2">
      <Draggable
        v-model="localColumns"
        item-key="id"
        handle=".drag-handle"
        tag="div"
        class="flex flex-col gap-1 px-2"
        @end="onDragEnd"
      >
        <template #item="{ element: col }">
          <div
            class="flex items-center gap-2 px-2 py-2 rounded-lg hover:bg-[#0d1117] group transition-colors"
          >
            <!-- Drag handle -->
            <span
              class="drag-handle i-lucide-grip-vertical size-4 text-n-slate-7 cursor-grab group-hover:text-n-slate-10 flex-shrink-0"
            />

            <!-- Toggle visibility -->
            <button
              class="flex-shrink-0 size-4 flex items-center justify-center transition-colors"
              :class="col.visible ? 'text-[#3B63A8]' : 'text-n-slate-7'"
              @click="toggleVisible(col)"
            >
              <span
                :class="col.visible ? 'i-lucide-eye' : 'i-lucide-eye-off'"
                class="size-4"
              />
            </button>

            <!-- Icon -->
            <span
              class="size-3.5 flex-shrink-0"
              :class="[col.icon, col.colorClass]"
            />

            <!-- Name (rename on click) -->
            <div class="flex-1 min-w-0">
              <input
                v-if="renamingId === col.id"
                v-model="renameValue"
                class="w-full bg-[#1a2035] border border-[#3B63A8] rounded px-1.5 py-0.5 text-xs text-n-slate-12 focus:outline-none"
                @blur="commitRename(col)"
                @keyup.enter="commitRename(col)"
                @keyup.escape="renamingId = null"
              />
              <button
                v-else
                class="text-xs text-n-slate-11 truncate text-left w-full hover:text-n-slate-12 transition-colors"
                @click="startRename(col)"
              >
                {{ col.name }}
              </button>
            </div>

            <!-- Label badge -->
            <span
              v-if="col.type === 'label'"
              class="text-[10px] px-1.5 py-0.5 rounded-full bg-[#1a2035] text-n-slate-9 flex-shrink-0"
            >
              {{ $t('KANBAN.SETTINGS.LABEL_BADGE') }}
            </span>

            <!-- Delete column -->
            <button
              class="opacity-0 group-hover:opacity-100 flex-shrink-0 size-4 flex items-center justify-center text-n-slate-7 hover:text-red-400 transition-all"
              @click="deleteColumn(col)"
            >
              <span class="i-lucide-trash-2 size-3.5" />
            </button>
          </div>
        </template>
      </Draggable>
    </div>

    <!-- Add column -->
    <div class="border-t border-[#1a2035] flex-shrink-0 p-3 relative">
      <button
        class="w-full flex items-center justify-center gap-2 py-2 rounded-lg border border-dashed border-[#1a2035] text-xs text-n-slate-9 hover:border-[#3B63A8] hover:text-n-slate-12 transition-colors"
        @click="showAddMenu = !showAddMenu"
      >
        <span class="i-lucide-plus size-3.5" />
        {{ $t('KANBAN.SETTINGS.ADD_COLUMN') }}
      </button>

      <!-- Add menu dropdown -->
      <div
        v-if="showAddMenu"
        class="absolute bottom-full left-3 right-3 mb-1 bg-[#0d1117] border border-[#1a2035] rounded-xl shadow-2xl overflow-hidden"
      >
        <!-- Tabs -->
        <div class="flex border-b border-[#1a2035]">
          <button
            class="flex-1 py-2 text-xs font-medium transition-colors"
            :class="
              addTab === 'status'
                ? 'text-n-slate-12 bg-[#1a2035]'
                : 'text-n-slate-9 hover:text-n-slate-11'
            "
            @click="addTab = 'status'"
          >
            {{ $t('KANBAN.SETTINGS.ADD_STATUS_COLUMN') }}
          </button>
          <button
            class="flex-1 py-2 text-xs font-medium transition-colors"
            :class="
              addTab === 'label'
                ? 'text-n-slate-12 bg-[#1a2035]'
                : 'text-n-slate-9 hover:text-n-slate-11'
            "
            @click="addTab = 'label'"
          >
            {{ $t('KANBAN.SETTINGS.ADD_LABEL_COLUMN') }}
          </button>
          <button
            class="flex-1 py-2 text-xs font-medium transition-colors"
            :class="
              addTab === 'custom'
                ? 'text-n-slate-12 bg-[#1a2035]'
                : 'text-n-slate-9 hover:text-n-slate-11'
            "
            @click="addTab = 'custom'"
          >
            {{ $t('KANBAN.SETTINGS.ADD_CUSTOM_COLUMN') }}
          </button>
        </div>

        <!-- Status tab -->
        <div v-if="addTab === 'status'" class="p-2">
          <div
            v-if="availableStatuses.length === 0"
            class="py-3 text-center text-xs text-n-slate-9"
          >
            {{ $t('KANBAN.SETTINGS.ALL_STATUS_ADDED') }}
          </div>
          <button
            v-for="def in availableStatuses"
            :key="def.status"
            class="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-xs text-n-slate-11 hover:bg-[#1a2035] hover:text-n-slate-12 transition-colors"
            @click="addStatusColumn(def)"
          >
            <span class="size-3.5" :class="[def.icon, def.colorClass]" />
            {{ STATUS_LABELS[def.status] ?? def.status }}
          </button>
        </div>

        <!-- Label tab -->
        <div v-if="addTab === 'label'" class="p-2">
          <input
            v-model="labelSearch"
            class="w-full bg-[#1a2035] border border-[#1a2035] rounded-lg px-2 py-1 text-xs text-n-slate-12 placeholder:text-n-slate-9 focus:outline-none focus:border-[#3B63A8] mb-2 transition-colors"
            :placeholder="$t('KANBAN.SETTINGS.SEARCH_LABELS')"
          />
          <div
            v-if="filteredLabels.length === 0"
            class="py-3 text-center text-xs text-n-slate-9"
          >
            {{ $t('KANBAN.SETTINGS.NO_LABELS') }}
          </div>
          <div class="max-h-40 overflow-y-auto flex flex-col gap-0.5">
            <button
              v-for="label in filteredLabels"
              :key="label.title"
              class="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-xs hover:bg-[#1a2035] transition-colors"
              :class="
                usedLabelTitles.includes(label.title)
                  ? 'text-n-slate-7 cursor-not-allowed'
                  : 'text-n-slate-11 hover:text-n-slate-12'
              "
              :disabled="usedLabelTitles.includes(label.title)"
              @click="addLabelColumn(label)"
            >
              <span
                class="size-2.5 rounded-full flex-shrink-0"
                :style="{ background: label.color }"
              />
              {{ label.title }}
              <span
                v-if="usedLabelTitles.includes(label.title)"
                class="ml-auto text-[10px] text-n-slate-7"
              >
                {{ $t('KANBAN.SETTINGS.ALREADY_ADDED') }}
              </span>
            </button>
          </div>
        </div>

        <!-- Custom tab -->
        <div v-if="addTab === 'custom'" class="p-3">
          <p class="text-xs text-n-slate-9 mb-2">
            {{ $t('KANBAN.SETTINGS.ADD_CUSTOM_COLUMN') }}
          </p>
          <div class="flex gap-2">
            <input
              v-model="customColumnName"
              class="flex-1 bg-[#1a2035] border border-[#1a2035] rounded-lg px-2 py-1.5 text-xs text-n-slate-12 placeholder:text-n-slate-9 focus:outline-none focus:border-[#3B63A8] transition-colors"
              :placeholder="$t('KANBAN.SETTINGS.CUSTOM_COLUMN_PLACEHOLDER')"
              @keyup.enter="addCustomColumn"
            />
            <button
              class="flex items-center justify-center size-7 rounded-lg bg-[#3B63A8] hover:bg-[#2a4f8f] text-white transition-colors disabled:opacity-40"
              :disabled="!customColumnName.trim()"
              @click="addCustomColumn"
            >
              <span class="i-lucide-plus size-3.5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
