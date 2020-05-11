import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import './plugins'
import './style.scss'
Vue.config.productionTip = false

router.beforeEach((to, from, next) => {
  if (to.name === 'login' && !store.state.doubleName) {
    next({
      name: 'initial'
    })
  } else {
    next()
  }
})

export default new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
