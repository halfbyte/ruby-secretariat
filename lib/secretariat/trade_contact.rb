module Secretariat
  TradeContact = Struct.new("TradeContact", :person_name, :department, :telephone, :email, keyword_init: true) do
    def to_xml(xml, version: 2)
      xml["ram"].DefinedTradeContact do
        if person_name
          xml["ram"].PersonName do
            xml.text(person_name)
          end
        end
        if department
          xml["ram"].DepartmentName do
            xml.text(department)
          end
        end
        if telephone
          xml["ram"].TelephoneUniversalCommunication do
            xml["ram"].CompleteNumber do
              xml.text(telephone)
            end
          end
        end
        if email
          xml["ram"].EmailURIUniversalCommunication do
            xml["ram"].URIID do
              xml.text(email)
            end
          end
        end
      end
    end
  end
end
