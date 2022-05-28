open Types

let default = () => {
  let router = Next.Router.useRouter()
  let gameId = router.query->Js.Dict.get("gameId")

  Js.log(router.query)

  let onConnect = (sendMessage, player) => {
    switch (gameId, player) {
    | (Some(gameId), Some(player)) => sendMessage(Lobby(Enter, player.id, gameId))
    | _ => ignore()
    }
  }

  <PlayerScreen onConnect />
}
