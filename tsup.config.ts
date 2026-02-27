import { name } from "./package.json";
import { defineConfig } from "tsup";

export default defineConfig({
  name,
  entry: ["src/index.ts"],
  format: ["cjs"],
  target: "node20",
  bundle: true,
  splitting: false,
  sourcemap: true,
  clean: true,
  noExternal: [/.*/],
  dts: {
    resolve: true,
  },
});
