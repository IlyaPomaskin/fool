open Utils

module Heading = {
  type size =
    | H2
    | H3
    | H4
    | H5

  @react.component
  let make = (~className: string="", ~size: size, ~children: React.element) => {
    let sizeClassName = switch size {
    | H2 => "text-4xl"
    | H3 => "text-3xl"
    | H4 => "text-2xl"
    | H5 => "text-xl"
    }

    <h1 className={cx(["font-medium leading-tight", sizeClassName, className])}> children </h1>
  }
}

module Button = {
  @react.component
  let make = (
    ~disabled: bool=false,
    ~className: string="",
    ~onClick: ReactEvent.Mouse.t => unit=noop,
    ~children: React.element,
  ) => {
    <button
      disabled
      type_="button"
      className={cx([
        className,
        "inline-block px-6 py-2.5",
        "bg-blue-600 text-white font-medium text-xs leading-tight uppercase",
        "rounded shadow-md",
        "transition duration-150 ease-in-out",
        disabled
          ? "opacity-60"
          : "hover:bg-blue-700 hover:shadow-lg focus:bg-blue-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-blue-800 active:shadow-lg",
      ])}
      onClick>
      children
    </button>
  }
}

module Switch = {
  @react.component
  let make = (
    ~disabled: bool=false,
    ~checked: bool,
    ~onClick: ReactEvent.Form.t => unit,
    ~text: string,
    ~className: string="",
  ) => {
    let uniqId = React.useMemo0(() => string_of_int(Js.Math.random_int(0, 10000000)))

    <div className={cx(["form-check form-switch", className])}>
      <input
        disabled
        checked
        onChange={onClick}
        className={cx([
          "form-check-input appearance-none w-9 -ml-10 loat-left h-5 align-top",
          "rounded-full f",
          "bg-white bg-no-repeat bg-contain bg-gray-300",
          "focus:outline-none shadow-sm",
          disabled ? "filter-none opacity-50" : "",
        ])}
        type_="checkbox"
        role="switch"
        id={"switch-" ++ uniqId}
      />
      <label
        disabled
        className={cx([
          "ml-2 form-check-label cursor-pointer inline-block text-gray-800 select-none",
          disabled ? "opacity-50" : "",
        ])}
        htmlFor={"switch-" ++ uniqId}>
        {uiStr(text)}
      </label>
    </div>
  }
}

module Input = {
  @react.component
  let make = (~value: string, ~onChange: string => unit, ~className: string="") =>
    <input
      value
      onChange={e => onChange(ReactEvent.Form.target(e)["value"])}
      type_="text"
      className={cx([
        "form-control block px-3 py-1.5",
        "text-base font-normal text-gray-700",
        "bg-white bg-clip-padding",
        "border border-solid border-gray-300 rounded",
        "transition ease-in-out",
        "focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none",
        className,
      ])}
    />
}
