<template lang="html">
  <div class="home" v-if="!account">
    <form @submit.prevent="signUp">
      <card
        title="Enter your username here"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Type your username here"
        />
      </card>
    </form>
  </div>
  <div class="home" v-if="account">
    <div class="card-home-wrapper">
      <card
        title="My account"
        :subtitle="`${balance} Ξ\t\t${account.balance} Tokens`"
        :gradient="true"
      >
        <div class="explanations">
          <h2>Information of my account</h2>
          <p><b>Name: </b>{{ account.username }}</p>
          <p><b>Address: </b>{{ address }}</p>
          <p><b>ETH: </b>{{ balance }}</p>
          <p><b>Balance: </b>{{ account.balance }} Tokens</p>
        </div>
        <div class="explanations">
          On your account on the contract, you have
          {{ account.balance }} tokens. If you click
          <button class="button-link" @click="addTokens">here</button>, you can
          add some token to your account. Just give it a try! And think to put
          an eye on Ganache!
        </div>
      </card>
      <spacer :size="24" />
      <card
        title="My company"
        :subtitle="`${balance} Ξ\t\t${company.balance} Tokens`"
        v-if="company"
      >
        <div class="explanations" v-if="company">
          <h2>Information of my company</h2>
          <p><b>Name: </b>{{ company.name }}</p>
          <p><b>Owner's Address: </b>{{ company.owner }}</p>
          <p><b>Balance: </b>{{ company.balance }} Tokens</p>
        </div>
      </card>
      <spacer :size="24" />
      <card title="Create a company" :gradient="true">
        <router-link class="card-body" to="/company/create">
          Create a company now
        </router-link>
      </card>
      <spacer :size="24" />
      <card
        title="List of my project"
        :subtitle="`The number of project: ${projects.length}`"
        v-if="projects"
      >
        <div v-for="project in projects" v-bind:key="project.name">
          <resume-project :project="project"></resume-project>
        </div>
      </card>
      <spacer :size="24" />
      <card title="Create a project" :gradient="true">
        <router-link class="card-body" to="/project/create">
          Create a project now
        </router-link>
      </card>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  name: 'Account',
  components: { Card, Spacer },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const account = null
    const username = ''
    const userBalance = ''
    const company = null
    const projects: any[] = []
    return { account, username, userBalance, company, projects }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async signUp() {
      const { contract, username } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name).send()
      await this.updateAccount()
      this.username = ''
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(200).send()
      await this.updateAccount()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    this.company = await contract.methods.company(address).call()
    this.projects = await contract.methods.project(address).call()
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 500px;
  margin: auto;
}

.home-wrapper {
  margin: auto 24px auto 24px;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}

.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}
</style>
