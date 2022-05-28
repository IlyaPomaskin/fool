let cx = (names: array<string>) => names->Array.reduce("", (acc, c) => acc ++ " " ++ c)

let uiList = (items: list<'a>, fn) => items->List.toArray->Array.map(fn)->React.array

let uiReverseList = (items: list<'a>, fn) =>
  items->List.toArray->Array.map(fn)->Array.reverse->React.array

let uiListWithIndex = (items: list<'a>, fn) =>
  items->List.toArray->Array.mapWithIndex(fn)->React.array

let uiStr = (text: string) => React.string(text)

let noop = (_: 'a) => ()

let noop2 = (_: 'a, _: 'a1) => ()

let equals = (a: 'a, b: 'b) => a == b

let toggleArrayItem = (list: list<'a>, item: 'a): list<'a> => {
  let hasItem = List.has(list, item, equals)

  if hasItem {
    List.keep(list, i => !equals(i, item))
  } else {
    List.add(list, item)
  }
}

let lastListItem = (list: list<'a>) => list->List.get(List.size(list) - 1)

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

let makeOk = (a: 'a) => Ok(a)

let toResult = (a: option<'a>, error: 'b): result<'a, 'b> =>
  a->Option.map(makeOk)->Option.getWithDefault(Error(error))

module Classify = {
  type unknownType

  let constructorName: unknownType => string = %raw(`x => {
        if (x && 'constructor' in x && x.constructor.name) {
          return x.constructor.name;
        } 

        return "";
    }`)
}

let tapResult = (result: result<'a, 'b>, fn: 'a => unit): result<'a, 'b> => {
  Result.map(result, content => {
    fn(content)
    content
  })
}

let tapErrorResult = (result: result<'a, 'b>, fn: 'b => unit): result<'a, 'b> => {
  switch result {
  | Error(err) => fn(err)
  | _ => ignore()
  }

  result
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
