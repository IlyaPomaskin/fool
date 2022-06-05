import React from "react";
import dynamic from "next/dynamic";

const IndexResLazy = dynamic({
  loader: () => import("src/Index.mjs"),
  loading: () => <div>Index Loading...</div>,
  ssr: false,
  suspense: true,
});

export default function Index(props) {
  return <IndexResLazy {...props} />;
}
