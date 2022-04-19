let cx = (names: array<string>) => names->Array.reduce("", (acc, c) => acc ++ " " ++ c)

let uiList = (items: list<'a>, fn) => React.array(items->List.toArray->Array.map(fn))

let uiStr = (text: string) => React.string(text)
