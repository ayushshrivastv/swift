// RUN: %target-swift-frontend -target wasm32-unknown-wasip1 -typecheck -enable-experimental-feature WasmExternref %s

// REQUIRES: CODEGENERATOR=WebAssembly
// REQUIRES: swift_feature_WasmExternref

#if hasFeature(WasmExternref)
struct StoredProperty {
  var value: WasmExternref // expected-error {{stored property cannot have type 'WasmExternref'; WebAssembly references cannot be stored in Swift memory}}
}

enum GlobalStorage {
  static var value: WasmExternref = fatalError() // expected-error {{static property cannot have type 'WasmExternref'; WebAssembly references cannot be stored in Swift memory}}
}

var globalValue: WasmExternref = fatalError() // expected-error {{global variable cannot have type 'WasmExternref'; WebAssembly references cannot be stored in Swift memory}}

struct TableStoredProperty {
  var table: WasmExternrefTable // expected-error {{stored property cannot have type 'WasmExternrefTable'; WebAssembly tables are not Swift values}}
}

enum TableGlobalStorage {
  static var table: WasmExternrefTable = fatalError() // expected-error {{static property cannot have type 'WasmExternrefTable'; WebAssembly tables are not Swift values}}
}

var globalTable: WasmExternrefTable = fatalError() // expected-error {{global variable cannot have type 'WasmExternrefTable'; WebAssembly tables are not Swift values}}

func takesInOut(_ value: inout WasmExternref) {} // expected-error {{'inout' parameter 'value' cannot have type 'WasmExternref'; WebAssembly references are not addressable}}

func takesVariadic(_ values: WasmExternref...) {} // expected-error {{parameter 'values' cannot be variadic because type 'WasmExternref' contains a WebAssembly reference}}

func takesPointer(_ value: UnsafePointer<WasmExternref>) {} // expected-error {{type 'UnsafePointer<WasmExternref>' cannot contain a pointer to a WebAssembly reference}}

func takesTable(_ table: WasmExternrefTable) {} // expected-error {{parameter 'table' cannot have type 'WasmExternrefTable'; WebAssembly tables cannot be passed as Swift values}}

func takesTablePointer(_ table: UnsafePointer<WasmExternrefTable>) {} // expected-error {{type 'UnsafePointer<WasmExternrefTable>' cannot contain a pointer to a WebAssembly table}}

func returnsPointer() -> UnsafeMutablePointer<WasmExternref> { // expected-error {{type 'UnsafeMutablePointer<WasmExternref>' cannot contain a pointer to a WebAssembly reference}}
  fatalError()
}

func returnsTable() -> WasmExternrefTable { // expected-error {{result type 'WasmExternrefTable' cannot contain a WebAssembly table}}
  fatalError()
}

func rejectInOutExpr(_ value: WasmExternref) {
  var local = value
  takesAddress(&local) // expected-error {{cannot pass value of type 'WasmExternref' as 'inout'; WebAssembly references are not addressable}}
}

func takesAddress<T>(_ value: inout T) {}

func rejectCapture(_ value: WasmExternref) -> () -> WasmExternref {
  { value } // expected-error {{cannot capture value of type 'WasmExternref'; WebAssembly references cannot be stored in closure contexts}}
}

func localRoundTrip(_ value: WasmExternref) -> WasmExternref {
  let local = value
  return local
}

let _: WasmExternref = .null
let _: UInt32 = WasmExternrefIndex(rawValue: 0).rawValue

func rejectTableStorage() {
  let _: WasmExternrefTable = fatalError() // expected-error {{local variable cannot have type 'WasmExternrefTable'; WebAssembly tables are not Swift values}}
}

let _: Int = MemoryLayout<WasmExternref>.size // expected-error {{'size' is unavailable: WebAssembly references do not have a Swift memory layout}}
let _: Int = MemoryLayout<WasmExternrefTable>.size // expected-error {{'size' is unavailable: WebAssembly tables do not have a Swift memory layout}}

func rejectLayout(_ value: WasmExternref) {
  _ = MemoryLayout.size(ofValue: value) // expected-error {{'size(ofValue:)' is unavailable: WebAssembly references do not have a Swift memory layout}}
}
#endif
