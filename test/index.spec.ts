import {assert} from "chai";

import * as globals from "./globals"
import loadString from "./util/loadString";

import {parse} from "../dist/index";
describe("parse", function() {

    it("parses log 00", function() {
        assert.deepEqual(parse(loadString("./test/logs/00.txt"), "00"), {
            adif: {
                header: {
                    ADIF_VER: globals.ADIF_VER,
                    APP_FLE_NICKNAME: "Test Log 00",
                    PROGRAMID: "fle"
                },
                qso: [
                    {
                        BAND: "20m",
                        CALL: "W1AW/1",
                        GRIDSQUARE: "FN31",
                        MODE: "SSB",
                        NAME: "Maxim",
                        QSLMSG: "Test QSL Message",
                        QSO_DATE: "20231201",
                        RST_SENT: "55",
                        RST_RECEIVED: "59",
                        STATION_CALLSIGN: "W1AW",
                        TIME_ON: "1234"
                    },
                    {
                        BAND: "20m",
                        CALL: "W1AW/2",
                        MODE: "SSB",
                        QSLMSG: "Test Global QSL Message",
                        QSO_DATE: "20231201",
                        RST_SENT: "59",
                        RST_RECEIVED: "59",
                        STATION_CALLSIGN: "W1AW",
                        TIME_ON: "1234"
                    },
                    {
                        BAND: "20m",
                        CALL: "W1AW/3",
                        MODE: "SSB",
                        QSLMSG: "Test Global QSL Message",
                        QSO_DATE: "20231201",
                        RST_SENT: "57",
                        RST_RECEIVED: "59",
                        STATION_CALLSIGN: "W1AW",
                        TIME_ON: "1235"
                    },
                    {
                        BAND: "20m",
                        CALL: "W1AW/4",
                        MODE: "CW",
                        QSLMSG: "Test Global QSL Message",
                        QSO_DATE: "20231201",
                        RST_SENT: "535",
                        RST_RECEIVED: "597",
                        STATION_CALLSIGN: "W1AW",
                        TIME_ON: "1245"
                    }
                ]
            }
        });
    });

});
