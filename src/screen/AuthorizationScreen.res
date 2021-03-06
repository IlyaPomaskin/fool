open Types
open Utils
open Js.Promise

@react.component
let make = (~onLogin, ~sessionId=None) => {
  let (login, setLogin) = React.useState(_ => "")
  let (error, setError) = React.useState(_ => None)
  let (isLoading, setIsLoading) = React.useState(_ => false)

  let makeAuthRequest = (arg, value) => {
    setIsLoading(_ => true)

    Fetch.fetch(`${getFullUrl(~isWs=false, ())}/api/user?${arg}=${value}`)
    |> then_(Fetch.Response.text)
    |> then_(json => Serializer.deserializeUserApiResponse(json)->resolve)
    |> then_(response => {
      switch response {
      | Ok(LoggedIn(player))
      | Ok(Registered(player)) => {
          if Option.isNone(sessionId) {
            LocalStorage.SessionStorage.setItem("sessionId", player.sessionId)
          }

          onLogin(player)
        }
      | Ok(UserError(err)) => setError(_ => Some(err))
      | Error(err) => {
          LocalStorage.SessionStorage.setItem("sessionId", "")
          setError(_ => Some(Jzon.DecodingError.toString(err)))
        }
      }->resolve
    })
    |> catch(_ => resolve())
    |> then_(_ => setIsLoading(_ => false)->resolve)
    |> ignore
  }

  React.useEffect0(() => {
    let lsSessionId = LocalStorage.SessionStorage.getItem("sessionId")->Js.Nullable.toOption
    let sessionId = switch (sessionId, lsSessionId) {
    | (Some(x), _) => x
    | (None, Some(x)) => x
    | _ => ""
    }

    if sessionId != "" {
      makeAuthRequest("sessionId", sessionId)
    }

    None
  })

  let handleRegistrationClick = _ => makeAuthRequest("playerId", login)

  <div className="flex flex-col gap-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Authorization")} </Base.Heading>
    {switch error {
    | Some(err) => <span> {uiStr(`Error: ${err}`)} </span>
    | _ => React.null
    }}
    <Base.Input disabled={isLoading} value={login} onChange={value => setLogin(_ => value)} />
    <Base.Button disabled={login === ""} onClick={handleRegistrationClick}>
      {uiStr("Register")}
    </Base.Button>
  </div>
}
