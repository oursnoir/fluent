import XCTest
import Fluent

class PivotTests: XCTestCase {
    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testEntityAttach() throws {
        Pivot<Atom, Compound>.database = db
        var atom = Atom(name: "Hydrogen")
        atom.id = 42
        atom.exists = true

        let compound = Compound(name: "Water")
        compound.id = 1337
        compound.exists = true

        try atom.compounds().attach(atom, compound)

        guard let query = lqd.lastQuery else {
            XCTFail("No query recorded")
            return
        }

        let (sql, _) = GeneralSQLSerializer(sql: query).serialize()

        XCTAssertEqual(
            sql,
            "INSERT INTO `atom_compound` (`\(lqd.idKey)`, `\(Atom.foreignIdKey)`, `\(Compound.foreignIdKey)`) VALUES (?, ?, ?)"
        )
    }

    func testStuff() throws {
        Atom.database = db
        Compound.database = db
        Proton.database = db

        var atom = Atom(name: "Hydrogen")
        atom.id = 42
        atom.exists = true

        let compounds = Siblings(
            from: atom,
            to: Compound.self,
            through: Proton.self
        )
        _ = try compounds.all()

        guard let query = lqd.lastQuery else {
            XCTFail("No query recorded")
            return
        }

        let (sql, _) = GeneralSQLSerializer(sql: query).serialize()

        XCTAssertEqual(
            sql,
            "SELECT `compounds`.* FROM `compounds` JOIN `protons` ON `compounds`.`#id` = `protons`.`compound_#id` WHERE `protons`.`atom_#id` = ?"
        )
    }

    static let allTests = [
        ("testEntityAttach", testEntityAttach),
    ]
}

extension Proton: PivotProtocol {
    static func related(_ left: Entity, _ right: Entity) throws -> Bool {
        return false
    }

    static func attach(_ left: Entity, _ right: Entity) throws {

    }

    static func detach(_ left: Entity, _ right: Entity) throws {

    }
}
