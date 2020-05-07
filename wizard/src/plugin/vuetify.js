import Vue from 'vue'
import Vuetify from 'vuetify'
import 'vuetify/src/styles/main.sass'
Vue.use(Vuetify)

export default new Vuetify({
  iconfont: 'fa',
  theme: {
    themes: {
      light: {
        primary: '#31404F'
      }
    }
  }
})
