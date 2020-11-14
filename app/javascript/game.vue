<template>
  <div id="game">
    <roster v-bind:roster="game.roster"></roster>
    <dice v-bind:turn="game.turn"
          v-bind:ownslot="ownslot"
          v-bind:break-out="game.breakOut"
          v-bind:board-score="curPlayer.score"
          v-on:roll="$emit('game-delta')"
          v-on:pass="passTurn"></dice>
    Turn score: {{game.turn.score}}
    <ul>
      <li>ONES : 100</li>
      <li>FIVES : 50</li>
      <li>3 ONES : 1000</li>
      <li>3 TWOS : 200</li>
      <li>3 THREES : 300</li>
      <li>3 FOURS : 400</li>
      <li>3 FIVES : 500</li>
      <li>3 SIXES : 600</li>
      <li>3 PAIRS : 1500</li>
      <li>2 TRIPLETS : 2500</li>
      <li>4 OF A KIND : 1000</li>
      <li>5 OF A KIND : 2000</li>
      <li>6 OF A KIND : 3000</li>
      <li>STRAIGHT (1-2-3-4-5-6) : 1500</li>
    </ul>
  </div>
</template>

<script>
import Roster from 'roster.vue'
import Dice from 'dice.vue'

export default {
  props: ['ownslot', 'game'],
  components: { Roster, Dice },
  computed: {
    curPlayer: function() {
      return this.game.roster.find((p) => p.slot == this.game.turn.slot);
    }
  },
  methods: {
    passTurn: function() {
      this.curPlayer.score += this.game.turn.score;
      this.game.turn.score = 0;
      this.game.turn.slot += 1;
      if (this.game.turn.slot > this.game.roster.length) {
        this.game.turn.slot = 1;
      }
      this.$emit('game-delta');
    }
  }
}
</script>

<style scoped>
</style>
