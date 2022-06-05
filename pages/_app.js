import React, { StrictMode } from "react";
import ResApp from "src/App.mjs";

import "../styles/main.css";

export default function App(props) {
  return (
    <StrictMode>
      <ResApp {...props} />
    </StrictMode>
  );
}
