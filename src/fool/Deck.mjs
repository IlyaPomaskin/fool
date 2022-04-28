// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "./Card.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";

var suitsList = {
  hd: /* Spades */0,
  tl: {
    hd: /* Hearts */1,
    tl: {
      hd: /* Diamonds */2,
      tl: {
        hd: /* Clubs */3,
        tl: /* [] */0
      }
    }
  }
};

var ranksList = {
  hd: /* Six */0,
  tl: {
    hd: /* Seven */1,
    tl: {
      hd: /* Eight */2,
      tl: {
        hd: /* Nine */3,
        tl: {
          hd: /* Ten */4,
          tl: {
            hd: /* Jack */5,
            tl: {
              hd: /* Queen */6,
              tl: {
                hd: /* King */7,
                tl: {
                  hd: /* Ace */8,
                  tl: /* [] */0
                }
              }
            }
          }
        }
      }
    }
  }
};

function makeShuffled(param) {
  var suits = Belt_List.flatten(Belt_List.make(9, suitsList));
  var ranks = Belt_List.flatten(Belt_List.make(4, ranksList));
  return Belt_List.shuffle(Belt_List.reduce2(suits, ranks, /* [] */0, (function (acc, suit, rank) {
                    return Belt_List.add(acc, /* Visible */{
                                _0: [
                                  suit,
                                  rank
                                ]
                              });
                  })));
}

function dealCards(amount, deck) {
  var cardsToDeal = Belt_List.keepWithIndex(deck, (function (param, index) {
          return index <= (amount - 1 | 0);
        }));
  var nextDeck = Belt_List.keepWithIndex(deck, (function (param, index) {
          return index > (amount - 1 | 0);
        }));
  return [
          cardsToDeal,
          nextDeck
        ];
}

function removeCard(removedCard, deck) {
  return Belt_List.keep(deck, (function (card) {
                return !Card.isEquals(card, removedCard);
              }));
}

function getSmallestValuableCard(trump, deck) {
  return Belt_List.reduce(Belt_List.map(deck, (function (card) {
                    return card;
                  })), undefined, (function (prev, next) {
                var nextSmallestCard = Card.getSmallest(trump, prev, next);
                if (prev !== undefined) {
                  if (nextSmallestCard !== undefined) {
                    return nextSmallestCard;
                  } else {
                    return prev;
                  }
                } else if (nextSmallestCard !== undefined) {
                  return nextSmallestCard;
                } else {
                  return ;
                }
              }));
}

function isEmpty(deck) {
  return Belt_List.length(deck) === 0;
}

function mask(deck) {
  return Belt_List.map(deck, (function (param) {
                return /* Hidden */0;
              }));
}

function toObject(deck) {
  return Belt_List.toArray(Belt_List.map(deck, Card.cardToString));
}

export {
  suitsList ,
  ranksList ,
  makeShuffled ,
  dealCards ,
  removeCard ,
  getSmallestValuableCard ,
  isEmpty ,
  mask ,
  toObject ,
  
}
/* No side effect */
