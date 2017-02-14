/// Errors that can be thrown while
/// attempting to attach, detach, or
/// check the relation on pivots.
public enum PivotError: Error {
    case idRequired(Entity)
    case existRequired(Entity)
    case invalidType(Entity, desiredType: Entity.Type)
    case unspecified(Error)
}

extension PivotError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .idRequired(let entity):
            reason = "Identifier required for \(entity)"
        case .existRequired(let entity):
            reason = "Entity must exist in the database. Try saving the entity first \(entity)"
        case .invalidType(let entity, let desiredType):
            reason = "Invalid entity \(entity): type \(desiredType) required."
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Database pivot error: \(reason)"
    }
}
