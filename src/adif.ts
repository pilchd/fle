export type ADIFField = 
    | "ADIF_VER"
    | "APP_FLE_NICKNAME"
    | "BAND"
    | "CALL"
    | "FREQ"
    | "GRIDSQUARE"
    | "MODE"
    | "MY_GRIDSQUARE"
    | "MY_POTA_REF"
    | "NAME"
    | "OPERATOR"
    | "POTA_REF"
    | "PROGRAMID"
    | "QSLMSG"
    | "QSO_DATE"
    | "RST_SENT"
    | "RST_RECEIVED"
    | "STATION_CALLSIGN"
    | "TIME_ON"
export type ADIFObject = Partial<Record<ADIFField, string>>

/**
 * Export the ADIF fields/values in `object` as an ADI-compatible string.
 *
 * @example Formatting a simple object with the default configuration
 * ```ts
 * const object = {
 *     BAND: "20m",
 *     MODE: "SSB",
 * }
 * adifObject(object, "qso") === "<BAND:3>20m <MODE:3>SSB <EOR>"
 * ```
 *
 * @param object The `ADIFObject` to format
 * @param type The type of record being formatted; used for the header/record separator
 * @param config Options for the formatting style
 *
 * @return The ADI format for the object
 */
export function adiObject(object: ADIFObject, type: "header" | "record", config: {separator: string} = {separator: " "}): string {
    return Object.entries(object)
        .map(([key, value]) => (`<${key}:${value.length}>${value}`))
        .concat([`<EO${type === "header" ? 'H' : 'R'}>`])
        .join(config.separator)
}
