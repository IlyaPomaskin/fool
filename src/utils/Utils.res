let cx = (names: array<string>) => names->Array.reduce("", (acc, c) => acc ++ " " ++ c)

let uiList = (items: list<'a>, fn) => items->List.toArray->Array.map(fn)->React.array

let uiReverseList = (items: list<'a>, fn) =>
  items->List.toArray->Array.map(fn)->Array.reverse->React.array

let uiListWithIndex = (items: list<'a>, fn) =>
  items->List.toArray->Array.mapWithIndex(fn)->React.array

let uiStr = (text: string) => React.string(text)

let noop = (_: 'a) => ()

let noop2 = (_: 'a, _: 'a1) => ()

let noop3 = (_: 'a, _: 'a1, _: 'a2) => ()

let equals = (a: 'a, b: 'b) => a == b

let toggleListItem = (list: list<'a>, item: 'a): list<'a> => {
  let hasItem = List.has(list, item, equals)

  if hasItem {
    List.keep(list, i => !equals(i, item))
  } else {
    List.add(list, item)
  }
}

let lastListItem = (list: list<'a>) => list->List.get(List.size(list) - 1)

let findInList = (list: list<'a>, fn: 'a => bool) =>
  List.reduce(list, None, (acc, item) => {
    switch (acc, fn(item)) {
    | (Some(_), _) => acc
    | (_, true) => Some(item)
    | _ => None
    }
  })

let identity = (a: 'a) => a

let rec numbersToEmoji = (number: int) =>
  switch number {
  | 0 => `0️⃣`
  | 1 => `1️⃣`
  | 2 => `2️⃣`
  | 3 => `3️⃣`
  | 4 => `4️⃣`
  | 5 => `5️⃣`
  | 6 => `6️⃣`
  | 7 => `7️⃣`
  | 8 => `8️⃣`
  | 9 => `9️⃣`
  | _ => numbersToEmoji(number / 10) ++ numbersToEmoji(mod(number, 10))
  }

module Classify = {
  type unknownType

  let constructorName: unknownType => string = %raw(`x => {
        if (x && 'constructor' in x && x.constructor.name) {
          return x.constructor.name;
        } 

        return "";
    }`)
}

let leftRotationClassName = "-rotate-12 -translate-x-1.5"
let rightRotationClassName = "rotate-12 translate-x-1.5"

let listIndexOf = (list, equalsFn) =>
  List.reduceWithIndex(list, None, (acc, item, index) => {
    if equalsFn(item) {
      Some(index)
    } else {
      acc
    }
  })

let isEmpty = list => List.length(list) == 0

let useStateValue = (initialValue: 'a) => {
  let (value, setValue) = React.useState(_ => initialValue)
  let handleSetValue = React.useCallback1(nextValue => setValue(_ => nextValue), [setValue])

  (value, handleSetValue)
}

@val external document: 'a = "document"

let getFullUrl = (~isWs=false, ()) => {
  let protocol = document["location"]["protocol"]
  let hostname = document["location"]["hostname"]
  let port = document["location"]["port"]
  let protocol = switch (isWs, protocol) {
  | (true, "https:") => "wss:"
  | (true, "http:") => "ws:"
  | _ => protocol
  }

  `${protocol}//${hostname}:${port}`
}

let any = (a: 'a) => Obj.magic(a)
