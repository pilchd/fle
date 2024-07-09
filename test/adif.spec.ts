import {assert} from "chai";

import * as globals from "./globals"

import {adiObject} from "../dist/index";
describe("adiObject", function() {

    it("formats header field ADIF_VER", function() {
        assert.deepEqual(adiObject({ADIF_VER: globals.ADIF_VER}, "header"),
            `<ADIF_VER:${globals.ADIF_VER.length}>${globals.ADIF_VER} <EOH>`
        );
    });

    it("formats header fields APP_FLE_NICKNAME, PROGRAMID", function() {
        assert.deepEqual(adiObject({APP_FLE_NICKNAME: "test", PROGRAMID: "fle"}, "header"),
            "<APP_FLE_NICKNAME:4>test <PROGRAMID:3>fle <EOH>"
        );
    });

    it("formats record fields BAND, FREQUENCY", function() {
        assert.deepEqual(adiObject({BAND: "20m", FREQ: "14.074"}, "record"),
            "<BAND:3>20m <FREQ:6>14.074 <EOR>"
        );
    });

});
