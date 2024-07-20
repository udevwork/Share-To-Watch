import Foundation
import SwiftData

@Model
class Note: Codable {
    
    @Attribute(.unique)
    let id = UUID().uuidString
    
    var text: String?
    var noteType: String?
    
    init(text: String? = nil, noteType: String? = nil) {
        self.text = text
        self.noteType = noteType
    }
    
    enum CodingKeys: CodingKey {
        case text
        case noteType
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        noteType = try container.decode(String.self, forKey: .noteType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(noteType, forKey: .noteType)
    }
}

extension Note {
    
    // Преобразование объекта Note в словарь
    func toDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    // Преобразование словаря в объект Note
    static func fromDictionary(_ dictionary: [String: Any]) -> Note? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(Note.self, from: data)
    }
}
extension Array where Element: Note {
    
    // Преобразование массива объектов Note в массив словарей
    func toDictionaryArray() -> [[String: Any]]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [[String: Any]] }
    }
    
    // Преобразование массива словарей в массив объектов Note
    static func fromDictionaryArray(_ array: [[String: Any]]) -> [Note]? {
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode([Note].self, from: data)
    }
}
