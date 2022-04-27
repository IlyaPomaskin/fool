open Types

let isEqualsBySuit = (card1: card, card2: card) =>
  switch (card1, card2) {
  | (Visible((suit1, _)), Visible(suit2, _)) => suit1 === suit2
  | _ => false
  }

let isEqualsByRank = (card1: card, card2: card) =>
  switch (card1, card2) {
  | (Visible((_, rank1)), Visible(_, rank2)) => rank1 === rank2
  | _ => false
  }

let isEquals = (first: card, second: card) =>
  isEqualsBySuit(first, second) && isEqualsByRank(first, second)

let ltByRank = (card1: card, card2: card) =>
  switch (card1, card2) {
  | (Visible((_, rank1)), Visible(_, rank2)) => rank1 < rank2
  | _ => false
  }

let gtByRank = (c1: card, c2: card) => !ltByRank(c1, c2)

let sortByRank = (first: card, second: card) => ltByRank(first, second) ? -1 : 1

let isTrump = (trump: suit, card: card) =>
  switch card {
  | Visible((suit, _)) => suit === trump
  | _ => false
  }

let getSmallest = (trump: suit, first: option<card>, second: option<card>) => {
  switch (first, second) {
  | (None, None) => None
  | (None, Some(_)) => second
  | (Some(_), None) => first
  | (Some(fst), Some(snd)) =>
    let isFstTrump = isTrump(trump, fst)
    let isSndTrump = isTrump(trump, snd)

    switch (isFstTrump, isSndTrump) {
    | (true, false) => first
    | (false, true) => second
    | _ => ltByRank(fst, snd) ? first : second
    }
  }
}

let isBeatByTrump = (to: card, by: card, trump: suit) => {
  !isTrump(trump, to) && isTrump(trump, by)
}

let isValidBeat = (to: card, by: card, trump: suit) => {
  switch (isTrump(trump, to), isTrump(trump, by)) {
  | (false, true) => true
  | (true, false) => false
  | (true, true) => ltByRank(to, by)
  | (false, false) => isEqualsBySuit(to, by) && ltByRank(to, by)
  }
}

let suitToString = (suit: suit) => {
  switch suit {
  | Spades => `♤`
  | Hearts => `♡`
  | Diamonds => `♢`
  | Clubs => `♧`
  }
}

let rankToString = (rank: rank) => {
  switch rank {
  | Six => "6"
  | Seven => "7"
  | Eight => "8"
  | Nine => "9"
  | Ten => "10"
  | Jack => "J"
  | Queen => "Q"
  | King => "K"
  | Ace => "A"
  }
}

let cardToString = (card: card) =>
  switch card {
  | Visible((suit, rank)) => suitToString(suit) ++ " " ++ rankToString(rank)
  | Hidden => "hidden"
  }
