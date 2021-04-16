<template>
  <div id="app">
    <h1 v-bind:class="{hot: game.turn.hot}">Hot Dice!</h1>
    <intro v-if="self.fresh" v-bind:self="self" v-on:start-click="joinGame"></intro>
    <div v-if="self.joining">Joining game...</div>
    <game v-if="self.slot" v-bind:game="game" v-bind:own-slot="self.slot"
          v-on:game-delta="shareGameDelta()"></game>
  </div>
</template>

<script>
import Intro from 'intro.vue'
import Game from 'game.vue'
import consumer from 'channels/consumer'

export default {
  data: function () {
    return {
      self: {
        gameCode: null,
        name: '',
        joining: false,
        fresh: true,
        slot: null,
        saidHello: false
      },
      game: {
        started: false,
        curSlot: null,
        turn: {
          dice: [
            {index: 1, val: 1, status: 'fresh'},
            {index: 2, val: 1, status: 'fresh'},
            {index: 3, val: 1, status: 'fresh'},
            {index: 4, val: 1, status: 'fresh'},
            {index: 5, val: 1, status: 'fresh'},
            {index: 6, val: 1, status: 'fresh'}
          ],
          score: 0,
          hot: false,
          farkle: false
        },
        breakOut: 500,
        roster: []
      },
      slots: {
        count: 0,
        claims: [],
      },
      channel: null
    }
  },
  methods: {
    joinGame: function (event) {
      let app = this;
      this.self.joining = true;
      this.self.fresh = false;
      app.channel = consumer.subscriptions.create({channel: 'GameChannel', game_code: app.self.gameCode}, {
        connected() {
          if (!app.self.saidHello) {
            app.self.saidHello = true;
            app.sayHello();
          }
        },

        disconnected() {

        },

        say(data) {
          data.from = app.self.name;
          this.perform('say', data);
        },

        received(data) {
          app.log("*************************** state update");
          app.log(JSON.stringify(data));
          app.handleUpdate(data);
        }
      });
    },
    handleUpdate: function(data) {
      if (data.game) {
        this.game = data.game;
      }
      if (data.slots && data.slots.count) {
        this.slots.count = Math.max(this.slots.count, data.slots.count);
      }
      if (data.slots && data.slots.claims) {
        let claims = this.slots.claims.concat(data.slots.claims);
        this.slots.claims = [...new Map(claims.map(c => [`${c.slot},${c.name}`, c])).values()];
      }
      if (data.hello && data.from != this.self.name && (!this.game.started || this.self.slot == 1)) {
        this.channel.say({game: this.game, slots: this.slots});
      }
    },
    shareGameDelta: function() {
      this.channel.say({game: this.game});
    },
    sayHello: function() {
      let app = this;
      this.log('Saying hello and waiting for game state');
      this.channel.say({hello: 1});
      setTimeout(function() { app.claimSlot(); }, 1000);
    },
    claimSlot: function() {
      this.log('Claiming next slot');
      let app = this;
      const claims = this.slots.claims;
      const num = claims.length ? claims.map((c) => c.slot).reduce((a, b) => Math.max(a, b)) + 1 : 1;
      const assertiveness = Math.random();
      this.channel.say({
        slots: {
          claims: [{slot: num, name: this.self.name, assertiveness}],
          count: num
        }
      });
      setTimeout(function() { app.checkClaim(num, assertiveness) }, 1000);
    },
    checkClaim: function(num, assertiveness) {
      this.log(`Checking claim ${num}`);
      let app = this;
      const competitors = app.slots.claims.filter((c) => (c.slot == num && c.name != app.self.name));
      const maxAssert = competitors.length ? competitors.reduce((a, b) => Math.max(a.ass, b.slot)) : 0;
      if (assertiveness > maxAssert) {
        this.log(`Won slot ${num}`);
        if (num == 1) {
          app.game.started = true;
          app.game.curSlot = 1;
        }
        app.self.slot = num;
        app.self.joining = false;
        app.game.roster.push({slot: num, name: app.self.name, score: 0});
        app.channel.say({game: app.game});
      } else {
        this.log(`DIDNT win slot ${num}, retrying`);
        app.claimSlot();
      }
    },
    log: function(msg) {
      const now = new Date();
      const stamp = '' + now.getHours() + ':' + now.getMinutes() + ':' + now.getSeconds() +
        '.' + now.getMilliseconds();
      console.log(stamp, msg);
    }
  },
  components: { Intro, Game }
}
</script>

<style scoped>
  .hot {
    color: red;
  }
</style>
