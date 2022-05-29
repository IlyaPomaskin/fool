let delay = (send, msg, ~timeout=100, ()) =>
  Promise.make((resolve, _) => Js.Global.setTimeout(() => resolve(. send(msg)), timeout)->ignore)

// let autologin = (~sendMessage, ~playerId, ~sessionId, ~gameId, ~isOwner=false, ()) => {
//   let (isLoaded, setIsLoaded) = React.useState(_ => false)

//   React.useEffect2(() => {
//     if !isLoaded {
//       open Promise

//       let delayM = delay(sendMessage)

//       if isOwner {
//         delayM(Login(sessionId), ())
//         ->then(() => delayM(Lobby(Create, playerId, ""), ()))
//         ->then(() => delayM(Lobby(Enter, playerId, gameId), ()))
//         ->then(() => delayM(Lobby(Ready, playerId, gameId), ()))
//         ->then(() => delayM(Lobby(Start, playerId, gameId), ~timeout=300, ()))
//         ->ignore
//       } else {
//         delayM(Login(sessionId), ())
//         ->then(() => delayM(Lobby(Enter, playerId, gameId), ~timeout=250, ()))
//         ->then(() => delayM(Lobby(Ready, playerId, gameId), ()))
//         ->ignore
//       }

//       setIsLoaded(_ => true)
//     }

//     None
//   }, (sendMessage, isLoaded))
// }
