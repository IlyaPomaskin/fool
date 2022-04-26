open Utils

module Button = {
  @react.component
  let make = (
    ~disabled: bool=false,
    ~pressed: bool=false,
    ~className: string="",
    ~onClick: ReactEvent.Mouse.t => unit=noop,
    ~children: React.element,
  ) => {
    <button
      disabled
      className={cx([
        className,
        "p-1 border rounded-md border-solid border-slate-500 bg-slate-100 shadow-sm hover:shadow-md",
        pressed ? selected : "",
        disabled
          ? "border-slate-400 text-slate-400 cursor-not-allowed shadow-none hover:shadow-none"
          : "",
      ])}
      onClick>
      children
    </button>
  }
}
