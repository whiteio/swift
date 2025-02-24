// RUN: %empty-directory(%t)
// RUN: %target-clang -std=c++14 %target-threading-opt %target-rtti-opt %target-pic-opt %target-msvc-runtime-opt -DSWIFT_INLINE_NAMESPACE=__runtime -g -c %S/Inputs/RoundTrip/RoundTrip.cpp -I%swift_obj_root/include -I%swift_src_root/include -I%swift_src_root/stdlib/include -I%swift_src_root/stdlib/public/runtime -I %swift_src_root/stdlib/public/SwiftShims/ -I%llvm_src_root/include -I%llvm_obj_root/include -o %t/RoundTrip.o
// RUN: %target-build-swift -g -static -emit-module-path %t/RoundTrip.swiftmodule -emit-module -emit-library -module-name RoundTrip -o %t/%target-static-library-name(RoundTrip) %S/Inputs/RoundTrip/RoundTrip.swift %t/RoundTrip.o
// RUN: echo "// AUTOGENERATED" > %t/all-tests.swift
// RUN: for module in %S/Inputs/testcases/*.swift; do modname=$(basename $module .swift); echo "import $modname" >> %t/all-tests.swift; done
// RUN: echo "func runAllTests() throws {" >> %t/all-tests.swift
// RUN: for module in %S/Inputs/testcases/*.swift; do modname=$(basename $module .swift); %target-build-swift -g -static -emit-module-path %t/$modname.swiftmodule -emit-module -emit-library -module-name $modname -o %t/%target-static-library-name($modname) -I%t -L%t $module -lRoundTrip; echo "  print(\"--- $modname\")" >> %t/all-tests.swift; echo "  $modname.test()" >> %t/all-tests.swift; echo "  print(\"\")" >> %t/all-tests.swift; echo "-l$modname" >> %t/link.txt; done
// RUN: echo "}" >> %t/all-tests.swift
// RUN: %target-build-swift -g -I%t -o %t/round-trip %s %t/all-tests.swift -L%t %target-cxx-lib $(cat %t/link.txt) -lm -lRoundTrip -lswiftRemoteInspection
// RUN: %target-codesign %t/round-trip
// RUN: %target-run %t/round-trip | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: shell
// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime

// CHECK-NOT: FAIL

@main
struct Test {
  static func main() throws {
    try runAllTests()
  }
}
