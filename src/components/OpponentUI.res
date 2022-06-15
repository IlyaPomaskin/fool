open Types
open Utils

@react.component
let make = (~player, ~className, ~isDefender, ~isAttacker) => {
  <div className={cx(["flex flex-col gap-2", className])}>
    <StackUI.opponent deck={player.cards} />
    <div className="vertial-align">
      <PlayerUI.Short player className="inline-block" />
      {uiStr(isDefender ? ` 🛡️` : "")}
      {uiStr(isAttacker ? ` 🔪` : "")}
    </div>
  </div>
}
