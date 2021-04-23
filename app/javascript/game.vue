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
      <div>Ones: 100</div>
      <div>Fives: 50</div>
      <div>3 Ones: 1000</div>
      <div>3 Twos: 200</div>
      <div>3 Threes: 300</div>
      <div>3 Fours: 400</div>
      <div>3 Fives: 500</div>
      <div>3 Sixes: 600</div>
      <div>3 Pairs: 1250</div>
      <div>2 Triplets: 2500</div>
      <div>4 of a Kind: 1100</div>
      <div>5 of a Kind: 3000</div>
      <div>6 of a Kind: 6000</div>
      <div>Straight: 1500</div>
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
