![MetaModel-banner](./images/banner.png)

# MetaModel

====

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/draveness/metamodel/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/metamodel.svg?style=flat)](http://rubygems.org/gems/metamodel)

MetaModel is an iOS framework that includes everything about model layer, data persistent, JSON to model constructor and a bunch of APIs which provides a way of dealing with client side database very easily.

> MetaModel is under-development, API may constantly change before gets to 1.0.0.

+ [x] Fastest JSON to model API
+ [x] Dealing with database without writing SQL
+ [x] Most concise API to retrieve data from persistent level

Use a scaffold file to define your model:

```ruby
metamodel_version '0.0.1'

define :User do |j|
  # define User model like this
  j.nickname :string
  j.avatar :string
  j.email :string, :unique, default: "default@gmail.com"
end
```

And then run `meta build` will automatically generate all the code you need.

## Installation

```
sudo gem install metamodel --verbose
```

**System Requirements**: Current version of MetaModel requires macOS with Ruby 2.2.2 or above

## Quick Start


a brand new xcode project in `./MetaModel` folder, just add the whole Xcode Project into your folder


## License

This project is licensed under the terms of the MIT license. See the [LICENSE](./LICENSE) file.

The MIT License (MIT)

Copyright (c) 2016 Draveness

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
