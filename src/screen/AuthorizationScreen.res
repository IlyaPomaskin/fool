open Types
open Utils

@react.component
let make = (~onMessage) => {
  let (login, setLogin) = React.useState(_ => "")

  <div className="m-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Authorization")} </Base.Heading>
    <span> {uiStr("Login:")} </span>
    <Base.Input className="my-2" value={login} onChange={value => setLogin(_ => value)} />
    <Base.Button onClick={_ => onMessage(Register(login))}> {uiStr("Register")} </Base.Button>
  </div>
}
