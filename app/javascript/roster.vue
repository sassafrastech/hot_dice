<template>
  <div id="roster">
    <ul>
      <li v-for="player in roster" :key="player.name">
        {{ player.name }}: {{ player.score }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: ['roster']
}
</script>

<style scoped>
</style>
