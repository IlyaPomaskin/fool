let hasCards = table => table->List.length > 0

let isAllBeaten = table => {
  let isBeaten = table->List.every(((_, by)) => Option.isSome(by))

  hasCards(table) && isBeaten
}

let isMaximumCards = table => table->List.length === 6

let getFlatCards = table => {
  table
  ->List.map(((firstCard, secondCard)) => list{Some(firstCard), secondCard})
  ->List.flatten
  // remove keepMap?
  ->List.keepMap(Utils.identity)
}

let getUnbeatedCards = table =>
  table->List.keep(((_, by)) => Option.isNone(by))->List.map(((to, _)) => to)

let toObject = table =>
  table
  ->List.map(((to, by)) => [
    Card.cardToString(to),
    by->Option.map(Card.cardToString)->Option.getWithDefault("None"),
  ])
  ->List.toArray
