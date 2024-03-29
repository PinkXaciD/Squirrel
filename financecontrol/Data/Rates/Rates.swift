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
    static let fallback = Rates(
        timestamp: "2024-03-26T11:00:00.514703881Z",
        rates: [
            "AED": 3.67232,
            "AFN": 71.215413,
            "ALL": 94.924007,
            "AMD": 395.551749,
            "ANG": 1.800328,
            "AOA": 836.877667,
            "ARS": 856.242095,
            "AUD": 1.526184,
            "AWG": 1.8,
            "AZN": 1.7,
            "BAM": 1.804152,
            "BBD": 2,
            "BDT": 109.634664,
            "BGN": 1.8029,
            "BHD": 0.37692,
            "BIF": 2857.331519,
            "BMD": 1,
            "BND": 1.343935,
            "BOB": 6.902786,
            "BRL": 4.9769,
            "BSD": 1,
            "BTN": 83.290978,
            "BWP": 13.711861,
            "BYN": 3.269021,
            "BZD": 2.013515,
            "CAD": 1.35711,
            "CDF": 2781.909708,
            "CHF": 0.901444,
            "CLP": 978.38,
            "CNY": 7.2184,
            "COP": 3884.794602,
            "CRC": 502.017932,
            "CUC": 1,
            "CUP": 25.75,
            "CVE": 101.715323,
            "CZK": 23.2718,
            "DJF": 177.883352,
            "DKK": 6.870905,
            "DOP": 59.030005,
            "DZD": 134.701,
            "EGP": 47.7556,
            "ERN": 15,
            "ETB": 56.748507,
            "EUR": 0.921365,
            "FJD": 2.24875,
            "FKP": 0.790251,
            "GBP": 0.790251,
            "GEL": 2.7,
            "GHS": 13.134942,
            "GIP": 0.790251,
            "GMD": 67.925,
            "GNF": 8585.556648,
            "GTQ": 7.791117,
            "GYD": 208.983865,
            "HKD": 7.823422,
            "HNL": 24.661792,
            "HRK": 6.94182,
            "HTG": 132.437915,
            "HUF": 365.260149,
            "IDR": 15796.57763,
            "ILS": 3.668115,
            "INR": 83.297982,
            "IQD": 1308.51147,
            "IRR": 42047.5,
            "ISK": 137.56,
            "JMD": 153.640387,
            "JOD": 0.7089,
            "JPY": 151.2704,
            "KES": 131.99,
            "KGS": 89.51,
            "KHR": 4042.207033,
            "KMF": 454.449922,
            "KPW": 900,
            "KRW": 1340.888514,
            "KWD": 0.30758,
            "KYD": 0.83243,
            "KZT": 449.995911,
            "LAK": 21037.386476,
            "LBP": 89469.197514,
            "LKR": 301.931754,
            "LRD": 192.750012,
            "LSL": 18.94532,
            "LYD": 4.832914,
            "MAD": 10.064895,
            "MDL": 17.649228,
            "MGA": 4371.679039,
            "MKD": 56.768924,
            "MMK": 2097.734569,
            "MNT": 3450,
            "MOP": 8.048023,
            "MRU": 39.88,
            "MUR": 46.28,
            "MVR": 15.43,
            "MWK": 1731.970315,
            "MXN": 16.679827,
            "MYR": 4.72,
            "MZN": 63.900001,
            "NAD": 18.945058,
            "NGN": 1440.38,
            "NIO": 36.760128,
            "NOK": 10.711903,
            "NPR": 133.269031,
            "NZD": 1.659663,
            "OMR": 0.384947,
            "PAB": 1,
            "PEN": 3.699905,
            "PGK": 3.772019,
            "PHP": 56.267005,
            "PKR": 277.873351,
            "PLN": 3.970475,
            "PYG": 7342.14884,
            "QAR": 3.643727,
            "RON": 4.5802,
            "RSD": 107.992,
            "RUB": 92.592593,
            "RWF": 1283.088665,
            "SAR": 3.750565,
            "SBD": 8.454445,
            "SCR": 13.978475,
            "SDG": 601,
            "SEK": 10.546369,
            "SGD": 1.344049,
            "SHP": 0.790251,
            "SLL": 20969.5,
            "SOS": 570.836356,
            "SRD": 35.041,
            "SSP": 130.26,
            "STN": 22.600746,
            "SYP": 2512.53,
            "SZL": 18.940522,
            "THB": 36.2865,
            "TJS": 10.917896,
            "TMT": 3.5,
            "TND": 3.118,
            "TOP": 2.356167,
            "TRY": 32.18714,
            "TTD": 6.789449,
            "TWD": 31.888999,
            "TZS": 2563,
            "UAH": 39.247161,
            "UGX": 3890.955508,
            "USD": 1,
            "UYU": 37.906803,
            "UZS": 12583.377195,
            "VES": 36.312083,
            "VND": 24773.941239,
            "VUV": 118.722,
            "WST": 2.8,
            "XAF": 604.375885,
            "XCD": 2.70255,
            "XOF": 604.375885,
            "XPF": 109.948102,
            "YER": 250.399984,
            "ZAR": 18.931958,
            "ZMW": 26.745693
        ]
    )
}
