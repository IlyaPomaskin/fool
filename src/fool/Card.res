open Types

let isEqualsBySuit = ((s1, _): card, (s2, _): card) => s1 === s2

let isEqualsByRank = ((_, r1): card, (_, r2): card) => r1 === r2

let isEquals = (first: card, second: card) =>
  isEqualsBySuit(first, second) && isEqualsByRank(first, second)

let ltByRank = ((_, r1): card, (_, r2): card) => r1 < r2
let gtByRank = (c1: card, c2: card) => !ltByRank(c1, c2)

let sortByRank = (first: card, second: card) => ltByRank(first, second) ? -1 : 1

let isTrump = (trump: suit, (suit, _): card) => trump === suit

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
  fst(to) != trump && fst(by) == trump
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

let cardToString = ((s, r): card) => suitToString(s) ++ " " ++ rankToString(r)
