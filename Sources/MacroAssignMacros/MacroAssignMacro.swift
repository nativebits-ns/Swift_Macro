import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GenerateCodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax, providingMembersOf
        declaration: some DeclGroupSyntax, conformingTo
        protocols: [TypeSyntax], in
        context: some MacroExpansionContext) throws -> [DeclSyntax] {
            guard let structDecl = declaration.as(StructDeclSyntax.self) else {
                throw MacroExpansionErrorMessage("@GenerateCodingKeys can only be applied to structs.")
            }
            
            let members = structDecl.memberBlock.members
            
            let storedProperties = members.compactMap { member -> (String)? in
                guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                      !varDecl.modifiers.contains(where: { $0.name.text == "static" }),
                      let binding = varDecl.bindings.first,
                      let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                      binding.accessorBlock == nil
                else { return nil }
                return (identifier)
            }
            
            let params = storedProperties.map { name in
                var result: String = ""
                for char in name {
                    if char.isUppercase {
                        result.append("_")
                        result.append(char.lowercased())
                    } else {
                        result.append(char)
                    }
                }
                return result
            }
            
            // Alternate way
            //            let cases = zip(storedProperties, params).map { property, param in
            //                "case \(property) = \"\(param)\""
            //            }.joined(separator: "\n")
            //
            //            let enumSyntax: DeclSyntax = """
            //                                        enum CodingKeys: String, CodingKey {
            //                                            \(raw: cases)
            //                                        }
            //                                        """
            
            let cases = zip(storedProperties, params).map { property, param in
                MemberBlockItemSyntax(
                    decl: EnumCaseDeclSyntax(
                        elements: EnumCaseElementListSyntax([
                            EnumCaseElementSyntax(
                                name: .identifier(property),
                                rawValue: InitializerClauseSyntax(
                                    value: StringLiteralExprSyntax(content: param)
                                )
                            )
                        ])
                    )
                )
            }
            
            let enumDecl = EnumDeclSyntax(
                name: .identifier("CodingKeys"),
                inheritanceClause: InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax([
                        InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("String")),
                                            trailingComma: .commaToken() ),
                        InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CodingKey")))
                    ])
                ),
                memberBlock: MemberBlockSyntax(
                    members: MemberBlockItemListSyntax(cases)
                )
            )
            
            let enumSyntax = DeclSyntax(enumDecl)
            
            return [enumSyntax]
        }
}

@main
struct MacroAssignPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GenerateCodingKeysMacro.self,
    ]
}
