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
