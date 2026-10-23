module Secretariat
  using ObjectExtensions

  TradeContact = Struct.new("TradeContact", :person_name, :department, :telephone, :email, keyword_init: true) do
    def to_xml(xml, version: 2)
      xml["ram"].DefinedTradeContact do
        if person_name.present?
          xml["ram"].PersonName do
            xml.text(person_name)
          end
        end
        if department.present?
          xml["ram"].DepartmentName do
            xml.text(department)
          end
        end
        if telephone.present?
          xml["ram"].TelephoneUniversalCommunication do
            xml["ram"].CompleteNumber do
              xml.text(telephone)
            end
          end
        end
        if email.present?
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
