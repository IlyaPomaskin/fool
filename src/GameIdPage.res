let default = () => {
  let router = Next.Router.useRouter()
  let gameId = router.query->Js.Dict.get("gameId")

  <PlayerScreen gameId />
}
