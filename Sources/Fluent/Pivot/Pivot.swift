/// A basic Pivot using two entities:
/// left and right.
/// The pivot itself conforms to entity
/// and can be used like any other Fluent model
/// in preparations, querying, etc.
public final class Pivot<
    Left: Entity,
    Right: Entity
>: PivotProtocol {
    public static var entity: String {
        if Left.name < Right.name {
            return "\(Left.name)_\(Right.name)"
        } else {
            return "\(Right.name)_\(Left.name)"
        }
    }

    public static var name: String {
        return entity
    }

    public var id: Node?
    public var leftId: Node
    public var rightId: Node
    public var exists = false

    public init(_ left: Left, _ right: Right) throws {
        guard left.exists else {
            throw PivotError.existRequired(left)
        }

        guard let leftId = left.id else {
            throw PivotError.idRequired(left)
        }

        guard right.exists else {
            throw PivotError.existRequired(right)
        }

        guard let rightId = right.id else {
            throw PivotError.idRequired(right)
        }

        self.leftId = leftId
        self.rightId = rightId
    }

    public init(node: Node, in context: Context) throws {
        id = try node.extract(type(of: self).idKey)

        leftId = try node.extract(Left.foreignIdKey)
        rightId = try node.extract(Right.foreignIdKey)
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
            Left.foreignIdKey: leftId,
            Right.foreignIdKey: rightId,
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id(for: self)
            builder.foreignId(for: Left.self)
            builder.foreignId(for: Right.self)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }

    /// See PivotProtocol.related
    public static func related(_ left: Entity, _ right: Entity) throws -> Bool {
        let (leftId, rightId) = try assertSaved(left, right)

        let results = try query()
            .filter(type(of: left).foreignIdKey, leftId)
            .filter(type(of: right).foreignIdKey, rightId)
            .first()

        return results != nil
    }

    /// See PivotProtocol.attach
    public static func attach(_ left: Entity, _ right: Entity) throws {
        _ = try assertSaved(left, right)

        guard let l = left as? Left else {
            throw PivotError.invalidType(left, desiredType: Left.self)
        }

        guard let r = right as? Right else {
            throw PivotError.invalidType(right, desiredType: Right.self)
        }

        var pivot = try Pivot<Left, Right>(l, r)
        try pivot.save()
    }

    /// See PivotProtocol.detach
    public static func detach(_ left: Entity, _ right: Entity) throws {
        let (leftId, rightId) = try assertSaved(left, right)

        try query()
            .filter(Left.foreignIdKey, leftId)
            .filter(Right.foreignIdKey, rightId)
            .delete()
    }
}

// MARK: Convenience

private func assertSaved(_ left: Entity, _ right: Entity) throws -> (Node, Node) {
    guard left.exists else {
        throw PivotError.existRequired(left)
    }

    guard let leftId = left.id else {
        throw PivotError.idRequired(left)
    }

    guard right.exists else {
        throw PivotError.existRequired(right)
    }

    guard let rightId = right.id else {
        throw PivotError.idRequired(right)
    }

    return (leftId, rightId)
}
