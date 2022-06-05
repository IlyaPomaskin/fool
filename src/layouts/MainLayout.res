@react.component
let make = (~children) => {
  let minWidth = ReactDOM.Style.make(~minWidth="20rem", ())
  <main style=minWidth className="s-full flex justify-center text-gray-900 font-base">
    children
  </main>
}
