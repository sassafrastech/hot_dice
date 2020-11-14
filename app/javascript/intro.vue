<template>
  <div id="intro">
    <form>
      <label>
        Game Code
        <input type="number" v-model="self.gameCode"/>
      </label>
      <label>
        Player Name
        <input type="text" v-model="self.name"/>
      </label>
      <button v-on:click.prevent="$emit('start-click')">
        Play!
      </button>
    </form>
  </div>
</template>

<script>
export default {
  props: ['self'],
  data: function () {
    return {
    }
  }
}
</script>

<style scoped>

</style>
