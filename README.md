fle
===

*PEG parser for a superset of [DF3CB][1]'s Fast Log Entry 3*

Many established out-of-the-box solutions for manipulating FLE files exist; if you're only looking to process a log to
ADIF (perhaps for upload to Logbook of the World or similar), take them each for a spin and select your favorite.

| Tool                | Platform              | Frontend | Implemented in       | Source               |
| :-----------------  | :-------------------- | :------  | :------------------- | :------------------- |
| [Fast Log Entry][2] | Windows               | GUI      | ?                    | Closed               |
| [FLEcli][3]         | Windows, macOS, Linux | CLI      | Go                   | Open ([MIT][4])      |
| [sfle][5]           | Web                   | Web      | JavaScript           | Open ([AGPL-3.0][6]) |
| [fle-cli][7]        | Windows, macOS, Linux | CLI      | TypeScript (Node.js) | Open ([MIT][8])      |

*This table is maintained in good faith--if I've misrepresented your application or excluded it entirely, please reach
out!*

If you still need an extensible parser for your own implementation, read on!

[1]: https://df3cb.com
[2]: https://df3cb.com/fle
[3]: https://github.com/on4kjm/FLEcli
[4]: https://raw.githubusercontent.com/on4kjm/FLEcli/master/LICENSE "LICENSE"
[5]: https://github.com/ok2cqr/sfle
[6]: https://raw.githubusercontent.com/ok2cqr/sfle/main/LICENSE "LICENSE"
[7]: https://github.com/pilchd/fle-cli
[8]: https://github.com/pilchd/fle-cli/main/LICENSE.txt "LICENSE.txt"


Overview
--------

Fast Log Entry is DF3CB's implementation of his [specification][9]; the community's programs largely operate within
it and bring functionality to additional platforms.

While the original program and its community derivations are excellent, I wanted to add a few custom features (likely
outside the scope of existing implementations) on top of an extensible, grammar-based, cross-platform codebase. I do
this namely (for fun!) as a component of my own FLE implementation, [fle-cli][7], but the module aims to be generally
useful as a starting point for others looking to implement, extend, or integrate FLE.

[9]: https://df3cb.com/fle/documentation


Pre-`1.0.0` Tasks
-----------------

- [ ] Support any separators in **DATE**
- [ ] Support abbreviated **DATE**
- [ ] Support time interpolation
- [ ] Support `MY_SOTA_REF`
- [ ] Support `MY_WWFF_REF`
- [ ] Support contest logging
- [ ] Support consecutive serial numbers
- [ ] Annotate grammar rules
- [ ] Test cases `:)`


Installation
------------

`npm install @pilchd/fle`


Usage
-----

```js
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
```


API
---

TODO


Extensions to Fast Log Entry
----------------------------

- QSO data may be entered in any sequence (**CALL** need not immediately follow **TIME_ON**), except the following:

    - If entered, the time (**TIME_ON**) must precede the callsign (**CALL**)
    - If entered, any RST values (**RST_SENT**, **RST_RECEIVED**) must follow the callsign (**CALL**)

    | Valid in Fast Log Entry *and* fle | Valid *only* in fle              |
    | --------------------------------- | -------------------------------- |
    | `2023-12-01 20m SSB 1234 W1AW/1`  | `2023-12-01 1234 20m SSB W1AW/1` |

    This requirement (or one meeting a similar condition) is inherent to FLE: a time or its abbreviation (`59`) and a
    RST report (`59`) are indistinguishable.

- The **DAY** keyword may be followed by any quantity (including zero) of whitespace.

    | Valid in Fast Log Entry *and* fle | Valid *only* in fle |
    | --------------------------------- | ------------------- |
    | `day +++`                         | `day+++`            |


Contributing
------------

fle functions in more cases than Fast Log Entry, so the application does not aim for 100% compatibility. It strives to
meet the following standard:

- Any valid Fast Log Entry log is a valid fle log.
- Any invalid Fast Log Entry log, excluding the cases enumerated in [Extensions](#extensions-to-fast-log-entry), is an
  invalid fle log.

If you find an exception, please open an issue!


Glossary: Supported ADI Fields
------------------------------

```
ADIF_VER
APP_FLE_NICKNAME
BAND
CALL
FREQ
GRIDSQUARE
MODE
MY_GRIDSQUARE
MY_POTA_REF
NAME
OPERATOR
POTA_REF
PROGRAMID
QSLMSG
QSO_DATE
RST_SENT
RST_RECEIVED
STATION_CALLSIGN
TIME_ON
```
