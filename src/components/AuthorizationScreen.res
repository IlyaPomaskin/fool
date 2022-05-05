open Types
open Utils

@react.component
let make = (~onMessage) => {
  let (login, setLogin) = React.useState(_ => "")

  <div>
    <Base.Input className="m-2 mb-0" value={login} onChange={value => setLogin(_ => value)} />
    <Base.Button className="m-2" onClick={_ => onMessage(Register(login))}>
      {uiStr("normal")}
    </Base.Button>
  </div>
}
