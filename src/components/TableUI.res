open Types
open Utils

@react.component
let make = (~className: string="", ~isCardDisabled: card => bool=_ => false, ~table: table) =>
  <div className={cx(["flex gap-1 flex-row", className])}>
    {table->uiList(((to, by)) => {
      let isDisabled = Option.isSome(by) || isCardDisabled(to)

      <div
        className="relative"
        key={Card.cardToString(to) ++ by->Option.map(Card.cardToString)->Option.getWithDefault("")}>
        {switch by {
        | Some(byCard) =>
          <div className="flex flex-col gap-1">
            <CardUI card={to} disabled={true} />
            <CardUI card={byCard} className="absolute opacity-0.5" disabled={true} />
          </div>
        | None =>
          <div className="flex flex-col gap-1">
            <CardUI card={to} disabled={isDisabled} />
            <CardDnd.Cards.DroppableContainer
              className={(~draggingOver: bool) =>
                cx([
                  "top-0",
                  "left-0",
                  "w-12 h-16",
                  draggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : "",
                ])}
              accept={_ => true}
              id={CardDnd.ContainerId.make(CardDnd.ToCard(to))}
              axis=Y
              lockAxis={true}>
              <div
                className={cx([
                  // "absolute",
                  "w-12 h-16",
                  "inline-block",
                  "transform-x-[-100%]",
                  "border rounded-md border-solid border-slate-500",
                ])}
              />
            </CardDnd.Cards.DroppableContainer>
          </div>
        }}
      </div>
    })}
  </div>
