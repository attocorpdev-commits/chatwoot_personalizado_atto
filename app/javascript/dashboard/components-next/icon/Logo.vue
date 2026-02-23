<script setup>
import { useAttrs } from 'vue';

const attrs = useAttrs();

const companyLogoUrl = '/atto-logo.png';
</script>

<template>
  <img v-bind="attrs" :src="companyLogoUrl" class="object-contain" />
</template>
