import { logError } from "./handle-error.ts";

export const main = async () => {
    const fileContent = await Deno.readTextFile("./readable-file.txt");
    
    // Try to list parent directory (will fail due to sandbox)
    let directoryInfo = "";
    try {
        const entries = [];
        for await (const entry of Deno.readDir("..")) {
            entries.push(entry.name);
        }
        directoryInfo = `\n[SANDBOX BROKEN] This should never happen! Also found these files: ${entries.join(", ")}`;
    } catch (error) {
        logError(error);
    }
    
    return fileContent + directoryInfo;
};
