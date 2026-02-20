<script setup>
import { useAttrs } from 'vue';

const attrs = useAttrs();

const companyLogoUrl =
  'https://krpophlzyxkzxeocgfow.supabase.co/storage/v1/object/public/Logo/Gemini_Generated_Image_v0mdlav0mdlav0md-removebg-preview.png';
</script>

<template>
  <img v-bind="attrs" :src="companyLogoUrl" class="object-contain" />
</template>
