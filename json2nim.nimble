# Package

version       = "0.1.0"
author        = "Isaac"
description   = "A json schema to Nim type converter"
license       = "MIT"
srcDir        = "src"
bin           = @["json2nim"]


# Dependencies

requires "nim >= 1.6.8"


task build, "Compiling json2nim...":
  exec "nim c -mm:orc src/json2nim.nim -o json2nim"
