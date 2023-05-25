const requester = args[0]
const datasetName = args[1]

// make HTTP request to get IPFS metadata
const req = Functions.makeHttpRequest({
  url: `https://api.lagrangedao.org/datasets/${requester}/${datasetName}`,
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

const metadata = data

// TODO: compare requester to metadata.owner
// if false, should throw error

// TODO: since the return is limited to some number of bytes,
// we cannot encode all files into the return
// so we need to somehow get the CID for all files,
// maybe using MCS SDK? or js-ipfs
// then add it as a field, suppose metadata.files

return Functions.encodeString(JSON.stringify(metadata.dataset))
