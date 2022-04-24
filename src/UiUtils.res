let cx = (names: array<string>) => names->Array.reduce("", (acc, c) => acc ++ " " ++ c)

let uiList = (items: list<'a>, fn) => React.array(items->List.toArray->Array.map(fn))

let uiStr = (text: string) => React.string(text)

let noop = (_: 'a) => ()

let noop2 = (_: 'a, _: 'a1) => ()

let selected = "bg-slate-400"

let unselected = ""
