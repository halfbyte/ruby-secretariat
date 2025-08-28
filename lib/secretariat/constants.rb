# Copyright Jan Krutisch and contributors (see CONTRIBUTORS.md)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Secretariat
  ALLOWED_MIME_TYPES = [
    "application/pdf",
    "application/vnd.oasis.opendocument.spreadsheet",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "image/jpeg",
    "image/png",
    "text/csv"
  ]

  TAX_CATEGORY_CODES = {
    STANDARDRATE: "S",
    REVERSECHARGE: "AE",
    TAXEXEMPT: "E",
    ZEROTAXPRODUCTS: "Z",
    UNTAXEDSERVICE: "O",
    INTRACOMMUNITY: "K",
    EXPORT: "G"
  }

  TAX_CATEGORY_CODES_1 = {
    STANDARDRATE: "S",
    REVERSECHARGE: "AE",
    TAXEXEMPT: "E",
    ZEROTAXPRODUCTS: "Z",
    UNTAXEDSERVICE: "O",
    INTRACOMMUNITY: "IC",
    EXPORT: "E"
  }

  PAYMENT_CODES = {
    BANKACCOUNT: "42",
    NOTSPECIFIED: "1",
    AUTOMATICCLEARING: "3",
    CASH: "10",
    CHECK: "20",
    DEBITADVICE: "31",
    CREDITCARD: "48",
    DEBIT: "49",
    COMPENSATION: "97"
  }

  TAX_EXEMPTION_REASONS = {
    REVERSECHARGE: "Reverse Charge",
    INTRACOMMUNITY: "Intra-community transaction",
    EXPORT: "Export outside the EU",
    TAXEXEMPT: "VAT exempt",
    UNTAXEDSERVICE: "Not subject to VAT"
  }

  # For the background of vertical and horizontal tax calculation see https://hilfe.pacemo.de/de-form/articles/3489851-rundungsfehler-bei-rechnungen
  # The idea of introducing an unknown value is that this could be inferred from the given invoice total and line items by probing both variants and selecting the matching one - or reporting a taxation error if neither matches.
  TAX_CALCULATION_METHODS = %i[HORIZONTAL VERTICAL NONE UNKNOWN].freeze

  UNIT_CODES = {
    PIECE: "H87",
    DAY: "DAY",
    HECTARE: "HAR",
    HOUR: "HUR",
    KILOGRAM: "KGM",
    KILOMETER: "KTM",
    KILOWATTHOUR: "KWH",
    FIXEDRATE: "LS",
    LITRE: "LTR",
    MINUTE: "MIN",
    SQUAREMILLIMETER: "MMK",
    MILLIMETER: "MMT",
    SQUAREMETER: "MTK",
    CUBICMETER: "MTQ",
    METER: "MTR",
    PRODUCTCOUNT: "NAR",
    PRODUCTPAIR: "NPR",
    PERCENT: "P1",
    SET: "SET",
    TON: "TNE",
    WEEK: "WEE"
  }
end
