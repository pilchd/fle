{
    const ADIF_VER = "3.1.4";
    const PROGRAMID = "fle";

    const state = {
        // Last-read values for stateful ADIF types
        type: {
            Time: null
        },

        // Last-read values for stateful ADIF fields
        adif: {
            BAND: null,
            // FREQ: undefined,
            MODE: null,
            // SUBMODE: undefined
            // MY_GRIDSQUARE: undefined,
            // MY_POTA_REF: undefined,
            // OPERATOR: undefined,
            // QSLMSG: undefined,
            QSO_DATE: null,
            // STATION_CALLSIGN: undefined,
            TIME_ON: null
        },

        // ADIF fields read so far in a QSO entry
        read: {
            CALL: false,
            RST_SENT: false,
            RST_RECEIVED: false
        }
    }
}


FLE
    = _n* header:HEADER_ENTRIES _n* qso:QSO_ENTRIES _n* {
        return {
            adif: {
                header: header,
                qso: qso
            }
        };
    }

HEADER_ENTRIES
    = entries:HEADER_ENTRY|1.., n+| {
        const entry = buildArrObj(entries);
        if (typeof entry === "string")
            error(`Ambiguous value for ${entry} in header`)

        return entry.APP_FLE_NICKNAME ? {
            ADIF_VER,
            PROGRAMID,
            APP_FLE_NICKNAME: entry.APP_FLE_NICKNAME
        } : {
            ADIF_VER,
            PROGRAMID
        }
    }

QSO_ENTRIES
	= qsos:QSO_ENTRY|.., n+| {return qsos.filter(qso => qso)}

HEADER_ENTRY
    = A_APP_FLE_NICKNAME
    / A_MY_GRIDSQUARE
    / A_MY_POTA_REF
    / A_OPERATOR
    / A_QSLMSG_HEADER
    / A_STATION_CALLSIGN
    / COMMENT {
        return {}
    }


QSO_ENTRY
    = _* qso:QSO_FIELD|1.., _+| _* {
        state.read.CALL = false;
        state.read.RST_SENT = false;
        state.read.RST_RECEIVED = false;

        const entry = buildArrObj(qso);
        if (typeof entry === "string")
            error(`Ambiguous value for ${entry} in QSO`);

        // This line does not encode a QSO
        if (!entry.CALL) return null;

        qso = {
            ...state.adif,
            ...entry
        }

        if (!qso.BAND && !qso.FREQ) {
            error("Must infer band, but no band or frequency known");
        }
        if (!qso.BAND && qso.FREQ) {
            qso.BAND = inferBand(qso.FREQ)
                || error("Couldn't infer band from frequency ${qso.FREQ} MHz");
        }
        if (qso.BAND && qso.FREQ && qso.BAND !== inferBand(qso.FREQ)) {
            error(`Band/frequency mismatch (band ${qso.BAND}, freq ${qso.FREQ} MHz)`);
        }

        ["RST_SENT", "RST_RECEIVED"].forEach(rst => {
            const def = generateRst(qso.MODE);
            // Apply the default RST for the mode if there isn't one
            qso[rst] ||= def.rst;
            // Extend any RST we can from the right to the length of its default
            if (def.category !== "digi")
                qso[rst] = qso[rst].padStart(def.rst.length, def.rst);
        });

        //CLEAR STATE

        return qso;
    }
    / COMMENT {
        return null;
    }

QSO_FIELD
    = A_GRIDSQUARE
    / A_NAME
    / A_POTA_REF
    / A_QSLMSG
    / DAY

    / A_BAND
    / A_MODE
    / A_QSO_DATE
    / A_FREQ
    / A_CALL
    / A_RST
    / A_TIME_ON

COMMENT
    = '#' [^\n]*

DAY
    = _* "day"i _* plus:'+'+ {
        if (!state.adif.QSO_DATE)
            error("Cannot increment day before date");

        const d = state.adif.QSO_DATE
        const D = new Date(`${d.slice(0, 4)}-${d.slice(4, 6)}-${d.slice(7, 9)}`);
        D.setUTCDate(D.getUTCDate() + plus.length);
        state.adif.QSO_DATE = D.toISOString().slice(0, 10).replace(/-/g, "");

        return {};
    }
