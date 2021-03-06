import config from '../../../public/config'
import cryptoService from '../../services/CryptoService'
import threebotService from '../../services/threebotService'

export default {
  name: 'callback',
  data() {
    return {
      username: null,
      verified: false,
      error: null
    }
  },
  async mounted() {
    let url = new URL(window.location.href)

    let error = url.searchParams.get('error')

    if (error) {
      console.log('Error: ', error)
      return
    }

    let signedAttemptObject = JSON.parse(url.searchParams.get('signedAttempt'));

    let user = signedAttemptObject['doubleName']
    let userPublicKey = (await threebotService.getUserData(user)).data.publicKey

    let verifiedSignedAttempt

    try {

      var utf8ArrayToStr = (function () {
        var charCache = new Array(128)
        var charFromCodePt = String.fromCodePoint || String.fromCharCode
        var result = []

        return function (array) {
          var codePt, byte1
          var buffLen = array.length

          result.length = 0

          for (var i = 0; i < buffLen;) {
            byte1 = array[i++]

            if (byte1 <= 0x7F) {
              codePt = byte1
            } else if (byte1 <= 0xDF) {
              codePt = ((byte1 & 0x1F) << 6) | (array[i++] & 0x3F)
            } else if (byte1 <= 0xEF) {
              codePt = ((byte1 & 0x0F) << 12) | ((array[i++] & 0x3F) << 6) | (array[i++] & 0x3F)
            } else if (String.fromCodePoint) {
              codePt = ((byte1 & 0x07) << 18) | ((array[i++] & 0x3F) << 12) | ((array[i++] & 0x3F) << 6) | (array[i++] & 0x3F)
            } else {
              codePt = 63
              i += 3
            }

            result.push(charCache[codePt] || (charCache[codePt] = charFromCodePt(codePt)))
          }

          return result.join('')
        }
      })()

      verifiedSignedAttempt = JSON.parse(utf8ArrayToStr(await cryptoService.validateSignedAttempt(signedAttemptObject['signedAttempt'], userPublicKey)))

      if (!verifiedSignedAttempt) {
        console.log('The signedAttempt could not be verified.')
        return
      }

      let state = window.localStorage.getItem('state')

      if (verifiedSignedAttempt['signedState'] !== state) {
        console.log('The state cannot be matched.')
        return
      }

      if (verifiedSignedAttempt['doubleName'] !== user) {
        console.log('The name cannot be matched.')
        return
      }
    } catch (e) {
      console.log('The signedAttempt could not be verified.')
      return
    }

    let encryptedData = verifiedSignedAttempt['data']

    // Keys from the third party app itself, or a temp keyset if it is a front-end only third party app.
    let keys = await cryptoService.generateKeys(config.seedPhrase)

    let decryptedData = JSON.parse(await cryptoService.decrypt(encryptedData.ciphertext, encryptedData.nonce, keys.privateKey, userPublicKey))
    decryptedData['name'] = user

    // SEI = Signed Email Identifier, this is used to link the email to the doubleName and verify it. 
    if (!decryptedData.email || !decryptedData.email.sei) {
      console.log('No sei was given from the app, if your app requires email, the flow stops here.')
    } else {
      // To verify the SEI, you could use the function implemented by openKYC or verify it yourself using openKYC his publicKey.
      let seiVerified = await threebotService.verifySignedEmailIdentifier(decryptedData.email.sei)

      if (!seiVerified || seiVerified.status !== 200) {
        console.log('sei could not be verified, something went wrong or someone is trying to forge his email verification.')
        return
      }

      console.log('We verified that ' + seiVerified.data.email + ' belongs to ' + seiVerified.data.identifier + ' and has a valid verification.')
    }

    window.localStorage.setItem('profile', JSON.stringify(decryptedData))
    this.$router.push({ name: 'profile' })
  }
}
