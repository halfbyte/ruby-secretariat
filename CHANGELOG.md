# Changelog

## 3.0.0

- [BREAKING] This now needs Java installed to run the Schematron validator, as nokogiri-schematron does not work with XSLT based schematron files
- [BREAKING] For ZUGFeRD 2.x, this library now exclusively uses the schemas for 2.3, or rather Factur-X 1.0.0.7 as it is called. The XML generation part is unchanged, though, as we had no validation issues after upgrading the schemas.

## 2.0.0

- [BREAKING] Validators and XML generators now need a version to use to be able to support ZUGFeRD 1.0

