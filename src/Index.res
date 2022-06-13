let default = () => {
  <div
    className="select-none flex flex-row flex-wrap justify-items-center w-full container px-12 py-6 gap-12">
    <ReactDnd.Provider.makeTouch
      backend={ReactDnd.Backend.touch}
      options={ReactDnd.Provider.makeOptions(
        ~enableTouchEvents=true,
        ~enableMouseEvents=true,
        ~ignoreContextMenu=true,
        (),
      )}>
      <PlayerScreen sessionId={Some("s:p1")} gameId={Some("g1")} />
      <PlayerScreen sessionId={Some("s:p2")} gameId={Some("g1")} />
    </ReactDnd.Provider.makeTouch>
  </div>
}
