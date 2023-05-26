const requester = args[0]
const datasetName = args[1]

// make HTTP request to get IPFS metadata
const req = Functions.makeHttpRequest({
  method: 'POST',
  url: `https://api.lagrangedao.org/datasets/${requester}/${datasetName}/generate_metadata`,
  headers: { Authorization: `Bearer ${secrets.apiKey}` },
})

// Execute the API request (Promise)
const res = await req
if (res.error) {
  console.error(res.error)
  throw Error('Request failed')
}

const data = res['data']
if (data.Response === 'Error') {
  console.error(data.Message)
  throw Error(`Functional error. Read message: ${data.Message}`)
}

if (data.ipfs_url == null) {
  throw Error(data.message)
}

return Functions.encodeString(JSON.stringify(data.ipfs_url))
