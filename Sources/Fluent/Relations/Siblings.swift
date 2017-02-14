/// Represents a many-to-many relationship
/// through a Pivot table from the Local 
/// entity to the Foreign entity.
public final class Siblings<Foreign: Entity> {
    /// This will be used to filter the 
    /// collection of foreign entities related
    /// to the local entity type.
    let local: Entity

    let pivotType: PivotProtocol.Type

    /// Create a new Siblings relationsip using 
    /// a Local and Foreign entity.
    public init<Local: Entity>(
        from local: Local,
        to foreignType: Foreign.Type = Foreign.self,
        through pivotType: PivotProtocol.Type = Pivot<Local, Foreign>.self
    ) {
        self.local = local
        self.pivotType = pivotType
    }
}

extension Siblings {
    /// See PivotProtocol.related
    public func related(_ left: Entity, _ right: Entity) throws -> Bool {
        return try pivotType.related(left, right)
    }

    /// See PivotProtocol.attach
    public func attach(_ left: Entity, _ right: Entity) throws {
        return try pivotType.attach(left, right)
    }

    /// See PivotProtocol.detach
    public func detach(_ left: Entity, _ right: Entity) throws {
        return try pivotType.detach(left, right)
    }
}

extension Siblings: QueryRepresentable {
    /// Creates a Query from the Siblings relation.
    /// This includes a pivot, join, and filter.
    public func makeQuery() throws -> Query<Foreign> {
        guard let localId = local.id else {
            throw RelationError.idRequired(local)
        }

        let query = try Foreign.query()

        try query.join(pivotType)
        try query.filter(pivotType, type(of: local).foreignIdKey, localId)

        return query
    }
}

extension Entity {
    /// Creates a Siblings relation using the current
    /// entity as the Local entity in the relation.
    public func siblings<Foreign: Entity>(
        type foreignType: Foreign.Type = Foreign.self
    ) throws -> Siblings<Foreign> {
        return try Siblings(from: self)
    }
}
