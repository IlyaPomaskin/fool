open NodeJs

let getCookies = req => {
  Http.IncomingMessage.headers(req).cookie
  ->Option.map(cookie =>
    String.split_on_char(';', cookie)
    ->List.map(String.split_on_char('='))
    ->List.map(cookie => cookie->List.map(String.trim))
    ->List.map(keyValue => (keyValue->List.get(0), keyValue->List.get(1)))
    ->List.reduce(Map.String.empty, (acc, (key, value)) =>
      switch (key, value) {
      | (Some(key), Some(value)) => acc->Map.String.set(key, value)
      | _ => acc
      }
    )
  )
  ->Option.getWithDefault(Map.String.empty)
}

let getUrl = (req, protocol) =>
  Some(req)
  ->Option.map(Http.IncomingMessage.headers)
  ->Option.flatMap(headers => headers.host)
  ->Option.map(host =>
    Url.fromBaseString(~input=Http.IncomingMessage.url(req), ~base=`${protocol}://${host}`)
  )

let getSearchParams = (url: option<NodeJs.Url.t>) =>
  url
  ->Option.map(url => url.search)
  ->Option.map(search => Js.String.sliceToEnd(~from=1, search))
  ->Option.map(search => QueryString.decode(search))
  ->Option.getWithDefault(Js.Dict.empty())

let getParam = (params: Js.Dict.t<string>, name) =>
  params
  ->Js.Dict.get(name)
  ->Option.map(value =>
    switch Js.Array.isArray(value) {
    | true => Js.Array.joinWith("", value->Obj.magic)
    | false => value
    }
  )
