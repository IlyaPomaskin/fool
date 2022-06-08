let toResult = (a: option<'a>, b: 'b): result<'a, 'b> =>
  a->Option.map(MResult.makeOk)->Option.getWithDefault(Error(b))
