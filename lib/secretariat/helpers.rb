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
  module Helpers
    def self.format(something, round: nil, digits: 2)
      dec = BigDecimal(something, 10)
      dec = dec.round(round, :down) if round
      "%0.#{digits}f" % dec
    end

    def self.currency_element(xml, ns, name, amount, currency, add_currency: true, digits: 2)
      attrs = {}
      if add_currency
        attrs[:currencyID] = currency
      end
      xml[ns].send(name, attrs) do
        xml.text(format(amount, round: 4, digits: digits))
      end
    end

    def self.date_element(xml, date)
      date = date.strftime("%Y%m%d") if date.respond_to?(:strftime)
      xml["udt"].DateTimeString(format: "102") do
        xml.text(date)
      end
    end
  end
end
