// Port of Flecs example: relationships/symmetric_relations
module flecs_ex_rel_symmetric;

import flecs;
import std::io;

fn void main()
{
	World w = flecs::create();
	defer w.fini();

	Entity trades = w.entity("TradesWith");
	w.add_id(trades, flecs::ECS_SYMMETRIC);

	Entity player_1 = w.entity();
	Entity player_2 = w.entity();

	w.add_pair(player_1, trades.id, player_2.id);

	io::printfn("Player 1 trades with Player 2: %s",
		w.has_pair(player_1, trades.id, player_2.id) ? "true" : "false");
	io::printfn("Player 2 trades with Player 1: %s",
		w.has_pair(player_2, trades.id, player_1.id) ? "true" : "false");
}
