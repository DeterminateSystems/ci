import * as actionsCore from "@actions/core";
import * as actionsExec from "@actions/exec";
import { DetSysAction } from "detsys-ts";

//#region src/index.ts
const EVENT_EXECUTION_FAILURE = "execution_failure";
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
			env: { ...process.env },
			ignoreReturnCode: true
		});
		if (exitCode !== 0) {
			this.recordEvent(EVENT_EXECUTION_FAILURE, { exitCode });
			actionsCore.setFailed(`Non-zero exit code of \`${exitCode}\`.`);
		}
	}
	async post() {}
};
function main() {
	new DeterminateCi().execute();
}
main();

//#endregion
export {  };
//# sourceMappingURL=index.mjs.map