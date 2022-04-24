let toggleArrayItem = (list: list<'a>, item: 'a): list<'a> => {
  let hasItem = List.has(list, item, (first, second) => first === second)

  if hasItem {
    List.keep(list, i => i !== item)
  } else {
    List.add(list, item)
  }
}

let equals = (a: 'a, b: 'b) => a == b
