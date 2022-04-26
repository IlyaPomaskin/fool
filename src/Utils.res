let cx = (names: array<string>) => names->Array.reduce("", (acc, c) => acc ++ " " ++ c)

let uiList = (items: list<'a>, fn) => React.array(items->List.toArray->Array.map(fn))

let uiStr = (text: string) => React.string(text)

let noop = (_: 'a) => ()

let noop2 = (_: 'a, _: 'a1) => ()

let selected = "bg-slate-400"

let unselected = ""

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
