// This example is available at `example/usage.js'.
import {adiObject, parse, SyntaxError} from "./dist/index";

// The parser accepts FLE as a string.
const fle1 = "mycall W1AW\n2023-12-01 20m SSB 1234 W1AW/1\nW1AW/2\n";
const fle2 = ["mycall W1AW", "2023-12-01 20m SSB 1234 W1AW", "W1AW/2"].join('\n');

try {
    // It returns the ADIF header and record fields as objects, one per header (1) and QSO (1+).
    // Object keys are ADIF 3.1.4 field names; object values are valid data for those fields.
    parse(fle1, "fle1").adif.header.ADIF_VER === "3.1.4"
    parse(fle2, "fle2").adif.qso[0].TIME_ON === "1234"
    parse(fle2, "fle2").adif.qso[1].CALL === "W1AW/2"
}
catch (e) {
    // It detects one syntax error at a time and throws it with a friendly error message.
    if (e instanceof SyntaxError) {
        console.log(e.message);
        process.exit();
    }
    else {
        throw e;
    }
}

// A simple utility function is included to format these objects in ADI.
console.log(adiObject(parse(fle2, "fle2").adif.qso[0], "record"));
// The ordering is dependent on the parse, but contains no more than the following:
// <STATION_CALLSIGN:4>W1AW <QSO_DATE:8>20231201 <BAND:3>20m <MODE:3>SSB
// <TIME_ON:4>1234 <CALL:6>W1AW/1 <RST_SENT:2>59 <RST_RECEIVED:2>59 <EOR>

// Accordingly, a complete FLE implementation to process `fle2` is as simple as follows.
console.log(adiObject(parse(fle2, "fle2").adif.header, "header"));
parse(fle2, "fle2").adif.qso.forEach(qso => console.log(adiObject(qso, "record")));
