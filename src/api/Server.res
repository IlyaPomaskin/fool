open NodeJs

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
