open Types
open Utils
open Js.Promise

@react.component
let make = (~onLogin) => {
  let (login, setLogin) = React.useState(_ => "")
  let (error, setError) = React.useState(_ => None)
  let (isLoading, setIsLoading) = React.useState(_ => false)

  let makeRequest = (arg, sessionId) => {
    setIsLoading(_ => true)

    Fetch.fetch(`http://localhost:3000/api/user?${arg}=${sessionId}`)
    |> then_(Fetch.Response.text)
    |> then_(json => Serializer.deserializeUserApiResponse(json)->resolve)
    |> then_(response => {
      switch response {
      | Ok(LoggedIn(player))
      | Ok(Registered(player)) => {
          LocalStorage.setItem("sessionId", player.sessionId)
          onLogin(player)
        }
      | Ok(UserError(err)) => setError(_ => Some(err))
      | Error(err) => setError(_ => Some(Jzon.DecodingError.toString(err)))
      }->resolve
    })
    |> catch(_ => resolve(ignore()))
    |> then_(_ => {
      setIsLoading(_ => false)
      resolve(ignore())
    })
    |> ignore
  }

  React.useEffect0(() => {
    let sessionId =
      LocalStorage.getItem("sessionId")->Js.Nullable.toOption->Option.getWithDefault("")

    if sessionId != "" {
      makeRequest("sessionId", sessionId)
    }

    None
  })

  let handleRegistrationClick = _ => makeRequest("playerId", login)

  <div className="m-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Authorization")} </Base.Heading>
    <span> {uiStr("Login:")} </span>
    {switch error {
    | Some(err) => <span> {uiStr(`Error: ${err}`)} </span>
    | _ => React.null
    }}
    <Base.Input
      disabled={isLoading} className="my-2" value={login} onChange={value => setLogin(_ => value)}
    />
    <Base.Button disabled={isLoading} onClick={handleRegistrationClick}>
      {uiStr("Register")}
    </Base.Button>
  </div>
}
