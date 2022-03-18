//  JSONDecoder+KeyPathDecoding.swift

import Foundation

public enum JSONDecoderNestedDecodingError: Error {
  case nilUserInfoKey
  case emptyUserInfo
  case emptyKeyPaths
}

public extension JSONDecoder {

  /// Decodes a model T from json data with the given keypath.
  /// - Parameter type: type of the model
  /// - Parameter data: data to decode
  /// - Parameter keyPath: keypath should be joined with '.', Eg `currency.symbol`
  /// - Return: decoded model of type T
  func decode<T: Decodable>(_ type: T.Type, from data: Data, keyPath: String) throws -> T {
    guard let userInfoKey = CodingUserInfoKey(rawValue: Constant.nestedModelKeyPathCodingUserInfoKeyString) else {
      throw JSONDecoderNestedDecodingError.nilUserInfoKey
    }
    self.userInfo[userInfoKey] = keyPath
    return try self.decode(ModelResponse<T>.self, from: data).model
  }

  private struct Constant {
    static let nestedModelKeyPathCodingUserInfoKeyString = "nested_model_keypath"
  }

  private struct DynamicKey: CodingKey {
    let stringValue: String
    init?(stringValue: String) {
      self.stringValue = stringValue
      self.intValue = nil
    }

    let intValue: Int?
    init?(intValue: Int) {
      return nil
    }
  }

  private struct ModelResponse<TargetModel: Decodable>: Decodable {
    let model: TargetModel

    init(from decoder: Decoder) throws {
      guard let userInfoKey = CodingUserInfoKey(rawValue: Constant.nestedModelKeyPathCodingUserInfoKeyString) else {
        throw JSONDecoderNestedDecodingError.nilUserInfoKey
      }

      guard let userInfo = decoder.userInfo[userInfoKey] as? String, !userInfo.isEmpty else {
        throw JSONDecoderNestedDecodingError.emptyUserInfo
      }

      var keyPaths = userInfo.split(separator: ".").compactMap { DynamicKey(stringValue: String($0)) }

      // Get the last key for decoding with the last nested container
      guard let lastKey = keyPaths.popLast() else {
        throw JSONDecoderNestedDecodingError.emptyKeyPaths
      }

      // Loop getting container until reach final one
      var targetContainer = try decoder.container(keyedBy: DynamicKey.self)
      for key in keyPaths {
        targetContainer = try targetContainer.nestedContainer(keyedBy: DynamicKey.self, forKey: key)
      }

      model = try targetContainer.decode(TargetModel.self, forKey: lastKey)
    }
  }
}
