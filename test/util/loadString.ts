import fs from "fs";

/**
 * Loads a string from a file; on failure, writes any error to standard error.
 *
 * @param path The path of the file to load from
 *
 * @return The contents of the file as a string
 */
export default function loadString(path: string): string {
    try {
        return fs.readFileSync(path).toString();
    }
    catch (e) {
        process.stderr.write(e);
        process.exit();
    }
}
