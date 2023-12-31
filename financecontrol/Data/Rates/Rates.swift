//
//  Rates.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/26.
//

import Foundation

struct Rates: Codable {
    let timestamp: String
    let rates: [String: Double]
}

extension Rates {
    static let fallback: Rates = .init(
        timestamp: "2023-12-25T13:00:00.373953065Z",
        rates: [
            "AED": 3.6726,
            "AFN": 70.087132,
            "ALL": 94.264195,
            "AMD": 405.222194,
            "ANG": 1.80542,
            "AOA": 830.599367,
            "ARS": 804.269703,
            "AUD": 1.472335,
            "AWG": 1.8025,
            "AZN": 1.7,
            "BAM": 1.776982,
            "BBD": 2,
            "BDT": 109.946103,
            "BGN": 1.77754,
            "BHD": 0.376116,
            "BIF": 2852.641166,
            "BMD": 1,
            "BND": 1.325968,
            "BOB": 6.922399,
            "BRL": 4.892443,
            "BSD": 1,
            "BTN": 83.28884,
            "BWP": 13.428673,
            "BYN": 3.300383,
            "BZD": 2.019298,
            "CAD": 1.325755,
            "CDF": 2730.825172,
            "CHF": 0.8571,
            "CLP": 892.74,
            "CNY": 7.1363,
            "COP": 3949.812778,
            "CRC": 521.882585,
            "CUC": 1,
            "CUP": 25.75,
            "CVE": 100.183534,
            "CZK": 22.2856,
            "DJF": 178.361474,
            "DKK": 6.7679,
            "DOP": 57.70331,
            "DZD": 134.158063,
            "EGP": 30.882927,
            "ERN": 15,
            "ETB": 56.407601,
            "EUR": 0.907897,
            "FJD": 2.1988,
            "FKP": 0.788022,
            "GBP": 0.788022,
            "GEL": 2.69,
            "GHS": 12.021297,
            "GIP": 0.788022,
            "GMD": 67.375,
            "GNF": 8611.439937,
            "GTQ": 7.833695,
            "GYD": 209.589051,
            "HKD": 7.808855,
            "HNL": 24.712211,
            "HRK": 6.8405,
            "HTG": 132.242449,
            "HUF": 345.92,
            "IDR": 15467,
            "ILS": 3.61312,
            "INR": 83.172499,
            "IQD": 1312.341006,
            "IRR": 42275,
            "ISK": 136.63,
            "JMD": 155.274748,
            "JOD": 0.7094,
            "JPY": 142.375,
            "KES": 154.97,
            "KGS": 89.225,
            "KHR": 4109.383412,
            "KMF": 447.249823,
            "KPW": 900,
            "KRW": 1297.292633,
            "KWD": 0.306556,
            "KYD": 0.834795,
            "KZT": 459.618436,
            "LAK": 20598.406687,
            "LBP": 15056.17599,
            "LKR": 326.085844,
            "LRD": 188.349994,
            "LSL": 18.450433,
            "LYD": 4.806339,
            "MAD": 9.904964,
            "MDL": 17.543951,
            "MGA": 4615.542485,
            "MKD": 55.828388,
            "MMK": 2103.703962,
            "MNT": 3450,
            "MOP": 8.062564,
            "MRU": 39.137585,
            "MUR": 43.909998,
            "MVR": 15.35,
            "MWK": 1686.306365,
            "MXN": 17.006905,
            "MYR": 4.6508,
            "MZN": 63.850001,
            "NAD": 18.450433,
            "NGN": 764.5,
            "NIO": 36.660821,
            "NOK": 10.19077,
            "NPR": 133.261867,
            "NZD": 1.593473,
            "OMR": 0.384292,
            "PAB": 1,
            "PEN": 3.699608,
            "PGK": 3.737859,
            "PHP": 55.335008,
            "PKR": 279.493209,
            "PLN": 3.94653,
            "PYG": 7381.183969,
            "QAR": 3.65418,
            "RON": 4.514,
            "RSD": 106.469921,
            "RUB": 92.024995,
            "RWF": 1258.278835,
            "SAR": 3.751,
            "SBD": 8.440171,
            "SCR": 13.979084,
            "SDG": 601,
            "SEK": 10.019985,
            "SGD": 1.3243,
            "SHP": 0.788022,
            "SLL": 20969.5,
            "SOS": 572.489682,
            "SRD": 36.946,
            "SSP": 130.26,
            "STN": 22.259978,
            "SYP": 2512.53,
            "SZL": 18.433989,
            "THB": 34.5955,
            "TJS": 10.954363,
            "TMT": 3.5,
            "TND": 3.0825,
            "TOP": 2.338274,
            "TRY": 29.257,
            "TTD": 6.815188,
            "TWD": 31.099999,
            "TZS": 2519.466,
            "UAH": 37.554854,
            "UGX": 3769.674298,
            "USD": 1,
            "UYU": 39.384281,
            "UZS": 12406.394662,
            "VES": 35.742693,
            "VND": 24245,
            "VUV": 118.722,
            "WST": 2.8,
            "XAF": 595.541444,
            "XCD": 2.70255,
            "XOF": 595.541444,
            "XPF": 108.34094,
            "YER": 249.799919,
            "ZAR": 18.4949,
            "ZMW": 25.439975
        ]
    )
}
