@val @scope("localStorage") external getItem: string => Js.Nullable.t<string> = "getItem"

@val @scope("localStorage") external setItem: (string, string) => unit = "setItem"

module SessionStorage = {
  @val @scope("sessionStorage") external getItem: string => Js.Nullable.t<string> = "getItem"
  @val @scope("sessionStorage") external setItem: (string, string) => unit = "setItem"
}
