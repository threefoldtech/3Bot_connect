
<template>
  <v-carousel
    v-model="slideActive"
    :cycle="false"
    :continuous="false"
    color="primary"
    class="carousel"
    height="100%"
    delimiter-icon="fiber_manual_record"
    hide-delimiter-background
    :hide-delimiters="slideActive == 5"
    :touch="{left: () => slideActive++, right: () => slideActive--}"
  >
    <v-carousel-item class="fill-height">
      <v-layout class="fill-height" justify-center align-center>
        <v-flex>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <h1 class="display-1 font-weight-bold text-xs-center">Hi! I'm 3bot.</h1>
            </div>
          </v-layout>
          <v-layout justify-center class="my-5 py-5">
            <v-img src="3Bot_Logo.png" aspect-ratio="1" contain max-width="185" max-height="185"></v-img>
          </v-layout>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <p
                class="textMarkup text-xs-center"
              >I am here to assist you to engage with your digital world</p>
            </div>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-carousel-item>
    <v-carousel-item class="fill-height">
      <v-layout class="fill-height" justify-center align-center>
        <v-flex>
          <v-layout class="ma-3" justify-center>
            <h1 class="display-1 font-weight-bold text-xs-center">Meet your 3bot Vision</h1>
          </v-layout>
          <v-layout justify-center class="my-5 py-5">
            <v-img src="3Bot_Vision.png" aspect-ratio="1" contain max-width="225" max-height="185"></v-img>
          </v-layout>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <p
                class="textMarkup text-xs-center"
              >A revolutionary digital avatar that executes your digital needs,</p>
            </div>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-carousel-item>
    <v-carousel-item>
      <v-layout class="fill-height" justify-center align-center>
        <v-flex>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <h1 class="display-1 font-weight-bold text-xs-center">With You at the Center</h1>
            </div>
          </v-layout>
          <v-layout justify-center class="my-5 py-5">
            <v-img src="3Bot_Center.png" aspect-ratio="1" contain max-width="224" max-height="203"></v-img>
          </v-layout>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <p class="textMarkup text-xs-center">
                A decentralized, private social
                <br />space where you own and control
                <br />your privacy and personal data.
              </p>
            </div>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-carousel-item>
    <v-carousel-item>
      <v-layout class="fill-height" justify-center align-center>
        <v-flex>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <h1 class="display-1 font-weight-bold text-xs-center">Master your finance</h1>
            </div>
          </v-layout>
          <v-layout justify-center class="my-5 py-5">
            <v-img src="3Bot_Wallet.png" aspect-ratio="1" contain max-width="231" max-height="188"></v-img>
          </v-layout>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <p class="textMarkup text-xs-center">
                3bot is equipped with its own
                <br />digital wallet, giving you access to
                <br />global market of currencies and assets.
              </p>
            </div>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-carousel-item>

    <v-carousel-item>
      <v-layout class="fill-height" justify-center align-center>
        <v-flex>
          <v-layout class="ma-3" justify-center align-center>
            <v-flex>
              <h1 class="display-1 font-weight-bold text-xs-center">Explore 3bot Experiences</h1>
            </v-flex>
          </v-layout>
          <v-layout justify-center class="my-5 py-5">
            <v-img
              src="3Bot_Experiences.png"
              aspect-ratio="1"
              contain
              max-width="202"
              max-height="185"
            ></v-img>
          </v-layout>
          <v-layout class="ma-3" justify-center>
            <div class="text-xs-center">
              <p class="textMarkup text-xs-center">
                From data storage, personal
                <br />assistant, to video call... Enjoy
                <br />3bot Experiences at your
                <br />fingertips.
              </p>
            </div>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-carousel-item>
    <v-carousel-item>
      <v-layout class="fill-height" justify-center align-center>
        <v-flex>
          <div class="text-xs-center">
            <h1 class="display-1 font-weight-bold text-xs-center">
              Start Your Journey
              <br />towards Digital
              <br />Freedom
            </h1>
          </div>
          <v-layout justify-center class="my-5">
            <v-img
              src="3Bot_Begin.png"
              class="my-5 py-5"
              aspect-ratio="1"
              contain
              max-width="260"
              max-height="185"
            ></v-img>
          </v-layout>
          <v-layout class="ma-3 mt-5" justify-center>
            <div class="text-xs-center mt-5 outline">
              <v-btn
                color="primary"
                onclick="window.flutter_inappwebview.callHandler('FINISH')"
              >Get started!</v-btn>
            </div>
          </v-layout>
        </v-flex>
      </v-layout>
    </v-carousel-item>
  </v-carousel>
</template>

<script>
export default {
  name: "App",
  data: () => {
    return {
      slideActive: 0
    };
  }
};
</script>
<style>
.carousel {
  position: fixed !important;
  height: 100% !important;
  width: 100% !important;
  left: 0 !important;
  top: 0 !important;
  background: white !important;
}
p {
  color: #2d4051;
}
.textMarkup {
  line-height: 1.3;
  font-weight: 450;
  font-size: 18px;
  text-align: center;
}
.v-btn--active .v-btn__content .v-icon {
  scale: 1.3;
  background: linear-gradient(to top, #68c5d5 0%, #73e5c0 100%);
  background-clip: text;
  -webkit-text-fill-color: transparent;
}
.v-btn .v-btn__content .v-icon {
  color: #c1c5ca;
}
.v-carousel__controls {
  background: none !important;
}
.outline {
  background: linear-gradient(to top, #68c5d5 0%, #73e5c0 100%);
  padding: 0px;
  border-radius: 5px;
}
.outline > button {
  margin: 3px;
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
.v-carousel__prev,
.v-carousel__next {
  display: none;
}
</style>
