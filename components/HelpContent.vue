<template>
  <div class="pt-2">
    <template v-if="article && Object.keys(variables).length">
      <div
        class="grid grid-cols-[auto_1fr] items-center justify-items-start justify-start p-4 gap-x-4 gap-y-2"
      >
        <VariableInput
          v-for="key of Object.keys(variables)"
          :key="key"
          v-model="actualVariables[key]"
          :config="variables[key]"
          class="contents"
        />
      </div>
    </template>
    <ContentRenderer
      v-if="article"
      :value="computedArticle"
      tag="article"
      class="markdown-body p-4 pt-0"
    />
  </div>
</template>

<script setup lang="ts">
import type { ParsedContent } from '@nuxt/content/dist/runtime/types'

const props = defineProps<{
  article: ParsedContent | null
}>()

const variables = computed(() => props.article?.variables ?? {})
const actualVariables = reactive<Record<string, string>>(
  Object.fromEntries(Object.entries(variables.value).map(([k, v]) => [k, v.default]))
)

const computedArticle = computed(() => {
  if (!props.article) return null

  function deepInterpolate<T>(obj: T): T {
    if (typeof obj === 'string') {
      return obj.replace(/\{\{(.+?)\}\}/g, (_, key) => {
        return actualVariables[key] || ''
      }) as T
    } else if (Array.isArray(obj)) {
      return obj.map(deepInterpolate) as T
    } else if (typeof obj === 'object') {
      if (!obj) return obj
      return Object.fromEntries(
        Object.entries(obj).map(([key, value]) => [key, deepInterpolate(value)])
      ) as T
    } else {
      return obj
    }
  }
  return deepInterpolate(props.article)
})
</script>
