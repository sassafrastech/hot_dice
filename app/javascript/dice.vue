<template>
  <div id="dice">
    <div v-for="die in dice" :key="die.index">
      <span v-bind:class="['die', die.status]" v-html="glyphs[die.val - 1]"
            v-on:click="dieClick(die)"></span>
    </div>
    <button v-if="canRoll" v-on:click="roll()">Roll</button>
    <button v-if="canPass" v-on:click="pass()">Pass</button>
    <br/>
    Pull Score: {{pullScore}}
  </div>
</template>

<script>
export default {
  props: ['turn', 'ownslot', 'breakOut', 'boardScore'],
  data: function() {
    return {
      firstRoll: true,
      glyphs: ['&#9856;', '&#9857;', '&#9858;', '&#9859;', '&#9860;', '&#9861;'],
    }
  },
  computed: {
    dice: function() {
      return this.turn.dice;
    },
    ownTurn: function() {
      return this.ownslot == this.turn.slot;
    },
    canRoll: function() {
      return this.ownTurn && (this.firstRoll || this.pullScore > 0);
    },
    canPass: function() {
      return this.ownTurn && this.brokenOut && this.pullScore > 0;
    },
    turnScore: function() {
      return this.turn.score;
    },
    brokenOut: function() {
      return this.boardScore + this.turnScore + this.pullScore >= this.breakOut;
    },
    pullScore: function() {
      const vals = this.dice.filter((d) => d.status == 'pulled').map((d) => d.val);
      return this.bestScore(vals);
    },
    allHeld: function() {
      return this.dice.every((d) => d.status == 'held');
    }
  },
  methods: {
    // if farkle (non-held dice have no possible scoring combinatations after roll),
    // set farkle true, hot false, reset curHoldScore to zero, set timeout to pass turn
    roll: function() {
      this.holdScore();
      this.holdPulledDice();
      if (this.allHeld) {
        this.turn.hot = true;
        this.resetDice();
      }
      this.rollAvailableDice();
      this.firstRoll = false;
      this.$emit('roll');
    },
    pass: function() {
      this.holdScore();
      this.resetDice();
      this.turn.hot = false;
      this.turn.farkle = false;
      this.firstRoll = true;
      this.$emit('pass');
    },
    holdPulledDice: function() {
      this.dice.forEach((die) => {
        if (die.status == 'pulled') {
          die.status = 'held';
        }
      });
    },
    rollAvailableDice: function() {
      this.dice.forEach((die) => {
        if (die.status == 'free' || die.status == 'fresh') {
          die.val = Math.floor(Math.random() * 6) + 1;
          die.status = 'free';
        }
      });
    },
    resetDice: function() {
      this.dice.forEach((d) => d.status = 'fresh');
    },
    dieClick: function(die) {
      if (die.status == 'held' || die.status == 'fresh') {
        return;
      } else {
        die.status = die.status == 'pulled' ? 'free' : 'pulled';
      }
    },
    holdScore: function() {
      this.turn.score += this.pullScore;
    },
    bestScore: function(vals) {
      console.log(vals)
      if (vals.length == 0) {
        return 0;
      }

      let possible = [];
      vals.sort;

      const ones = vals.reduce((count, v) => count + (v == 1 ? 1 : 0), 0);
      const fives = vals.reduce((count, v) => count + (v == 5 ? 1 : 0), 0);
      console.log(ones, fives);
      if (ones + fives == vals.length) {
        possible.push(ones * 100 + fives * 50);
      }

      const allSame = vals.every((v) => v == vals[0]);
      if (allSame) {
        if (vals.length == 3) {
          switch (vals[0]) {
            case 1: possible.push(1000); break;
            case 2: possible.push(200); break;
            case 3: possible.push(300); break;
            case 4: possible.push(400); break;
            case 5: possible.push(500); break;
            case 6: possible.push(600); break;
          }
        } else if (vals.length == 4) {
          possible.push(1000);
        } else if (vals.length == 5) {
          possible.push(2000);
        } else if (vals.length == 6) {
          possible.push(3000);
        }
      } else if (vals.toString() == "1,2,3,4,5,6") {
        possible.push(1500);
      } else if (vals.length == 6) {
        const left = [vals[0], vals[2], vals[4]];
        const right = [vals[1], vals[3], vals[5]];
        const distinct = left[0] != left[1] && left[0] != left[2] && left[1] != left[2];
        if (left.toString() == right.toString() && distinct) {
          possible.push(1500);
        }
      }
      console.log(possible);
      return Math.max(...possible, 0)
    }
  }
}
</script>

<style scoped>
  .die {
    font-size: 40px;
  }

  .die.pulled, .die.held {
    margin-left: 50px;
  }

  .die.free, .die.pulled {
    cursor: pointer;
  }
</style>
