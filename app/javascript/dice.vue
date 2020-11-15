<template>
  <div id="dice">
    <div v-for="die in dice" :key="die.index">
      <span v-bind:class="['die', die.status]" v-html="glyphs[die.val - 1]"
            v-on:click="dieClick(die)"></span>
    </div>
    <button v-if="canRoll" v-on:click="roll()">Roll</button>
    <button v-if="canPass" v-on:click="pass()">Pass</button>
    <br/>
    Turn score: {{turn.score}}
    Pull score: {{pullScore}}
    {{turn.farkle ? 'FARKLE' : ''}}
  </div>
</template>

<script>
export default {
  props: ['turn', 'ownTurn', 'breakOut', 'onTheBoard'],
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
    canRoll: function() {
      return this.ownTurn && (this.firstRoll || this.pullScore > 0);
    },
    canPass: function() {
      return this.ownTurn && (this.turn.farkle || (this.brokenOut && this.pullScore > 0));
    },
    turnScore: function() {
      return this.turn.score;
    },
    brokenOut: function() {
      return this.onTheBoard || (this.turnScore + this.pullScore >= this.breakOut);
    },
    pullScore: function() {
      const vals = this.dice.filter((d) => d.status == 'pulled').map((d) => d.val);
      return this.computeScore(vals, 'bestUsingAll');
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
      const freeVals = this.dice.filter((d) => d.status == 'free').map((d) => d.val);
      console.log('******************************************');
      console.log('Free vals', freeVals);
      const freeScore = this.computeScore(freeVals, 'firstUsingAny');
      console.log('Free score', freeScore);
      if (freeScore == 0) {
        this.turn.farkle = true;
        this.turn.score = 0;
      }
      this.printState();
      this.$emit('game-delta');
    },
    pass: function() {
      this.holdScore();
      this.resetDice();
      const turnScore = this.turn.score;
      this.turn.hot = false;
      this.turn.farkle = false;
      this.turn.score = 0;
      this.firstRoll = true;
      this.printState();
      this.$emit('pass', {turnScore: turnScore});
    },
    dieClick: function(die) {
      if (die.status == 'held' || die.status == 'fresh') {
        return;
      } else {
        die.status = die.status == 'pulled' ? 'free' : 'pulled';
      }
      this.printState();
      this.$emit('game-delta');
    },
    holdPulledDice: function() {
      this.dice.forEach((die) => {
        if (die.status == 'pulled') {
          die.status = 'held';
        }
      });
      this.$emit('game-delta');
    },
    rollAvailableDice: function() {
      this.dice.forEach((die) => {
        if (die.status == 'free' || die.status == 'fresh') {
          die.val = Math.floor(Math.random() * 6) + 1;
          die.status = 'free';
        }
      });
      this.$emit('game-delta');
    },
    resetDice: function() {
      this.dice.forEach((d) => (d.status = 'fresh') && (d.val = 1));
    },
    holdScore: function() {
      this.turn.score += this.pullScore;
    },
    // mode can be 'bestUsingAll' or 'firstUsingAny'
    // return of 0 means no scoring possible
    computeScore: function(vals, mode) {
      if (vals.length == 0) {
        return 0;
      }

      let hit = null;
      let done = false;
      let best = 0;

      let freqHash = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
      vals.forEach((v) => freqHash[v] += 1);
      let freqStr = Object.values(freqHash).sort().reverse().toString();

      for (let i = 0; true; i += 1) {
        let freqArray = Object.entries(freqHash).sort((pairA, pairB) => pairA[1] - pairB[1]).reverse();
        switch (i) {
          case 0: // 6 of a kind
            if (freqStr == "6,0,0,0,0,0") {
              hit = 3000;
              freqArray = [];
            }
            break;
          case 1: // 2 triplets
            if (freqStr == "3,3,0,0,0,0") {
              hit = 2500;
              freqArray = [];
            }
            break;
          case 2: // Straight
            if (freqStr == "1,1,1,1,1,1") {
              hit = 1500;
              freqArray = [];
            }
            break;
          case 3: // 3 pairs
            if (freqStr == "2,2,2,0,0,0") {
              hit = 1500;
              freqArray = [];
            }
            break;
          case 4: // 5 of a kind
            if (freqArray[0][1] == 5) {
              hit = 2000;
              freqArray.shift();
            }
            break;
          case 5: // 4 of a kind
            if (freqArray[0][1] == 4) {
              hit = 1000;
              freqArray.shift();
            }
            break;
          case 6: // 3 of a kind
            if (freqArray[0][1] == 3) {
              switch (freqArray[0][0]) {
                case '1': hit = 1000; break;
                case '2': hit = 200; break;
                case '3': hit = 300; break;
                case '4': hit = 400; break;
                case '5': hit = 500; break;
                case '6': hit = 600; break;
              }
              freqArray.shift();
            }
            break;
          case 7: // 1 or 2 1's
            if (freqHash['1'] > 0 && freqHash['1'] <= 2) {
              hit = freqHash['1'] * 100;
              freqArray = freqArray.filter((pair) => pair[0] != '1');
            }
            break;
          case 8: // 1 or 2 5's
            if (freqHash['5'] > 0 && freqHash['5'] <= 2) {
              hit = freqHash['5'] * 50;
              freqArray = freqArray.filter((pair) => pair[0] != '5');
            }
            break;
          default:
            done = true;
        }

        if (mode == 'firstUsingAny' && hit) {
          return hit;
        } else if (mode == 'bestUsingAll' && hit) {
          let remaining = [];
          freqArray.forEach((pair) => {
            remaining = remaining.concat(Array.from({length: pair[1]}, () => parseInt(pair[0])))
          });
          let extra = this.computeScore(remaining, mode);
          let full = remaining.length == 0 || extra > 0 ? hit + extra : 0;
          best = Math.max(best, full);
        } else if (done) {
          return best;
        }

        hit = null;
      }

      return 0;
    },
    printState: function() {
      console.log('******************************************');
      console.log('ownTurn', this.ownTurn);
      console.log('breakOut', this.breakOut);
      console.log('onTheBoard', this.onTheBoard);
      console.log('hot', this.turn.hot);
      console.log('farkle', this.turn.farkle);
      console.log('dice', JSON.stringify(this.dice));
      console.log('canRoll', this.canRoll);
      console.log('canPass', this.canPass);
      console.log('turnScore', this.turnScore);
      console.log('brokenOut', this.brokenOut);
      console.log('pullScore', this.pullScore);
      console.log('allHeld', this.allHeld);
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
