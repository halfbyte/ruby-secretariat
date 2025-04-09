# A ZUGFeRD xml generator and validator

See tests for examples.

## Some words of caution

1. This is an opinionated library optimised for my very specific usecase
2. While I did start to add some validations to make sure you can't input absolute garbage into this, I cannot guarantee factual (as in taxation law) correctness of the resulting XML.
1. The library, for ZUGFeRD 2.x, currently only supports the EN16931 variant. This is probably what you want as well. PRs welcome.
3. This does not contain any code to attach the XML to a PDF file, mainly because I have yet to find a ruby library to do that. For software that does this, take a look at [this python library](https://github.com/akretion/factur-x) or [this Java library which also does extended validation](https://mustangproject.org)

## Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md).

## LICENSE

See [LICENSE](LICENSE).

Additionally, this project contains material, such as the schema files, which, according to the ZUGFeRD documentation, are also licensed under the Apache License.

Additionally, this project uses nokogiri and [SchXslt](https://github.com/schxslt/schxslt), both licensed unter the MIT license.


