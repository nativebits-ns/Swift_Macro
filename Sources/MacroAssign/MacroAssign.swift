// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(CodingKeys))
public macro GenerateCodingKeys() = #externalMacro(module: "MacroAssignMacros", type: "GenerateCodingKeysMacro")
