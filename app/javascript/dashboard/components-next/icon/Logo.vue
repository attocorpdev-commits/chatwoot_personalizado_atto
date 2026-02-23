<script setup>
import { useAttrs } from 'vue';
import attoLogo from 'dashboard/assets/images/atto-logo.png';

const attrs = useAttrs();

const companyLogoUrl = attoLogo;
</script>

<template>
  <img v-bind="attrs" :src="companyLogoUrl" class="object-contain" />
</template>
