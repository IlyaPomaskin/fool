let makeOk = (a: 'a) => Ok(a)

let mapError = (result: result<'a, 'b>, fn: 'b => 'c): result<'a, 'c> =>
  switch result {
  | Error(b) => Error(fn(b))
  | Ok(a) => Ok(a)
  }

let tap = (result: result<'a, 'b>, fn: 'a => unit): result<'a, 'b> => {
  Result.map(result, content => {
    fn(content)
    content
  })
}

let tapError = (result: result<'a, 'b>, fn: 'b => unit): result<'a, 'b> => {
  switch result {
  | Error(err) => fn(err)
  | _ => ignore()
  }

  result
}

let fold = (result: result<'a, 'b>, onOk: 'a => unit, onError: 'b => unit): unit => {
  switch result {
  | Ok(a) => onOk(a)
  | Error(b) => onError(b)
  }
}

let validate = (result, err, isInvalid) =>
  Result.flatMap(result, content =>
    if isInvalid(content) {
      Error(err)
    } else {
      Ok(content)
    }
  )
