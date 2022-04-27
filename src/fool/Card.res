open Types

let isEqualsBySuit = (card1, card2) =>
  switch (card1, card2) {
  | (Visible((suit1, _)), Visible(suit2, _)) => suit1 === suit2
  | _ => false
  }

let isEqualsByRank = (card1, card2) =>
  switch (card1, card2) {
  | (Visible((_, rank1)), Visible(_, rank2)) => rank1 === rank2
  | _ => false
  }

let isEquals = (card1, card2) => isEqualsBySuit(card1, card2) && isEqualsByRank(card1, card2)

let ltByRank = (card1, card2) =>
  switch (card1, card2) {
  | (Visible((_, rank1)), Visible(_, rank2)) => rank1 < rank2
  | _ => false
  }

let gtByRank = (card1, card2) => !ltByRank(card1, card2)

let sortByRank = (card1, card2) => ltByRank(card1, card2) ? -1 : 1

let isTrump = (trump, card) =>
  switch card {
  | Visible((suit, _)) => suit === trump
  | _ => false
  }

let getSmallest = (trump, card1, card2) => {
  switch (card1, card2) {
  | (None, None) => None
  | (None, Some(_)) => card2
  | (Some(_), None) => card1
  | (Some(fst), Some(snd)) =>
    let isFstTrump = isTrump(trump, fst)
    let isSndTrump = isTrump(trump, snd)

    switch (isFstTrump, isSndTrump) {
    | (true, false) => card1
    | (false, true) => card2
    | _ => ltByRank(fst, snd) ? card1 : card2
    }
  }
}

let isBeatByTrump = (to, by, trump) => {
  !isTrump(trump, to) && isTrump(trump, by)
}

let isValidBeat = (to, by, trump) => {
  switch (isTrump(trump, to), isTrump(trump, by)) {
  | (false, true) => true
  | (true, false) => false
  | (true, true) => ltByRank(to, by)
  | (false, false) => isEqualsBySuit(to, by) && ltByRank(to, by)
  }
}

let suitToString = suit => {
  switch suit {
  | Spades => `♤`
  | Hearts => `♡`
  | Diamonds => `♢`
  | Clubs => `♧`
  }
}

let rankToString = rank => {
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

let cardToString = card =>
  switch card {
  | Visible((suit, rank)) => suitToString(suit) ++ " " ++ rankToString(rank)
  | Hidden => "hidden"
  }
