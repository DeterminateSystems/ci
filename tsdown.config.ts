import { defineConfig } from "tsdown";

export default defineConfig({
  name: "determinate-ci",
  entry: ["src/index.ts"],
  format: ["esm"],
  target: "node20",
  sourcemap: true,
  dts: {
    resolve: false,
  },
  clean: true,
});
