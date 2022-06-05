let default = () => {
  <div className="flex flex-row flex-wrap justify-items-center w-full container px-12 py-6 gap-12">
    <PlayerScreen sessionId={Some("s:p1")} gameId={Some("g1")} />
    <PlayerScreen sessionId={Some("s:p2")} gameId={Some("g1")} />
  </div>
}
