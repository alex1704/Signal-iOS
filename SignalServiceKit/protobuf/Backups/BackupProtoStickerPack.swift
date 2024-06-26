//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

// Code generated by Wire protocol buffer compiler, do not edit.
// Source: BackupProto.BackupProtoStickerPack in Backup.proto
import Foundation
import Wire

public struct BackupProtoStickerPack {

    public var id: Foundation.Data
    public var key: Foundation.Data
    public var title: String
    public var author: String
    /**
     * First one should be cover sticker.
     */
    public var stickers: [BackupProtoStickerPackSticker] = []
    public var unknownFields: UnknownFields = .init()

    public init(
        id: Foundation.Data,
        key: Foundation.Data,
        title: String,
        author: String,
        configure: (inout Self) -> Swift.Void = { _ in }
    ) {
        self.id = id
        self.key = key
        self.title = title
        self.author = author
        configure(&self)
    }

}

#if !WIRE_REMOVE_EQUATABLE
extension BackupProtoStickerPack : Equatable {
}
#endif

#if !WIRE_REMOVE_HASHABLE
extension BackupProtoStickerPack : Hashable {
}
#endif

extension BackupProtoStickerPack : Sendable {
}

extension BackupProtoStickerPack : ProtoMessage {

    public static func protoMessageTypeURL() -> String {
        return "type.googleapis.com/BackupProto.BackupProtoStickerPack"
    }

}

extension BackupProtoStickerPack : Proto3Codable {

    public init(from protoReader: ProtoReader) throws {
        var id: Foundation.Data = .init()
        var key: Foundation.Data = .init()
        var title: String = ""
        var author: String = ""
        var stickers: [BackupProtoStickerPackSticker] = []

        let token = try protoReader.beginMessage()
        while let tag = try protoReader.nextTag(token: token) {
            switch tag {
            case 1: id = try protoReader.decode(Foundation.Data.self)
            case 2: key = try protoReader.decode(Foundation.Data.self)
            case 3: title = try protoReader.decode(String.self)
            case 4: author = try protoReader.decode(String.self)
            case 5: try protoReader.decode(into: &stickers)
            default: try protoReader.readUnknownField(tag: tag)
            }
        }
        self.unknownFields = try protoReader.endMessage(token: token)

        self.id = id
        self.key = key
        self.title = title
        self.author = author
        self.stickers = stickers
    }

    public func encode(to protoWriter: ProtoWriter) throws {
        try protoWriter.encode(tag: 1, value: self.id)
        try protoWriter.encode(tag: 2, value: self.key)
        try protoWriter.encode(tag: 3, value: self.title)
        try protoWriter.encode(tag: 4, value: self.author)
        try protoWriter.encode(tag: 5, value: self.stickers)
        try protoWriter.writeUnknownFields(unknownFields)
    }

}

#if !WIRE_REMOVE_CODABLE
extension BackupProtoStickerPack : Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringLiteralCodingKeys.self)
        self.id = try container.decode(stringEncoded: Foundation.Data.self, forKey: "id")
        self.key = try container.decode(stringEncoded: Foundation.Data.self, forKey: "key")
        self.title = try container.decode(String.self, forKey: "title")
        self.author = try container.decode(String.self, forKey: "author")
        self.stickers = try container.decodeProtoArray(BackupProtoStickerPackSticker.self, forKey: "stickers")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringLiteralCodingKeys.self)
        let includeDefaults = encoder.protoDefaultValuesEncodingStrategy == .include

        if includeDefaults || !self.id.isEmpty {
            try container.encode(stringEncoded: self.id, forKey: "id")
        }
        if includeDefaults || !self.key.isEmpty {
            try container.encode(stringEncoded: self.key, forKey: "key")
        }
        if includeDefaults || !self.title.isEmpty {
            try container.encode(self.title, forKey: "title")
        }
        if includeDefaults || !self.author.isEmpty {
            try container.encode(self.author, forKey: "author")
        }
        if includeDefaults || !self.stickers.isEmpty {
            try container.encodeProtoArray(self.stickers, forKey: "stickers")
        }
    }

}
#endif
