const encodedString = process.argv[2]

const decodedString = Buffer.from(encodedString, 'hex').toString('utf8')

console.log(decodedString)
