const eth_crypto_1 = require('eth-crypto')

const encryptWithSignature = async (
  signerPrivateKey,
  readerPublicKey,
  message,
) => {
  const signature = eth_crypto_1.default.sign(
    signerPrivateKey,
    eth_crypto_1.default.hash.keccak256(message),
  )
  const payload = {
    message,
    signature,
  }
  return await encrypt(readerPublicKey, JSON.stringify(payload))
}

const encrypt = async (readerPublicKey, message) => {
  const encrypted = await eth_crypto_1.default.encryptWithPublicKey(
    readerPublicKey,
    message,
  )
  return eth_crypto_1.default.cipher.stringify(encrypted)
}

// Example usage
const signerPrivateKey =
  '5c412d5f09c85ab2271cb5712dee9f87384321c6a87b750092502ba68cadc1d0' // Your private key
const readerPublicKey =
  'a30264e813edc9927f73e036b7885ee25445b836979cb00ef112bc644bd16de2db866fa74648438b34f52bb196ffa386992e94e0a3dc6913cee52e2e98f1619c' // Recipient's public key
const message = { apiKey: 'Hello, world!' }

;(async () => {
  try {
    const encryptedMessage = await encryptWithSignature(
      signerPrivateKey,
      readerPublicKey,
      message,
    )
    console.log('Encrypted message:', encryptedMessage)
  } catch (error) {
    console.error('Encryption failed:', error)
  }
})()
