{{
    /**
     * Build a single object with unique keys from a list of objects.
     *
     * @example
     * buildArrObj([{alpha: "A"}, {bravo: "B", charlie: "C"}]):
     *     {alpha: "A", bravo: "B", charlie: "C"}
     *
     * @param array The array of objects to build from
     *
     * @return An object with no duplicate keys or the string name of the
     * first-encountered duplicate key
     */
    function buildArrObj(array) {
        let duplicate = null;
        const object = array.reduce((accumulator, currentValue) => {
            Object.keys(accumulator).forEach(element => {
                if (Object.keys(currentValue).includes(element))
                    duplicate ||= element;
            })

            return {...accumulator, ...currentValue};
        })

        return duplicate || object;
    }

    /**
     * Given a string representing an amateur frequency, infer its band.
     *
     * @return The ADIF-compatible band for a frequency; null if invalid.
     */
     function inferBand(frequencyString) {
        const bands = [
            "2190m",
            "630m",
            "560m",
            "160m",
            "80m",
            "60m",
            "40m",
            "30m",
            "20m",
            "17m",
            "15m",
            "12m",
            "10m",
            "8m",
            "6m",
            "5m",
            "4m",
            "2m",
            "1.25m",
            "70cm",
            "33cm",
            "23cm",
            "13cm",
            "9cm",
            "6cm",
            "3cm",
            "1.25cm",
            "6mm",
            "4mm",
            "2.5mm",
            "2mm",
            "1mm",
            "submm"
        ]
        const bounds = {
            lower: [
                .1357,
                .472,
                .501,
                1.8,
                3.5,
                5.06,
                7.0,
                10.1,
                14.0,
                18.068,
                21.0,
                24.890,
                28.0,
                40.,
                50.,
                54.000001,
                70.,
                144.,
                222.,
                420.,
                902.,
                1240.,
                2300.,
                3300.,
                5650.,
                10000.,
                24000.,
                47000.,
                75500.,
                119980.,
                134000.,
                241000.,
                300000.
            ],
            upper: [
                .1378,
                .479,
                .504,
                2.0,
                2.0,
                5.45,
                7.3,
                10.15,
                14.35,
                18.168,
                21.45,
                24.99,
                29.7,
                45.,
                54.,
                69.9,
                71.,
                148.,
                225.,
                450.,
                928.,
                1300.,
                2450.,
                3500.,
                5925.,
                10500.,
                24250.,
                47200.,
                81000.,
                123000.,
                149000.,
                250000.,
                7500000.
            ]
        }

        const frequency = parseFloat(frequencyString);
        for (let idx = 0; idx != bands.length; ++idx) {
            if (bounds.lower[idx] <= frequency && frequency <= bounds.upper[idx])
                return bands[idx];
        }

        return null;
    }

    /**
     * Given a mode, determine its category and default RST.
     *
     * @param mode A member of the ADIF MODE enumeration
     *
     * @return The category ["phone", "cw", "digi"], and default RST ["59",
     * "599", "-10"] for that mode
     */
     function generateRst(mode) {
        if (["AM", "FM", "SSB"].includes(mode))
            return {category: "phone", rst: "59"};
        if (["CW"].includes(mode)) 
            return {category: "cw", rst: "599"};
        return {category: "digi", rst: "-10"};
    }
}}

NOOP = ""
