/// A pivot between two many-to-many
/// database entities.
///
/// For example: users > users+teams < teams
///
/// let teams = users.teams()
public protocol PivotProtocol: Entity {
    /// Returns true if the two entities are related
    static func related(_ left: Entity, _ right: Entity) throws -> Bool

    /// Attaches the two entities
    /// Entities must be saved before attempting attach.
    static func attach(_ left: Entity, _ right: Entity) throws

    /// Detaches the two entities.
    /// Entities must be saved before attempting detach.
    static func detach(_ left: Entity, _ right: Entity) throws
}
