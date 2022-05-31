open Types
open NodeJs
open ServerUtils

let default = (req: Http.IncomingMessage.t, res: Http.ServerResponse.t) => {
  WsServer.setWsServer(res)

  let searchParams = req->getUrl("http")->getSearchParams
  let playerId = getParam(searchParams, "playerId")
  let sessionId = getParam(searchParams, "sessionId")

  let response = switch (playerId, sessionId) {
  | (_, Some(sessionId)) => {
      Js.log(`/api/user login ${sessionId}`)
      GameInstance.loginPlayer(sessionId)->Result.map(player => LoggedIn(player))
    }
  | (Some(playerId), _) => {
      Js.log(`/api/user register ${playerId}`)
      GameInstance.registerPlayer(playerId)->Result.map(player => Registered(player))
    }
  | _ => Error("No way to authorize")
  }

  let json = switch response {
  | Ok(player) => Serializer.serializeUserApiResponse(player)
  | Error(err) => Serializer.serializeUserApiResponse(UserError(err))
  }

  res->Http.ServerResponse.endWithData(Buffer.fromString(json))
}
