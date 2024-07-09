//@ts-expect-error codegen
import * as parser from "./parser.js";

export interface FLE {
    adif: {
        header: Header
        qso: QSO[]
    }
}
export interface Header {
    ADIF_VER: string
    APP_FLE_NICKNAME?: string
    PROGRAMID: string
}
export interface QSO {
    BAND: string
    CALL: string
    FREQ?: string
    GRIDSQUARE?: string
    MODE: string
    MY_GRIDSQUARE?: string
    NAME?: string
    QSLMSG?: string
    QSO_DATE: string
    RST_RECEIVED: string
    RST_SENT: string
    STATION_CALLSIGN: string
    TIME_ON: string
}

/**
 * Thrown by the parser when it encounters a syntax error.
 */
export class SyntaxError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "SyntaxError";
    }
}
/**
 * Parse an FLE input to its intermediate representation.
 *
 * @param input The FLE input to parse
 * @param name The file or other friendly name which produced the input
 *
 * @return The IR for the FLE log
 */
export function parse(input: string, name: string): FLE {
    try {
        return parser.parse(input, {grammarSource: name});
    }
    catch (e) {
        if (typeof (e as any).format === "function")
            throw new SyntaxError((e as any).format([{source: name, text: input}]));
        throw e;
    }
}

export * from "./adif.js";
