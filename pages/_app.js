import React, { StrictMode } from "react";
import dynamic from "next/dynamic";

import "../styles/main.css";

const ResAppLazy = dynamic({
  loader: () => import("src/App.mjs"),
  loading: () => <div>App Loading...</div>,
  ssr: false,
  suspense: true,
});

export default function App(props) {
  return (
    <StrictMode>
      <ResAppLazy {...props} />
    </StrictMode>
  );
}
