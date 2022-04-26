open Types

let hasCards = (table: table) => table->List.length > 0

let isAllBeaten = (table: table) => {
  let isBeaten = table->List.every(((_, by)) => Option.isSome(by))

  hasCards(table) && isBeaten
}

let isMaximumCards = (table: table) => table->List.length === 6

let getFlatCards = (table: table) => {
  table
  ->List.map(((firstCard, secondCard)) => list{Some(firstCard), secondCard})
  ->List.flatten
  // remove keepMap?
  ->List.keepMap(Utils.identity)
}
