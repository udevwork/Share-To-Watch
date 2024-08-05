import Foundation
import SwiftData

@Model
class Note: Codable {
    
    enum NoteType: String, Codable {
        case plain
        case checkbox
        case unowned
    }
    
    var viewID = UUID().uuidString
    var id: String?
    var text: String?
    var noteType: NoteType? = NoteType.plain
    var isCheked: Bool = false
    var lastEditingDate: Date?


    init(id: String,
         text: String? = "New note",
         noteType: NoteType? = NoteType.plain,
         isCheked: Bool = false
    ) {
        self.id = id
        self.text = text
        self.noteType = noteType
        self.isCheked = isCheked
    }
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case noteType
        case isCheked
        case lastEditingDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try? container.decode(String.self, forKey: .text)
        if let type = try? container.decode(NoteType?.self, forKey: .noteType) {
            self.noteType = type
        } else {
            self.noteType = .plain
        }
        id = try? container.decode(String.self, forKey: .id)
        isCheked = try container.decode(Bool.self, forKey: .isCheked)
        lastEditingDate = try? container.decode(Date?.self, forKey: .lastEditingDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(noteType, forKey: .noteType)
        try container.encode(id, forKey: .id)
        try container.encode(isCheked, forKey: .isCheked)
        try container.encode(lastEditingDate, forKey: .lastEditingDate)
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
        do {
             let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            
            let decoder = JSONDecoder()
            
            return try decoder.decode(Note.self, from: data)
        } catch let err {
            print(err.localizedDescription)
            return nil
        }
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
