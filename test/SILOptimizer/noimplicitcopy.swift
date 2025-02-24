// RUN: %target-swift-frontend -enable-experimental-move-only -verify %s -parse-stdlib -emit-sil

import Swift

public class Klass {
    var k: Klass? = nil
}

public final class FinalKlass {
    var k: Klass? = nil
}

var boolValue: Bool { return true }

public func classUseMoveOnlyWithoutEscaping(_ x: Klass) {
}
public func classConsume(_ x: __owned Klass) {
}

public func classSimpleChainTest(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    let y2 = x2
    let k2 = y2
    classUseMoveOnlyWithoutEscaping(k2)
}

public func classSimpleChainArgTest(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let y2 = x2 // expected-note {{consuming use}}
    let k2 = y2
    classUseMoveOnlyWithoutEscaping(k2)
}

public func classSimpleChainOwnedArgTest(@_noImplicitCopy _ x2: __owned Klass) {
    let y2 = x2
    let k2 = y2
    classUseMoveOnlyWithoutEscaping(k2)
}

public func classSimpleNonConsumingUseTest(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2)
}

public func classSimpleNonConsumingUseArgTest(@_noImplicitCopy _ x2: Klass) {
    classUseMoveOnlyWithoutEscaping(x2)
}

public func classSimpleNonConsumingUseOwnedArgTest(@_noImplicitCopy _ x2: __owned Klass) {
    classUseMoveOnlyWithoutEscaping(x2)
}

public func classMultipleNonConsumingUseTest(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2)
    classUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func classMultipleNonConsumingUseArgTest(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    classUseMoveOnlyWithoutEscaping(x2)
    classUseMoveOnlyWithoutEscaping(x2)
    print(x2) // expected-note {{consuming use}}
}

public func classMultipleNonConsumingUseOwnedArgTest(@_noImplicitCopy _ x2: __owned Klass) {
    classUseMoveOnlyWithoutEscaping(x2)
    classUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func classUseAfterConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    classUseMoveOnlyWithoutEscaping(x2)
    classConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func classUseAfterConsumeArg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    classUseMoveOnlyWithoutEscaping(x2)
    classConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func classUseAfterConsumeOwnedArg(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    classUseMoveOnlyWithoutEscaping(x2)
    classConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func classDoubleConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x  // expected-error {{'x2' consumed more than once}}
    classConsume(x2) // expected-note {{consuming use}}
    classConsume(x2) // expected-note {{consuming use}}
}

public func classDoubleConsumeArg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    classConsume(x2) // expected-note {{consuming use}}
    classConsume(x2) // expected-note {{consuming use}}
}

public func classDoubleConsumeOwnedArg(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    classConsume(x2) // expected-note {{consuming use}}
    classConsume(x2) // expected-note {{consuming use}}
}

public func classLoopConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        classConsume(x2) // expected-note {{consuming use}}
    }
}

public func classLoopConsumeArg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        classConsume(x2) // expected-note {{consuming use}}
    }
}

public func classLoopConsumeOwnedArg(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        classConsume(x2) // expected-note {{consuming use}}
    }
}

public func classDiamond(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    if boolValue {
        classConsume(x2)
    } else {
        classConsume(x2)
    }
}

public func classDiamondArg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if boolValue {
        classConsume(x2) // expected-note {{consuming use}}
    } else {
        classConsume(x2) // expected-note {{consuming use}}
    }
}

public func classDiamondOwnedArg(@_noImplicitCopy _ x2: __owned Klass) {
    if boolValue {
        classConsume(x2)
    } else {
        classConsume(x2)
    }
}

public func classDiamondInLoop(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          classConsume(x2) // expected-note {{consuming use}}
      } else {
          classConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func classDiamondInLoopArg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
      if boolValue {
          classConsume(x2) // expected-note {{consuming use}}
      } else {
          classConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func classDiamondInLoopOwnedArg(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          classConsume(x2) // expected-note {{consuming use}}
      } else {
          classConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func classAssignToVar1(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func classAssignToVar1Arg(_ x: Klass, @_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func classAssignToVar1OwnedArg(_ x: Klass, @_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func classAssignToVar2(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    classUseMoveOnlyWithoutEscaping(x3)
}

public func classAssignToVar2Arg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    classUseMoveOnlyWithoutEscaping(x3)
}

public func classAssignToVar2OwnedArg(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    classUseMoveOnlyWithoutEscaping(x3)
}

public func classAssignToVar3(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    var x3 = x2
    x3 = x
    print(x3)
}

public func classAssignToVar3Arg(_ x: Klass, @_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func classAssignToVar3OwnedArg(_ x: Klass, @_noImplicitCopy _ x2: __owned Klass) {
    var x3 = x2
    x3 = x
    print(x3)
}

public func classAssignToVar4(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func classAssignToVar4Arg(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func classAssignToVar4OwnedArg(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func classAssignToVar5(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    classUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func classAssignToVar5Arg(_ x: Klass, @_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    classUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func classAssignToVar5OwnedArg(_ x: Klass, @_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    classUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func classAccessAccessField(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.k!)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.k!)
    }
}

public func classAccessAccessFieldArg(@_noImplicitCopy _ x2: Klass) {
    classUseMoveOnlyWithoutEscaping(x2.k!)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.k!)
    }
}

public func classAccessAccessFieldOwnedArg(@_noImplicitCopy _ x2: __owned Klass) {
    classUseMoveOnlyWithoutEscaping(x2.k!)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.k!)
    }
}

public func classAccessConsumeField(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    // Since a class is a reference type, we do not emit an error here.
    classConsume(x2.k!)
    for _ in 0..<1024 {
        classConsume(x2.k!)
    }
}

public func classAccessConsumeFieldArg(@_noImplicitCopy _ x2: Klass) {
    // Since a class is a reference type, we do not emit an error here.
    classConsume(x2.k!)
    for _ in 0..<1024 {
        classConsume(x2.k!)
    }
}

public func classAccessConsumeFieldOwnedArg(@_noImplicitCopy _ x2: __owned Klass) {
    // Since a class is a reference type, we do not emit an error here.
    classConsume(x2.k!)
    for _ in 0..<1024 {
        classConsume(x2.k!)
    }
}

/////////////////
// Final Class //
/////////////////

public func finalClassUseMoveOnlyWithoutEscaping(_ x: FinalKlass) {
}
public func finalClassConsume(_ x: __owned FinalKlass) {
}

public func finalClassSimpleChainTest(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x
    let y2 = x2
    let k2 = y2
    finalClassUseMoveOnlyWithoutEscaping(k2)
}

public func finalClassSimpleChainTestArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let y2 = x2 // expected-note {{consuming use}}
    let k2 = y2
    finalClassUseMoveOnlyWithoutEscaping(k2)
}

public func finalClassSimpleChainTestOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) {
    let y2 = x2
    let k2 = y2
    finalClassUseMoveOnlyWithoutEscaping(k2)
}

public func finalClassSimpleNonConsumingUseTest(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x
    finalClassUseMoveOnlyWithoutEscaping(x2)
}

public func finalClassSimpleNonConsumingUseTestArg(@_noImplicitCopy _ x2: FinalKlass) {
    finalClassUseMoveOnlyWithoutEscaping(x2)
}

public func finalClassSimpleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) {
    finalClassUseMoveOnlyWithoutEscaping(x2)
}

public func finalClassMultipleNonConsumingUseTest(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x
    finalClassUseMoveOnlyWithoutEscaping(x2)
    finalClassUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func finalClassMultipleNonConsumingUseTestArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    finalClassUseMoveOnlyWithoutEscaping(x2)
    finalClassUseMoveOnlyWithoutEscaping(x2)
    print(x2) // expected-note {{consuming use}}
}

public func finalClassMultipleNonConsumingUseTestownedArg(@_noImplicitCopy _ x2: __owned FinalKlass) {
    finalClassUseMoveOnlyWithoutEscaping(x2)
    finalClassUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func finalClassUseAfterConsume(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    finalClassUseMoveOnlyWithoutEscaping(x2)
    finalClassConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func finalClassUseAfterConsumeArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    finalClassUseMoveOnlyWithoutEscaping(x2)
    finalClassConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func finalClassUseAfterConsumeOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    finalClassUseMoveOnlyWithoutEscaping(x2)
    finalClassConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func finalClassDoubleConsume(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x  // expected-error {{'x2' consumed more than once}}
    finalClassConsume(x2) // expected-note {{consuming use}}
    finalClassConsume(x2) // expected-note {{consuming use}}
}

public func finalClassDoubleConsumeArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    finalClassConsume(x2) // expected-note {{consuming use}}
    finalClassConsume(x2) // expected-note {{consuming use}}
}

public func finalClassDoubleConsumeownedArg(@_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    finalClassConsume(x2) // expected-note {{consuming use}}
    finalClassConsume(x2) // expected-note {{consuming use}}
}

public func finalClassLoopConsume(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        finalClassConsume(x2) // expected-note {{consuming use}}
    }
}

public func finalClassLoopConsumeArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        finalClassConsume(x2) // expected-note {{consuming use}}
    }
}

public func finalClassLoopConsumeOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        finalClassConsume(x2) // expected-note {{consuming use}}
    }
}

public func finalClassDiamond(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x
    if boolValue {
        finalClassConsume(x2)
    } else {
        finalClassConsume(x2)
    }
}

public func finalClassDiamondArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if boolValue {
        finalClassConsume(x2) // expected-note {{consuming use}}
    } else {
        finalClassConsume(x2) // expected-note {{consuming use}}
    }
}

public func finalClassDiamondOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) {
    if boolValue {
        finalClassConsume(x2)
    } else {
        finalClassConsume(x2)
    }
}

public func finalClassDiamondInLoop(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          finalClassConsume(x2) // expected-note {{consuming use}}
      } else {
          finalClassConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func finalClassDiamondInLoopArg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
      if boolValue {
          finalClassConsume(x2) // expected-note {{consuming use}}
      } else {
          finalClassConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func finalClassDiamondInLoopOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          finalClassConsume(x2) // expected-note {{consuming use}}
      } else {
          finalClassConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func finalClassAssignToVar1(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func finalClassAssignToVar1Arg(_ x: FinalKlass, @_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func finalClassAssignToVar1OwnedArg(_ x: FinalKlass, @_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func finalClassAssignToVar2(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    finalClassUseMoveOnlyWithoutEscaping(x3)
}

public func finalClassAssignToVar2Arg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    finalClassUseMoveOnlyWithoutEscaping(x3)
}

public func finalClassAssignToVar2OwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    finalClassUseMoveOnlyWithoutEscaping(x3)
}

public func finalClassAssignToVar3(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x
    var x3 = x2
    x3 = x
    print(x3)
}

public func finalClassAssignToVar3Arg(_ x: FinalKlass, @_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func finalClassAssignToVar3OwnedArg(_ x: FinalKlass, @_noImplicitCopy _ x2: __owned FinalKlass) {
    var x3 = x2
    x3 = x
    print(x3)
}

public func finalClassAssignToVar4(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func finalClassAssignToVar4Arg(@_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func finalClassAssignToVar4OwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func finalClassAssignToVar5(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    finalClassUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func finalClassAssignToVar5Arg(_ x: FinalKlass, @_noImplicitCopy _ x2: FinalKlass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    finalClassUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func finalClassAssignToVar5OwnedArg(_ x: FinalKlass, @_noImplicitCopy _ x2: __owned FinalKlass) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    finalClassUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func finalClassAccessField(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.k!)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.k!)
    }
}

public func finalClassAccessFieldArg(@_noImplicitCopy _ x2: FinalKlass) {
    classUseMoveOnlyWithoutEscaping(x2.k!)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.k!)
    }
}

public func finalClassAccessFieldOwnedArg(@_noImplicitCopy _ x2: __owned FinalKlass) {
    classUseMoveOnlyWithoutEscaping(x2.k!)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.k!)
    }
}

public func finalClassConsumeField(_ x: FinalKlass) {
    @_noImplicitCopy let x2 = x

    // No diagnostic here since class is a reference type and we are not copying
    // the class, we are copying its field.
    classConsume(x2.k!)
    for _ in 0..<1024 {
        classConsume(x2.k!)
    }
}

public func finalClassConsumeFieldArg(@_noImplicitCopy _ x2: FinalKlass) {
    // No diagnostic here since class is a reference type and we are not copying
    // the class, we are copying its field.
    classConsume(x2.k!)
    for _ in 0..<1024 {
        classConsume(x2.k!)
    }
}

public func finalClassConsumeFieldArg(@_noImplicitCopy _ x2: __owned FinalKlass) {
    // No diagnostic here since class is a reference type and we are not copying
    // the class, we are copying its field.
    classConsume(x2.k!)
    for _ in 0..<1024 {
        classConsume(x2.k!)
    }
}

//////////////////////
// Aggregate Struct //
//////////////////////

public struct KlassPair {
    var lhs: Klass
    var rhs: Klass
}

public struct AggStruct {
    var lhs: Klass
    var center: Builtin.Int32
    var rhs: Klass
    var pair: KlassPair
}

public func aggStructUseMoveOnlyWithoutEscaping(_ x: AggStruct) {
}
public func aggStructConsume(_ x: __owned AggStruct) {
}

public func aggStructSimpleChainTest(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    let y2 = x2
    let k2 = y2
    aggStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggStructSimpleChainTestArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let y2 = x2 // expected-note {{consuming use}}
    let k2 = y2
    aggStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggStructSimpleChainTestOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    let y2 = x2
    let k2 = y2
    aggStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggStructSimpleNonConsumingUseTest(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    aggStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggStructSimpleNonConsumingUseTestArg(@_noImplicitCopy _ x2: AggStruct) {
    aggStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggStructSimpleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    aggStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggStructMultipleNonConsumingUseTest(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    aggStructUseMoveOnlyWithoutEscaping(x2)
    aggStructUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func aggStructMultipleNonConsumingUseTestArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggStructUseMoveOnlyWithoutEscaping(x2)
    aggStructUseMoveOnlyWithoutEscaping(x2)
    print(x2) // expected-note {{consuming use}}
}

public func aggStructMultipleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    aggStructUseMoveOnlyWithoutEscaping(x2)
    aggStructUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func aggStructUseAfterConsume(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    aggStructUseMoveOnlyWithoutEscaping(x2)
    aggStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggStructUseAfterConsumeArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggStructUseMoveOnlyWithoutEscaping(x2)
    aggStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggStructUseAfterConsumeOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) { // expected-error {{'x2' consumed more than once}}
    aggStructUseMoveOnlyWithoutEscaping(x2)
    aggStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggStructDoubleConsume(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x  // expected-error {{'x2' consumed more than once}}
    aggStructConsume(x2) // expected-note {{consuming use}}
    aggStructConsume(x2) // expected-note {{consuming use}}
}

public func aggStructDoubleConsumeArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggStructConsume(x2) // expected-note {{consuming use}}
    aggStructConsume(x2) // expected-note {{consuming use}}
}

public func aggStructDoubleConsumeOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) { // expected-error {{'x2' consumed more than once}}
    aggStructConsume(x2) // expected-note {{consuming use}}
    aggStructConsume(x2) // expected-note {{consuming use}}
}

public func aggStructLoopConsume(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        aggStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggStructLoopConsumeArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        aggStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggStructLoopConsumeOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        aggStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggStructDiamond(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    if boolValue {
        aggStructConsume(x2)
    } else {
        aggStructConsume(x2)
    }
}

public func aggStructDiamondArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if boolValue {
        aggStructConsume(x2) // expected-note {{consuming use}}
    } else {
        aggStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggStructDiamondOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    if boolValue {
        aggStructConsume(x2)
    } else {
        aggStructConsume(x2)
    }
}

public func aggStructDiamondInLoop(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          aggStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggStructDiamondInLoopArg(@_noImplicitCopy _ x2: AggStruct) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
      if boolValue {
          aggStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggStructDiamondInLoopOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          aggStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggStructAccessField(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggStructAccessFieldArg(@_noImplicitCopy _ x2: AggStruct) {
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggStructAccessFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggStructConsumeField(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggStructConsumeFieldArg(@_noImplicitCopy _ x2: AggStruct) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggStructConsumeFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggStructAccessGrandField(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggStructAccessGrandFieldArg(@_noImplicitCopy _ x2: AggStruct) {
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggStructAccessGrandFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggStructConsumeGrandField(_ x: AggStruct) {
    @_noImplicitCopy let x2 = x
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

public func aggStructConsumeGrandFieldArg(@_noImplicitCopy _ x2: AggStruct) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

public func aggStructConsumeGrandFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggStruct) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

//////////////////////////////
// Aggregate Generic Struct //
//////////////////////////////

public struct AggGenericStruct<T> {
    var lhs: Klass
    var rhs: Builtin.RawPointer
    var pair: KlassPair
}

public func aggGenericStructUseMoveOnlyWithoutEscaping(_ x: AggGenericStruct<Klass>) {
}
public func aggGenericStructConsume(_ x: __owned AggGenericStruct<Klass>) {
}

public func aggGenericStructSimpleChainTest(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    let y2 = x2
    let k2 = y2
    aggGenericStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggGenericStructSimpleChainTestArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let y2 = x2 // expected-note {{consuming use}}
    let k2 = y2
    aggGenericStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggGenericStructSimpleChainTestOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    let y2 = x2
    let k2 = y2
    aggGenericStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggGenericStructSimpleNonConsumingUseTest(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggGenericStructSimpleNonConsumingUseTestArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) {
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggGenericStructSimpleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggGenericStructMultipleNonConsumingUseTest(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func aggGenericStructMultipleNonConsumingUseTestArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructMultipleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func aggGenericStructUseAfterConsume(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructUseAfterConsumeArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructUseAfterConsumeOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) { // expected-error {{'x2' consumed more than once}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructDoubleConsume(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x  // expected-error {{'x2' consumed more than once}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
}

public func aggGenericStructDoubleConsumeArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
}

public func aggGenericStructDoubleConsumeOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) { // expected-error {{'x2' consumed more than once}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
}

public func aggGenericStructLoopConsume(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructLoopConsumeArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructLoopConsumeOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructDiamond(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    if boolValue {
        aggGenericStructConsume(x2)
    } else {
        aggGenericStructConsume(x2)
    }
}

public func aggGenericStructDiamondArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if boolValue {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    } else {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructDiamondOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    if boolValue {
        aggGenericStructConsume(x2)
    } else {
        aggGenericStructConsume(x2)
    }
}

public func aggGenericStructDiamondInLoop(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggGenericStructDiamondInLoopArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
      if boolValue {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggGenericStructDiamondInLoopOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggGenericStructAccessField(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggGenericStructAccessFieldArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) {
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggGenericStructAccessFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggGenericStructConsumeField(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeFieldArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructAccessGrandField(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggGenericStructAccessGrandFieldArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) {
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggGenericStructAccessGrandFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggGenericStructConsumeGrandField(_ x: AggGenericStruct<Klass>) {
    @_noImplicitCopy let x2 = x
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeGrandFieldArg(@_noImplicitCopy _ x2: AggGenericStruct<Klass>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeGrandFieldOwnedArg(@_noImplicitCopy _ x2: __owned AggGenericStruct<Klass>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

////////////////////////////////////////////////////////////
// Aggregate Generic Struct + Generic But Body is Trivial //
////////////////////////////////////////////////////////////

public func aggGenericStructUseMoveOnlyWithoutEscaping<T>(_ x: AggGenericStruct<T>) {
}
public func aggGenericStructConsume<T>(_ x: __owned AggGenericStruct<T>) {
}

public func aggGenericStructSimpleChainTest<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    let y2 = x2
    let k2 = y2
    aggGenericStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggGenericStructSimpleChainTestArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let y2 = x2 // expected-note {{consuming use}}
    let k2 = y2
    aggGenericStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggGenericStructSimpleChainTestOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    let y2 = x2
    let k2 = y2
    aggGenericStructUseMoveOnlyWithoutEscaping(k2)
}

public func aggGenericStructSimpleNonConsumingUseTest<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggGenericStructSimpleNonConsumingUseTestArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) {
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggGenericStructSimpleNonConsumingUseTestOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
}

public func aggGenericStructMultipleNonConsumingUseTest<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func aggGenericStructMultipleNonConsumingUseTestArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { //expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructMultipleNonConsumingUseTestOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func aggGenericStructUseAfterConsume<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructUseAfterConsumeArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructUseAfterConsumeOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) { // expected-error {{'x2' consumed more than once}}
    aggGenericStructUseMoveOnlyWithoutEscaping(x2)
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func aggGenericStructDoubleConsume<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x  // expected-error {{'x2' consumed more than once}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
}

public func aggGenericStructDoubleConsumeArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
}

public func aggGenericStructDoubleConsumeOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) { // expected-error {{'x2' consumed more than once}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
    aggGenericStructConsume(x2) // expected-note {{consuming use}}
}

public func aggGenericStructLoopConsume<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructLoopConsumeArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructLoopConsumeOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructDiamond<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    if boolValue {
        aggGenericStructConsume(x2)
    } else {
        aggGenericStructConsume(x2)
    }
}

public func aggGenericStructDiamondArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if boolValue {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    } else {
        aggGenericStructConsume(x2) // expected-note {{consuming use}}
    }
}

public func aggGenericStructDiamondOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    if boolValue {
        aggGenericStructConsume(x2)
    } else {
        aggGenericStructConsume(x2)
    }
}

public func aggGenericStructDiamondInLoop<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggGenericStructDiamondInLoopArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
      if boolValue {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggGenericStructDiamondInLoopOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      } else {
          aggGenericStructConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func aggGenericStructAccessField<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggGenericStructAccessFieldArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) {
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggGenericStructAccessFieldOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    classUseMoveOnlyWithoutEscaping(x2.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.lhs)
    }
}

public func aggGenericStructConsumeField<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeFieldArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeFieldOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.lhs)
    for _ in 0..<1024 {
        classConsume(x2.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructAccessGrandField<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggGenericStructAccessGrandFieldArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) {
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggGenericStructAccessGrandFieldOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    for _ in 0..<1024 {
        classUseMoveOnlyWithoutEscaping(x2.pair.lhs)
    }
}

public func aggGenericStructConsumeGrandField<T>(_ x: AggGenericStruct<T>) {
    @_noImplicitCopy let x2 = x
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeGrandFieldArg<T>(@_noImplicitCopy _ x2: AggGenericStruct<T>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

public func aggGenericStructConsumeGrandFieldOwnedArg<T>(@_noImplicitCopy _ x2: __owned AggGenericStruct<T>) {
    // expected-error @-1 {{'x2' has a move only field that was consumed before later uses}}
    classConsume(x2.pair.lhs)
    for _ in 0..<1024 {
        classConsume(x2.pair.lhs) // expected-note {{consuming use}}
    }
}

/////////////////////
// Enum Test Cases //
/////////////////////

public enum EnumTy {
    case klass(Klass)
    case int(Int)

    func doSomething() -> Bool { true }
}

public func enumUseMoveOnlyWithoutEscaping(_ x: EnumTy) {
}
public func enumConsume(_ x: __owned EnumTy) {
}

public func enumSimpleChainTest(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    let y2 = x2
    let k2 = y2
    enumUseMoveOnlyWithoutEscaping(k2)
}

public func enumSimpleChainTestArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let y2 = x2 // expected-note {{consuming use}}
    let k2 = y2
    enumUseMoveOnlyWithoutEscaping(k2)
}

public func enumSimpleChainTestOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) {
    let y2 = x2
    let k2 = y2
    enumUseMoveOnlyWithoutEscaping(k2)
}

public func enumSimpleNonConsumingUseTest(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    enumUseMoveOnlyWithoutEscaping(x2)
}

public func enumSimpleNonConsumingUseTestArg(@_noImplicitCopy _ x2: EnumTy) {
    enumUseMoveOnlyWithoutEscaping(x2)
}

public func enumSimpleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) {
    enumUseMoveOnlyWithoutEscaping(x2)
}

public func enumMultipleNonConsumingUseTest(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    enumUseMoveOnlyWithoutEscaping(x2)
    enumUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func enumMultipleNonConsumingUseTestArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    enumUseMoveOnlyWithoutEscaping(x2)
    enumUseMoveOnlyWithoutEscaping(x2)
    print(x2) // expected-note {{consuming use}}
}

public func enumMultipleNonConsumingUseTestOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) {
    enumUseMoveOnlyWithoutEscaping(x2)
    enumUseMoveOnlyWithoutEscaping(x2)
    print(x2)
}

public func enumUseAfterConsume(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    enumUseMoveOnlyWithoutEscaping(x2)
    enumConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func enumUseAfterConsumeArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    enumUseMoveOnlyWithoutEscaping(x2)
    enumConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func enumUseAfterConsumeOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    enumUseMoveOnlyWithoutEscaping(x2)
    enumConsume(x2) // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
}

public func enumDoubleConsume(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x  // expected-error {{'x2' consumed more than once}}
    enumConsume(x2) // expected-note {{consuming use}}
    enumConsume(x2) // expected-note {{consuming use}}
}

public func enumDoubleConsumeArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    enumConsume(x2) // expected-note {{consuming use}}
    enumConsume(x2) // expected-note {{consuming use}}
}

public func enumDoubleConsumeOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    enumConsume(x2) // expected-note {{consuming use}}
    enumConsume(x2) // expected-note {{consuming use}}
}

public func enumLoopConsume(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        enumConsume(x2) // expected-note {{consuming use}}
    }
}

public func enumLoopConsumeArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        enumConsume(x2) // expected-note {{consuming use}}
    }
}

public func enumLoopConsumeOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        enumConsume(x2) // expected-note {{consuming use}}
    }
}

public func enumDiamond(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    if boolValue {
        enumConsume(x2)
    } else {
        enumConsume(x2)
    }
}

public func enumDiamondArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if boolValue {
        enumConsume(x2) // expected-note {{consuming use}}
    } else {
        enumConsume(x2) // expected-note {{consuming use}}
    }
}

public func enumDiamondOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) {
    if boolValue {
        enumConsume(x2)
    } else {
        enumConsume(x2)
    }
}

public func enumDiamondInLoop(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          enumConsume(x2) // expected-note {{consuming use}}
      } else {
          enumConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func enumDiamondInLoopArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
      if boolValue {
          enumConsume(x2) // expected-note {{consuming use}}
      } else {
          enumConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func enumDiamondInLoopOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
      if boolValue {
          enumConsume(x2) // expected-note {{consuming use}}
      } else {
          enumConsume(x2) // expected-note {{consuming use}}
      }
    }
}

public func enumAssignToVar1(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func enumAssignToVar1Arg(_ x: EnumTy, @_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func enumAssignToVar1OwnedArg(_ x: EnumTy, @_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func enumAssignToVar2(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    enumUseMoveOnlyWithoutEscaping(x3)
}

public func enumAssignToVar2Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    enumUseMoveOnlyWithoutEscaping(x3)
}

public func enumAssignToVar2OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x2 // expected-note {{consuming use}}
    enumUseMoveOnlyWithoutEscaping(x3)
}

public func enumAssignToVar3(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    var x3 = x2
    x3 = x
    print(x3)
}

public func enumAssignToVar3Arg(_ x: EnumTy, @_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    x3 = x
    print(x3)
}

public func enumAssignToVar3OwnedArg(_ x: EnumTy, @_noImplicitCopy _ x2: __owned EnumTy) {
    var x3 = x2
    x3 = x
    print(x3)
}

public func enumAssignToVar4(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func enumAssignToVar4Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func enumAssignToVar4OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    let x3 = x2 // expected-note {{consuming use}}
    print(x2) // expected-note {{consuming use}}
    print(x3)
}

public func enumAssignToVar5(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    enumUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func enumAssignToVar5Arg(_ x: EnumTy, @_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    enumUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func enumAssignToVar5OwnedArg(_ x: EnumTy, @_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    var x3 = x2 // expected-note {{consuming use}}
    // TODO: Need to mark this as the lifetime extending use. We fail
    // appropriately though.
    enumUseMoveOnlyWithoutEscaping(x2)
    x3 = x
    print(x3)
}

public func enumPatternMatchIfLet1(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    if case let .klass(x) = x2 { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x)
    }
    if case let .klass(x) = x2 { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x)
    }
}

public func enumPatternMatchIfLet1Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    if case let .klass(x) = x2 { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x)
    }
    if case let .klass(x) = x2 { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x)
    }
}

public func enumPatternMatchIfLet1OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    if case let .klass(x) = x2 { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x)
    }
    if case let .klass(x) = x2 { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x)
    }
}

public func enumPatternMatchIfLet2(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        if case let .klass(x) = x2 {  // expected-note {{consuming use}}
            classUseMoveOnlyWithoutEscaping(x)
        }
    }
}

public func enumPatternMatchIfLet2Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    for _ in 0..<1024 {
        if case let .klass(x) = x2 {  // expected-note {{consuming use}}
            classUseMoveOnlyWithoutEscaping(x)
        }
    }
}

public func enumPatternMatchIfLet2OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    for _ in 0..<1024 {
        if case let .klass(x) = x2 {  // expected-note {{consuming use}}
            classUseMoveOnlyWithoutEscaping(x)
        }
    }
}

// This is wrong.
public func enumPatternMatchSwitch1(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k):
        classUseMoveOnlyWithoutEscaping(k)
        // This should be flagged as the use after free use. We are atleast
        // erroring though.
        enumUseMoveOnlyWithoutEscaping(x2)
    case .int:
        break
    }
}

public func enumPatternMatchSwitch1Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k):
        classUseMoveOnlyWithoutEscaping(k)
        // This should be flagged as the use after free use. We are atleast
        // erroring though.
        enumUseMoveOnlyWithoutEscaping(x2)
    case .int:
        break
    }
}

public func enumPatternMatchSwitch1OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k):
        classUseMoveOnlyWithoutEscaping(k)
        // This should be flagged as the use after free use. We are atleast
        // erroring though.
        enumUseMoveOnlyWithoutEscaping(x2)
    case .int:
        break
    }
}

public func enumPatternMatchSwitch2(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    switch x2 {
    case let .klass(k):
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    }
}

public func enumPatternMatchSwitch2Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k):
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    }
}

public func enumPatternMatchSwitch2OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) {
    switch x2 {
    case let .klass(k):
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    }
}

// QOI: We can do better here. We should also flag x2
public func enumPatternMatchSwitch2WhereClause(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k)
           where x2.doSomething():
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    case .klass:
        break
    }
}

public func enumPatternMatchSwitch2WhereClauseArg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k)
           where x2.doSomething():
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    case .klass:
        break
    }
}

public func enumPatternMatchSwitch2WhereClauseOwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) { // expected-error {{'x2' consumed more than once}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k)
           where x2.doSomething():
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    case .klass:
        break
    }
}

public func enumPatternMatchSwitch2WhereClause2(_ x: EnumTy) {
    @_noImplicitCopy let x2 = x
    switch x2 {
    case let .klass(k)
           where boolValue:
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    case .klass:
        break
    }
}

public func enumPatternMatchSwitch2WhereClause2Arg(@_noImplicitCopy _ x2: EnumTy) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    switch x2 { // expected-note {{consuming use}}
    case let .klass(k)
           where boolValue:
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    case .klass:
        break
    }
}

public func enumPatternMatchSwitch2WhereClause2OwnedArg(@_noImplicitCopy _ x2: __owned EnumTy) {
    switch x2 {
    case let .klass(k)
           where boolValue:
        classUseMoveOnlyWithoutEscaping(k)
    case .int:
        break
    case .klass:
        break
    }
}

/////////////////////////////
// Closure and Defer Tests //
/////////////////////////////

public func closureClassUseAfterConsume1(_ x: Klass) {
    let f = {
        @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2) // expected-note {{consuming use}}
        print(x2) // expected-note {{consuming use}}
    }
    f()
}

public func closureClassUseAfterConsume2(_ argX: Klass) {
    let f = { (_ x: Klass) in
        @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2) // expected-note {{consuming use}}
        print(x2) // expected-note {{consuming use}}
    }
    f(argX)
}

public func closureClassUseAfterConsumeArg(_ argX: Klass) {
    // TODO: Fix this
    let f = { (@_noImplicitCopy _ x2: Klass) in // expected-error {{'x2' has guaranteed ownership but was consumed}}
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2) // expected-note {{consuming use}}
        print(x2) // expected-note {{consuming use}}
    }
    f(argX)
}

public func closureCaptureClassUseAfterConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    let f = {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    f()
}

public func closureCaptureClassUseAfterConsumeError(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    let f = { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    f()
    let x3 = x2 // expected-note {{consuming use}}
    let _ = x3
}

public func closureCaptureClassArgUseAfterConsume(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let f = { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    f()
}

public func closureCaptureClassOwnedArgUseAfterConsume(@_noImplicitCopy _ x2: __owned Klass) {
    let f = {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    f()
}

public func closureCaptureClassOwnedArgUseAfterConsume2(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    let f = { // expected-note {{consuming use}}
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    f()
    let x3 = x2 // expected-note {{consuming use}}
    let _ = x3
}

public func deferCaptureClassUseAfterConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    defer {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    print(x)
}

public func deferCaptureClassUseAfterConsume2(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}

    // TODO: Defer error is b/c we have to lifetime extend x2 for the defer. The
    // use is a guaranteed use, so we don't emit an error on that use.
    defer {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    let x3 = x2 // expected-note {{consuming use}}
    let _ = x3
}

public func deferCaptureClassArgUseAfterConsume(@_noImplicitCopy _ x2: Klass) {
    classUseMoveOnlyWithoutEscaping(x2)
    defer {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    print("foo")
}

public func deferCaptureClassOwnedArgUseAfterConsume(@_noImplicitCopy _ x2: __owned Klass) {
    defer {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    print("foo")
}

public func deferCaptureClassOwnedArgUseAfterConsume2(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    defer {
        classUseMoveOnlyWithoutEscaping(x2)
        classConsume(x2)
        print(x2)
    }
    print(x2) // expected-note {{consuming use}}
}

public func closureAndDeferCaptureClassUseAfterConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    let f = {
        defer {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        print("foo")
    }
    f()
}

public func closureAndDeferCaptureClassUseAfterConsume2(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    let f = {
        classConsume(x2)
        defer {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        print("foo")
    }
    f()
}

public func closureAndDeferCaptureClassUseAfterConsume3(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    let f = { // expected-note {{consuming use}}
        classConsume(x2)
        defer {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        print("foo")
    }
    f()
    classConsume(x2) // expected-note {{consuming use}}
}

public func closureAndDeferCaptureClassArgUseAfterConsume(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let f = { // expected-note {{consuming use}}
        defer {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        print("foo")
    }
    f()
}

public func closureAndDeferCaptureClassOwnedArgUseAfterConsume(@_noImplicitCopy _ x2: __owned Klass) {
    let f = {
        defer {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        print("foo")
    }
    f()
}

public func closureAndDeferCaptureClassOwnedArgUseAfterConsume2(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    let f = { // expected-note {{consuming use}}
        defer {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        print("foo")
    }
    f()
    print(x2) // expected-note {{consuming use}}
}

public func closureAndClosureCaptureClassUseAfterConsume(_ x: Klass) {
    @_noImplicitCopy let x2 = x
    let f = {
        let g = {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        g()
    }
    f()
}

public func closureAndClosureCaptureClassUseAfterConsume2(_ x: Klass) {
    @_noImplicitCopy let x2 = x // expected-error {{'x2' consumed more than once}}
    let f = { // expected-note {{consuming use}}
        let g = {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        g()
    }
    f()
    print(x2) // expected-note {{consuming use}}
}


public func closureAndClosureCaptureClassArgUseAfterConsume(@_noImplicitCopy _ x2: Klass) { // expected-error {{'x2' has guaranteed ownership but was consumed}}
    let f = { // expected-note {{consuming use}}
        let g = {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        g()
    }
    f()
}

public func closureAndClosureCaptureClassOwnedArgUseAfterConsume(@_noImplicitCopy _ x2: __owned Klass) {
    let f = {
        let g = {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        g()
    }
    f()
}

public func closureAndClosureCaptureClassOwnedArgUseAfterConsume2(@_noImplicitCopy _ x2: __owned Klass) { // expected-error {{'x2' consumed more than once}}
    let f = { // expected-note {{consuming use}}
        let g = {
            classUseMoveOnlyWithoutEscaping(x2)
            classConsume(x2)
            print(x2)
        }
        g()
    }
    f()
    print(x2) // expected-note {{consuming use}}
}

/////////////////////////////
// Tests For Move Operator //
/////////////////////////////

func moveOperatorTest(_ k: __owned Klass) {
    @_noImplicitCopy let k2 = k // expected-error {{'k2' consumed more than once}}
    @_noImplicitCopy let k3 = _move k2 // expected-note {{consuming use}}
    let _ = _move k2 // expected-note {{consuming use}}
    let _ = k3
}
