//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

// Code generated by Wire protocol buffer compiler, do not edit.
// Source: BackupProto.BackupProtoGroupJoinRequestCanceledUpdate in Backup.proto
import Foundation
import Wire

public struct BackupProtoGroupJoinRequestCanceledUpdate {

    public var requestorAci: Foundation.Data
    public var unknownFields: UnknownFields = .init()

    public init(requestorAci: Foundation.Data) {
        self.requestorAci = requestorAci
    }

}

#if !WIRE_REMOVE_EQUATABLE
extension BackupProtoGroupJoinRequestCanceledUpdate : Equatable {
}
#endif

#if !WIRE_REMOVE_HASHABLE
extension BackupProtoGroupJoinRequestCanceledUpdate : Hashable {
}
#endif

extension BackupProtoGroupJoinRequestCanceledUpdate : Sendable {
}

extension BackupProtoGroupJoinRequestCanceledUpdate : ProtoMessage {

    public static func protoMessageTypeURL() -> String {
        return "type.googleapis.com/BackupProto.BackupProtoGroupJoinRequestCanceledUpdate"
    }

}

extension BackupProtoGroupJoinRequestCanceledUpdate : Proto3Codable {

    public init(from protoReader: ProtoReader) throws {
        var requestorAci: Foundation.Data = .init()

        let token = try protoReader.beginMessage()
        while let tag = try protoReader.nextTag(token: token) {
            switch tag {
            case 1: requestorAci = try protoReader.decode(Foundation.Data.self)
            default: try protoReader.readUnknownField(tag: tag)
            }
        }
        self.unknownFields = try protoReader.endMessage(token: token)

        self.requestorAci = requestorAci
    }

    public func encode(to protoWriter: ProtoWriter) throws {
        try protoWriter.encode(tag: 1, value: self.requestorAci)
        try protoWriter.writeUnknownFields(unknownFields)
    }

}

#if !WIRE_REMOVE_CODABLE
extension BackupProtoGroupJoinRequestCanceledUpdate : Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringLiteralCodingKeys.self)
        self.requestorAci = try container.decode(stringEncoded: Foundation.Data.self, forKey: "requestorAci")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringLiteralCodingKeys.self)
        let includeDefaults = encoder.protoDefaultValuesEncodingStrategy == .include

        if includeDefaults || !self.requestorAci.isEmpty {
            try container.encode(stringEncoded: self.requestorAci, forKey: "requestorAci")
        }
    }

}
#endif
