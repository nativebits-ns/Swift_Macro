import MacroAssign

@GenerateCodingKeys
struct Article: Codable {
    let articleId: Int
    let articleTitle: String
    let authorName: String
    let publishedDate: String
}

@GenerateCodingKeys
struct Comment: Codable {
    let commentId: Int
    let articleId: Int
    let commenterName: String
    let createdAt: String
}
