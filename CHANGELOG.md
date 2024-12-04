# Changelog

## 3.2.0

- [CHORE] Update schemas for latest Factur-X version (1.07.2) by @zealot128
- [FEATURE] Allow for multiple tax rates in line items and correctly summarising them in invoice. PR by @SubandiK
- [CHORE] Update copyright notices and add CONTRIBUTORS.md to reflect that this isn't a solo project anymore.

## 3.1.0

- [BUGFIX] Schematron Validator always reported valid. Fix by @SubandiK
- [FEATURE] Allow skipping validations on `Invoice` and `LineItem` to allow for alternative calculation methods. PR by @zealot128
- [FEATURE] Multiple fields added (`payment_due_date`, `service_period_to` + `...from`, `payment_iban`, `buyer_reference`, `payment_terms_text`) to Invoice. PR by @zealot128
- [FEATURE] Return a list of exceptions from schematron validator to make it behave the same as schema validator.

## 3.0.1

- [BUGFIX] Schema JAR must be properly relatively addressed when published as a gem
- [BUGFIX] Make sure tmpdir lib is loaded when needed

## 3.0.0

- [BREAKING] This now needs Java installed to run the Schematron validator, as nokogiri-schematron does not work with XSLT based schematron files
- [BREAKING] For ZUGFeRD 2.x, this library now exclusively uses the schemas for 2.3, or rather Factur-X 1.0.0.7 as it is called. The XML generation part is unchanged, though, as we had no validation issues after upgrading the schemas.

## 2.0.0

- [BREAKING] Validators and XML generators now need a version to use to be able to support ZUGFeRD 1.0

