=begin
Copyright Jan Krutisch and contributors (see CONTRIBUTORS.md)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'bigdecimal'

module Secretariat
  Tax = Struct.new('Tax',
    :tax_percent,
    :tax_amount,
    :base_amount,
    keyword_init: true
  ) do

    def initialize(*)
      super
      self.tax_amount = 0
      self.base_amount = 0
    end
  end
end