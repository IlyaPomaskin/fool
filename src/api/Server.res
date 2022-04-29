let asdf = ref(0)

asdf := asdf.contents + 1

let default = (_: NodeJs.Http.ClientRequest.t, res: NodeJs.Http.ServerResponse.t) => {
  res->NodeJs.Http.ServerResponse.endWithData(
    NodeJs.Buffer.fromString(asdf.contents->string_of_int),
  )
}
