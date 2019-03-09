[![GitHub tag](https://img.shields.io/github/tag/creekpld/SimpleHTTP.svg)](https://github.com/creekpld/SimpleHTTP/tags)

# SimpleHTTP

A simple library to make HTTP Requests using URLRequest and Codable Data.

This Swift library is written in swift version 4.0

## Features

- [x] Uses only Foundations URLRequest
- [x] Very simple one line HTTP Requets
- [x] Supports Swift's Codable Models
- [x] Supports Linux

## Installation

### Import Source File

You can just drop the Source File [SimpleHTTP.swift](Sources/SimpleHTTP/SimpleHTTP.swift) into your Project.

### Swift Package Manager

``` swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "YourApp",
    products: [
        .executable(name: "YourApp", targets: ["YourApp"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/creekpld/SimpleHTTP.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["SimpleHTTP"],
            path: "Sources"),
    ]
)
```

## Usage

Synchronous Example:
``` swift
import SimpleHTTP

let result = httpSync("https://example.com").json() as YourResultModel?
```

Asynchronous Example:
``` swift
  httpAsync("https://example.com"){
    ( data, result, error) as
    let result = data.json() as YourResultModel?
    // your code
  })
```

## Advanced Usage

``` swift
        let request = YourRequestModel(msg: "Hello", description: "World", version: "1.2.3")
        
        let result = httpSync("https://example.com/api/v1/", 
                              "POST", 
                              Data(encode: request),
                              ["Content-Type":"application/json",
                               "Authorization":"Bearer UkGaHu8nT4O05XgoEhA50oPbmWxSI0"],
                              timeout: 120
                            )?.json() as YourResultModel?
```

## TODO

- [x] Code Comments / Documentation
- [x] Advanced Usage Examples
- [ ] Some Tests
- [ ] CI

## License

SimpleHTTP is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
