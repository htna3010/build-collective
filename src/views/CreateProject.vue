<template lang="html">
  <div class="home">
    <form @submit.prevent="createProject">
      <card title="Create project">
        <input
          type="text"
          class="input-username"
          v-model="projectName"
          placeholder="Project's name"
        />
        <input
          type="number"
          class="input-username"
          v-model="projectBalance"
          placeholder="Balance of tokens"
        />
        <button type="submit" class="input-username">Create</button>
      </card>
    </form>
  </div>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  name: 'CreateProject',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const users: any[] = []
    const projectAccount = null
    const projectName = ''
    const projectBalance = ''
    return {
      projectName,
      users,
      projectAccount,
      projectBalance,
    }
  },
  methods: {
    async updateProjectAccount() {
      const { address, contract } = this
      this.projectAccount = await contract.methods
          .project(address)
          .call()
    },
    async createProject() {
      const { contract, projectName, projectBalance } =
          this
      const name = projectName.trim().replace(/ /g, '_')
      await contract.methods
          .createProject(name,projectBalance)
          .send()
      await this.updateProjectAccount()
      await this.$router.push({ name: 'Account' })
    },
  },
  async mounted() {
    const { address, contract } = this
    this.projectAccount = await contract.methods
        .project(address)
        .call()
    const userAddresses = await contract.methods.user().call()
    for (const userAddressesKey of userAddresses) {
      const account = await contract.methods
          .user(userAddressesKey)
          .call()
      this.users.push({ address: userAddressesKey, account: account })
    }
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
</style>
