import harperConfig from "@harperdb/code-guidelines/eslint";
import { defineConfig } from "eslint/config";

export default defineConfig([
  ...harperConfig,
  // Your custom configuration here
  {
    rules: {
      // Override or add custom rules
    },
  },
]);
