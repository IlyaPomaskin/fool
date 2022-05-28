let default = () => {
  // FIXME remove debug code
  let isStarted = UseDebug.startServer()

  if !isStarted {
    <div> {React.string("Loading...")} </div>
  } else {
    <div className="flex flex-row flex-wrap w-full"> <PlayerScreen /> </div>
  }
}
