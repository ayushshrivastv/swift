// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %swift-frontend -target wasm32-unknown-wasip1 -parse-stdlib -module-name Swift -typecheck -enable-experimental-feature WasmExternref -I %t %t/test.swift

// REQUIRES: CODEGENERATOR=WebAssembly
// REQUIRES: swift_feature_WasmExternref

//--- wasm_externref.h
__externref_t c_roundtrip_externref(__externref_t);
extern __externref_t objects[0];

//--- module.modulemap
module wasm_externref {
  header "wasm_externref.h"
  export *
}

//--- test.swift
import wasm_externref

/// ===== Minimal stdlib definitions =====
typealias Void = ()
enum Optional<T> {}

public struct WasmExternref {
  internal var _rawValue: Builtin.WasmExternRef

  internal init(_ value: Builtin.WasmExternRef) {
    _rawValue = value
  }
}

public struct WasmExternrefTable {
  internal var _rawValue: Builtin.WasmExternRefTable

  internal init(_ value: Builtin.WasmExternRefTable) {
    _rawValue = value
  }
}
/// ======================================

func test(_ value: WasmExternref) {
  let _: (WasmExternref) -> WasmExternref = c_roundtrip_externref
  let result: WasmExternref = c_roundtrip_externref(value)
  let _: Builtin.WasmExternRef = result._rawValue
  _ = Builtin.wasmTableSizeExternRef(objects._rawValue)
  takesAddress(&objects) // expected-error {{cannot pass value of type 'WasmExternrefTable' as 'inout'; WebAssembly tables are not addressable}}
}

func takesAddress<T>(_ value: inout T) {}
