// A_T_ derivations match *A*DIF data *t*ypes as they are written in FLE. Their
// translations return strings compatible with the corresponding type.

A_T_Digit
    = [0123456789]

// TODO only allowed decimals (freqs) and pad/trunc to 3
A_T_Number
    = number:$(A_T_Digit+ '.' $A_T_Digit|0..3|) {
        return number;
    }

// ' ' (ASCII 32) is excluded, as it is the IFS in FLE
// '<'/'>', '{'/'}', '#'
A_T_Character
    = [!"$%&'()*+,\-./0-9:;=?@A-Z\[\\\]^_`a-z|~]

A_T_Date
    = year:A_T_Date_Y "-" month:A_T_Date_M "-" day:A_T_Date_D {
        return `${year}${month}${day}`
    }
A_T_Date_Y
    = $("19" [3-9] [0-9])
    / $("20" [0-9] [0-9])
A_T_Date_M
    = $("0" [1-9])
    / $("1" [0-2])
A_T_Date_D
    = $("0" [1-9])
    / $([1-2] [0-9])
    / $("3" [0-1])

A_T_Time
	= time:A_T_Time_ {
        if (!state.type.time && time.length !== 4)
            error("Must extrapolate time, but no time is known");
        state.type.time = time.padStart(4, state.type.time);
        return state.type.time;
    }
A_T_Time_
    = $("2"   [0-3] [0-5] [0-9])
    / $([0-1] [0-9] [0-5] [0-9])
    / $([0-9] [0-5] [0-9])
    / $([0-5] [0-9])
    / $([0-9])

A_T_String
    = $(A_T_Character / " ")+

A_T_MultilineString
    = $(A_T_Character / " " / n)+

// Not an ADIF type; used in place of String where the IFS is meaningful to FLE
A_T_ContiguousString
    = $(A_T_Character)+

A_T_E_Band
    = band:A_T_E_Band_ {
        return band.toLowerCase()
    }
A_T_E_Band_
    = "2190m"i
    / "630m"i
    / "560m"i
    / "160m"i
    / "80m"i
    / "60m"i
    / "40m"i
    / "30m"i
    / "20m"i
    / "17m"i
    / "15m"i
    / "12m"i
    / "10m"i
    / "8m"i
    / "6m"i
    / "5m"i
    / "4m"i
    / "2m"i
    / "1.25m"i
    / "70cm"i
    / "33cm"i
    / "23cm"i
    / "13cm"i
    / "9cm"i
    / "6cm"i
    / "3cm"i
    / "1.25cm"i
    / "6mm"i
    / "4mm"i
    / "2.5mm"i
    / "2mm"i
    / "1mm"i
    / "submm"i

A_T_E_Mode
    = mode:A_T_E_Mode_ {
        return mode.toUpperCase()
    }
A_T_E_Mode_
    = "AM"i
    / "ARDOP"i
    / "ATV"i
    / "CHIP"i
    / "CLO"i
    / "CONTESTI"i
    / "CW"i
    / "DIGITALVOICE"i
    / "DOMINO"i
    / "DYNAMIC"i
    / "FAX"i
    / "FM"i
    / "FSK441"i
    / "FT8"i
    / "HELL"i
    / "ISCAT"i
    / "JT4"i
    / "JT6M"i
    / "JT9"i
    / "JT44"i
    / "JT65"i
    / "MFSK"i
    / "MSK144"i
    / "MT63"i
    / "OLIVIA"i
    / "OPERA"i
    / "PAC"i
    / "PAX"i
    / "PKT"i
    / "PSK"i
    / "PSK2K"i
    / "Q15"i
    / "QRA64"i
    / "ROS"i
    / "RTTY"i
    / "RTTYM"i
    / "SSB"i
    / "SSTV"i
    / "T10"i
    / "THOR"i
    / "THRB"i
    / "TOR"i
    / "V4"i
    / "VOI"i
    / "WINMOR"i
    / "WSPR"i

    // Aliases for submodes handled by A_MODE (non-spec)
    / "JS8"i

A_T_GridSquare
    = $([A-Ra-r]|2..2| [0-9]|2..2| [A-Xa-x]|2..2| [0-9]|2..2|)
    / $([A-Ra-r]|2..2| [0-9]|2..2| [A-Xa-x]|2..2|)
    / $([A-Ra-r]|2..2| [0-9]|2..2|)
    / $([A-Ra-r]|2..2|)

A_T_POTARef
    // TODO Support @yyyyyy (ISO 3166-2)
    = $([A-Za-z]|1..4| "-" [0-9]|4..5|)


// A_ derivations match *A*DIF fields as they are written in FLE (by including
// a match on an ADIF data type). Their translations return a {key: value}
// object containing the name of the ADIF field and its value.

A_APP_FLE_NICKNAME
    = "nickname"i _ APP_FLE_NICKNAME:A_T_String {
        return {APP_FLE_NICKNAME};
    }

A_BAND
    = BAND:A_T_E_Band {
        state.adif.BAND = BAND;
        return {BAND};
    }

A_CALL
    = CALL:A_T_ContiguousString &{return /[A-Za-z]/.test(CALL) && /[0-9]/.test(CALL);} {
        state.read.CALL = true;
        return {CALL};
    }

A_FREQ
    = FREQ:A_T_Number {
        state.adif.FREQ = FREQ;
        return {FREQ};
    }

A_GRIDSQUARE
    = '#' GRIDSQUARE:A_T_GridSquare {
        state.read.GRIDSQUARE = true;
        return {GRIDSQUARE};
    }

A_MODE
    = MODE:A_T_E_Mode {
        switch (MODE) {
            case "JS8":
                state.adif.MODE = "MFSK";
                state.adif.SUBMODE = "JS8";
                return {MODE: "MFSK", SUBMODE: "JS8"};
            default:
                state.adif.MODE = MODE;
                delete state.adif.SUBMODE;
                return {MODE};
        }
    }

A_MY_GRIDSQUARE
    = "mygrid"i _ MY_GRIDSQUARE:A_T_GridSquare {
        state.adif.MY_GRIDSQUARE = MY_GRIDSQUARE;
        return {MY_GRIDSQUARE};
    }

A_MY_POTA_REF
    = "mypota"i _ MY_POTA_REF:A_T_POTARef {
        state.adif.MY_POTA_REF = MY_POTA_REF;
        return {MY_POTA_REF};
    }

A_NAME
    = '@' NAME:A_T_ContiguousString {
        return {NAME};
    }

A_OPERATOR
    = "operator"i _ OPERATOR:A_T_ContiguousString {
    	return {OPERATOR};
    }

A_POTA_REF
    = "pota"i _ POTA_REF:A_T_POTARef {
        return {POTA_REF};
    }

A_QSLMSG_HEADER
    = "qslmsg"i _ QSLMSG:A_T_String {
        state.adif.QSLMSG = QSLMSG;
        return {QSLMSG};
    }

A_QSLMSG
    = '<' QSLMSG:A_T_String '>' {
        return {QSLMSG};
    }

A_QSO_DATE
    = ("date"i _)? QSO_DATE:A_T_Date {
        state.adif.QSO_DATE = QSO_DATE;
        return {QSO_DATE};
    }

A_RST
    = rst:A_T_ContiguousString &{return state.read.CALL} {
        options.debug && console.log(`A_RST: ${rst}`);
        switch (state.read.RST_SENT + state.read.RST_RECEIVED) {
            case 0:
                state.read.RST_SENT = true;
                return {RST_SENT: rst};
            case 1:
                state.read.RST_RECEIVED = true;
                return {RST_RECEIVED: rst};
            case 2:
                error("Too many RST reports (read \"${rst}\")");
        }
    }

A_STATION_CALLSIGN
    = "mycall"i _ STATION_CALLSIGN:A_T_ContiguousString {
        state.adif.STATION_CALLSIGN = STATION_CALLSIGN;
        return {STATION_CALLSIGN};
    }

A_TIME_ON
    = TIME_ON:A_T_Time {
        options.debug && console.log(`A_TIME_ON: ${TIME_ON}`);
        state.adif.TIME_ON = TIME_ON;
        return {TIME_ON};
    }
