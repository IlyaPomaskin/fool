open Types

type useBeatCardReturn = {
  toBeat: option<card>,
  beatBy: option<card>,
  setBeat: (((option<card>, option<card>)) => (option<card>, option<card>)) => unit,
  handleSelectToBeat: (bool, card) => unit,
}

let hook = (~game: inProgress, ~player: player): useBeatCardReturn => {
  let ((toBeat, beatBy), setBeat) = React.useState(() => (None, None))
  let handleSelectToBeat = (isToCard: bool, card: card) => {
    setBeat(((toBeat, beatBy)) => {
      if isToCard {
        let isSame = toBeat->Option.map(Utils.equals(card))->Option.getWithDefault(false)

        isSame ? (None, beatBy) : (Some(card), beatBy)
      } else {
        let isSame = beatBy->Option.map(Utils.equals(card))->Option.getWithDefault(false)

        isSame ? (toBeat, None) : (toBeat, Some(card))
      }
    })
  }

  let isDefender = GameUtils.isDefender(game, player)

  React.useEffect1(() => {
    if !isDefender {
      setBeat(_ => (None, None))
    }

    None
  }, [isDefender])

  {
    toBeat: toBeat,
    beatBy: beatBy,
    setBeat: setBeat,
    handleSelectToBeat: handleSelectToBeat,
  }
}
