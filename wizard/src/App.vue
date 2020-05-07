
<template>
  <v-app>
    <v-content fill-height>
      <v-carousel
        v-model="slideActive"
        :continuous="false"
        color="primary"
        class="pt-5"
        height="100%"
        delimiter-icon="fas fa-circle"
        :show-arrows="false"
        hide-delimiter-background
        :touch="{left: () => slideActive++, right: () => slideActive--}"
      >
        <v-carousel-item class="fill-height">
          <v-row class="fill-height" justify="center" align="center">
            <v-col>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h1 class="display-1 font-weight-bold textCentered">Hi! I'm 3bot.</h1>
                </div>
              </v-row>
              <v-row justify="center" class="my-5 py-5">
                <v-img
                  src="3Bot_Logo.png"
                  aspect-ratio="1"
                  contain
                  max-width="185"
                  max-height="185"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <p
                    class="textMarkup textCentered"
                  >I am here to assist you to engage with your digital world</p>
                </div>
              </v-row>
            </v-col>
          </v-row>
        </v-carousel-item>
        <v-carousel-item class="fill-height">
          <v-row class="fill-height" justify="center" align="center">
            <v-col>
              <v-row class="ma-3" justify="center">
                <h1 class="display-1 font-weight-bold textCentered">Meet your 3bot Vision</h1>
              </v-row>
              <v-row justify="center" class="my-5 py-5">
                <v-img
                  src="3Bot_Vision.png"
                  aspect-ratio="1"
                  contain
                  max-width="225"
                  max-height="185"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <p
                    class="textMarkup textCentered"
                  >A revolutionary digital avatar that executes your digital needs,</p>
                </div>
              </v-row>
            </v-col>
          </v-row>
        </v-carousel-item>
        <v-carousel-item>
          <v-row class="fill-height" justify="center" align="center">
            <v-col>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h1 class="display-1 font-weight-bold textCentered">With You at the Center</h1>
                </div>
              </v-row>
              <v-row justify="center" class="my-5 py-5">
                <v-img
                  src="3Bot_Center.png"
                  aspect-ratio="1"
                  contain
                  max-width="224"
                  max-height="203"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <p class="textMarkup textCentered">
                    A decentralized, private social
                    <br />space where you own and control
                    <br />your privacy and personal data.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-row>
        </v-carousel-item>
        <v-carousel-item>
          <v-row class="fill-height" justify="center" align="center">
            <v-col>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h1 class="display-1 font-weight-bold textCentered">Master your finance</h1>
                </div>
              </v-row>
              <v-row justify="center" class="my-5 py-5">
                <v-img
                  src="3Bot_Wallet.png"
                  aspect-ratio="1"
                  contain
                  max-width="231"
                  max-height="188"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <p class="textMarkup textCentered">
                    3bot is equipped with its own
                    <br />digital wallet, giving you access to
                    <br />global market of currencies and assets.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-row>
        </v-carousel-item>

        <v-carousel-item>
          <v-row class="fill-height" justify="center" align="center">
            <v-col>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h1 class="display-1 font-weight-bold textCentered">Explore 3bot Experiences</h1>
                </div>
              </v-row>
              <v-row justify="center" class="my-5 py-5">
                <v-img
                  src="3Bot_Experiences.png"
                  aspect-ratio="1"
                  contain
                  max-width="202"
                  max-height="185"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">What's coming next?</h3>
                  <p class="textMarkup textCentered">
                    From data storage, personal
                    <br />assistant, to video call... Enjoy
                    <br />3bot Experiences at your
                    <br />fingertips.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-row>
        </v-carousel-item>
        <v-carousel-item>
          <v-row class="fill-height" justify="center" align="center">
            <v-col>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <p class="title font-weight-bold textCentered">
                    Start Your Journey
                    <br />towards Digital
                    <br />Freedom
                  </p>
                </div>
              </v-row>
              <v-row justify="center" class="my-5 py-5">
                <v-img
                  src="3Bot_Begin.png"
                  class="my-5 py-5"
                  aspect-ratio="1"
                  contain
                  max-width="260"
                  max-height="185"
                ></v-img>
              </v-row>
              <v-row class="ma-3 mt-5" justify="center">
                <div class="text-center mt-5 outline">
                  <v-btn
                    color="primary"
                    onclick="window.flutter_inappwebview.callHandler('FINISH')"
                  >Get started!</v-btn>
                </div>
              </v-row>
            </v-col>
          </v-row>
        </v-carousel-item>
      </v-carousel>
    </v-content>
  </v-app>
</template>

<script>
export default {
  name: 'App',
  data: () => {
    return {
      slideActive: 0
    }
  }
}
</script>
<style>
p {
  color: #2d4051;
}
.textMarkup {
  line-height: 1.3;
  font-weight: 450;
  font-size: 18px;
}
.v-btn--active .v-btn__content .v-icon::before {
  scale: 1.3;
  background: linear-gradient(to top, #68c5d5 0%, #73e5c0 100%);
  background-clip: text;
  -webkit-text-fill-color: transparent;
}
.v-btn .v-btn__content .v-icon::before {
  color: #c1c5ca;
}
.outline {
  background: linear-gradient(to top, #68c5d5 0%, #73e5c0 100%);
  padding: 2px;
  border-radius: 5px;
}
.v-carousel .v-carousel__controls {
  position: absolute;
  bottom: 10%;
}
.v-carousel__controls__item .v-icon {
  opacity: 1 !important;
}
#skip {
  z-index: 1000;
}
</style>
