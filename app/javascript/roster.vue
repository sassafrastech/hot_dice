<template>
  <div id="roster">
    <ul>
      <li v-for="player in roster" :key="player.name" v-bind:class="{active: curSlot == player.slot}">
        {{ player.name }}: {{ player.score }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: ['roster', 'curSlot']
}
</script>

<style scoped>
  .active {
    font-weight: bold;
  }
</style>
