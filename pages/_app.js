import "../styles/main.css";

import ResApp from "src/App.mjs";

const SafeHydrate = ({ children }) => (
  <div suppressHydrationWarning>
    {typeof window === "undefined" ? null : children}
  </div>
);

export default function App(props) {
  return (
    <SafeHydrate>
      <ResApp {...props} />
    </SafeHydrate>
  );
}
