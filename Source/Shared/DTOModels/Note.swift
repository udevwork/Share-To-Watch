import Foundation
import CoreData

enum NoteType: String {
    case text
    case check
    case link
}

struct SimpleNote: Identifiable {
    var id = UUID()
    var text: String?
    var noteType: String?
}

extension Note {
    // Преобразование объекта Note в словарь
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["text"] = self.text ?? ""
        dict["noteType"] = self.noteType ?? ""
        return dict
    }
    
    // Создание объекта Note из словаря
    static func from(dictionary: [String: Any], context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.text = dictionary["text"] as? String
        note.noteType = dictionary["noteType"] as? String
        return note
    }
}

extension SimpleNote {
    // Преобразование SimpleNote в словарь
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["text"] = self.text ?? ""
        dict["noteType"] = self.noteType ?? ""
        return dict
    }
    
    // Создание SimpleNote из словаря
    static func from(dictionary: [String: Any]) -> SimpleNote {
        let text = dictionary["text"] as? String
        let noteType = dictionary["noteType"] as? String
        return SimpleNote(text: text, noteType: noteType)
    }
}

extension Array where Element: Note {
    
    // Преобразование массива Note в массив словарей
    func toDictionaryArray() -> [[String: Any]] {
        return self.map { $0.toDictionary() }
    }
    
    // Создание массива Note из массива словарей
    static func from(dictionaryArray: [[String: Any]], context: NSManagedObjectContext) -> [Note] {
        return dictionaryArray.map { Note.from(dictionary: $0, context: context) }
    }
}

extension Array where Element == SimpleNote {
    
    // Преобразование массива SimpleNote в массив словарей
    func toDictionaryArray() -> [[String: Any]] {
        return self.map { $0.toDictionary() }
    }
    
    // Создание массива SimpleNote из массива словарей
    static func from(dictionaryArray: [[String: Any]]) -> [SimpleNote] {
        return dictionaryArray.map { SimpleNote.from(dictionary: $0) }
    }
}
