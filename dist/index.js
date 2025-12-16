// src/index.ts
import * as actionsCore from "@actions/core";
import * as actionsExec from "@actions/exec";
import { DetSysAction } from "detsys-ts";
var EVENT_EXECUTION_FAILURE = "execution_failure";
var DeterminateCi = class extends DetSysAction {
  constructor() {
    super({
      name: "flake-iter",
      fetchStyle: "gh-env-style",
      diagnosticsSuffix: "telemetry",
      requireNix: "fail"
    });
  }
  async main() {
    const binaryPath = await this.fetchExecutable();
    const exitCode = await actionsExec.exec(binaryPath, [], {
      // To get $FLAKE_ITER_RUNNER_MAP or $FLAKE_ITER_NIX_SYSTEM (depending on workflow step)
      env: process.env,
      ignoreReturnCode: true
    });
    if (exitCode !== 0) {
      this.recordEvent(EVENT_EXECUTION_FAILURE, {
        exitCode
      });
      actionsCore.setFailed(`Non-zero exit code of \`${exitCode}\`.`);
    }
  }
  // No post step
  async post() {
  }
};
function main() {
  new DeterminateCi().execute();
}
main();
//# sourceMappingURL=index.js.map