// Port of Flecs example: prefabs/slots
module flecs_ex_prefab_slots;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity ship = w.prefab("SpaceShip");

	Entity engine = w.prefab_child(ship, "Engine");
	w.add_pair(engine, flecs::ECS_SLOT_OF, ship.id);

	Entity cockpit = w.prefab_child(ship, "Cockpit");
	w.add_pair(cockpit, flecs::ECS_SLOT_OF, ship.id);

	Entity pilot_seat = w.prefab_child(cockpit, "PilotSeat");
	w.add_pair(pilot_seat, flecs::ECS_SLOT_OF, ship.id);

	Entity inst = w.instantiate(ship, "my_spaceship");

	Entity inst_engine = w.target(inst, engine.id, 0);
	Entity inst_cockpit = w.target(inst, cockpit.id, 0);
	Entity inst_seat = w.target(inst, pilot_seat.id, 0);

	io::printfn("instance engine:  %s", w.path(inst_engine));
	io::printfn("instance cockpit: %s", w.path(inst_cockpit));
	io::printfn("instance seat:    %s", w.path(inst_seat));
}
