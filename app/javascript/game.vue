<template>
  <div id="game">
    <roster v-bind:roster="game.roster"
            v-bind:cur-slot="game.curSlot"></roster>
    <dice v-bind:turn="game.turn"
          v-bind:own-turn="ownTurn"
          v-bind:break-out="game.breakOut"
          v-bind:on-the-board="onTheBoard"
          v-on:roll="$emit('game-delta')"
          v-on:game-delta="$emit('game-delta')"
          v-on:pass="passTurn"></dice>
    <div id="legend">
      <ul>
        <li>ONES: 100</li>
        <li>FIVES: 50</li>
        <li>3 ONES: 1000</li>
        <li>3 TWOS: 200</li>
        <li>3 THREES: 300</li>
        <li>3 FOURS: 400</li>
        <li>3 FIVES: 500</li>
        <li>3 SIXES: 600</li>
        <li>3 PAIRS: 1500</li>
        <li>2 TRIPLETS: 2500</li>
        <li>4 OF A KIND: 1000</li>
        <li>5 OF A KIND: 2000</li>
        <li>6 OF A KIND: 3000</li>
        <li>STRAIGHT: 1500</li>
      </ul>
    </div>
  </div>
</template>

<script>
import Roster from 'roster.vue'
import Dice from 'dice.vue'

export default {
  props: ['ownSlot', 'game'],
  components: { Roster, Dice },
  computed: {
    curPlayer: function() {
      return this.game.roster.find((p) => p.slot == this.game.curSlot);
    },
    ownTurn: function() {
      return this.game.curSlot == this.ownSlot;
    },
    onTheBoard: function() {
      return (this.curPlayer || {score: 0}).score > 0;
    }
  },
  methods: {
    passTurn: function(e) {
      this.curPlayer.score += e.turnScore;
      this.game.curSlot += 1;
      if (this.game.curSlot > this.game.roster.length) {
        this.game.curSlot = 1;
      }
      this.$emit('game-delta');
    }
  }
}
</script>

<style scoped>
</style>
